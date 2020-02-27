//
//  ChatListViewController.swift
//  DateApp
//
//  Created by ryan on 12/22/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit

class ChatListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var refreshControl: UIRefreshControl!
    private var cardListNotificationModel = DViewModel<CardListNotificationModel>()
    private var chatSegue: DSegue!
    private var popupSegue: DSegue!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.makeNavigationBarDefaultStyle()
        self.navigationController?.navigationBar.setBottomBorderColor(color: UIColor(rgba: "#e6e6e6"), height: 1)
        // 좌측 닫기 버튼
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(image: UIImage(assetIdentifier: .Close), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ChatListViewController.close))
        ]
        
        navigationItem.title = "채팅 목록"
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)   // 내용없는 셀 표시 안함
        
        // refresh controll
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ChatListViewController.pulldown(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        // viewmodel
        
        _app.talkChannelsViewModel.bind (view: self) { [weak self] (model, oldModel) -> () in
            self?.tableView.reloadData()
            self?.refreshControl.endRefreshing()
        }
        
        cardListNotificationModel.bind (view: self) { [weak self] (model, oldModel) -> () in
            self?.tableView.reloadData()
        }
        
        // segue
        
        chatSegue = DSegue(source: self) { () -> (destination: UIViewController, style: DSegueStyle)? in
            let wrapper = MessagingTableViewControllerWrapper()
            wrapper.initChannel(channelUrl: "", userName: _app.sessionViewModel.model?.name ?? "Unknown", userId: "\(_app.sessionViewModel.model?.id ?? -1)")
            let destination = wrapper.viewController
            let style = DSegueStyle.Show(animated: true)
            
            _app.ga.trackingViewName(viewName: .chat)
            
            _app.sendBird.messagingTableViewController = wrapper.viewController // weak 참조 (message 전달을 위함)
            return (destination as! UIViewController, style)
        }
        
        popupSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "ConfirmPopupController") as! ConfirmPopupController
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: 172.0)
            })
            return (destination, style)
        })
        
    }
    
    deinit {
        print(#function, "\(self)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _app.ga.trackingViewName(viewName: .chat_list)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reloadApi()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is MessagingTableViewController {
            if let vm = sender as? DViewModel<ChannelModel>, let channelModel = vm.model {
                if let channelUrl = channelModel.channel.getUrl() {
                    
                    MessagingTableViewControllerWrapper.refreshViewController(viewController: segue.destination, channelUrl: channelUrl)
                    _app.sendBird.joinMessagingWithChannelUrl(channelUrl: channelUrl)
                }
            }
        } else if let vc = segue.destination as? ConfirmPopupController, let channelModel = (sender as? DViewModel<ChannelModel>)?.model {
            
            vc.line1 = ("\(channelModel.channelName)님과 대화를 시작할까요?", .Title)
            vc.line2 = ("둘 중 한분만 대화방을 열면 채팅이 가능합니다", .Normal)
            vc.line3 = ("30버찌", .Red)
            vc.submitHandler = { (popup: UIViewController) -> Void in
                popup.dismiss(animated:true, completion: { () -> Void in
                    
                    // 서버에 잠금해제 요청
                    let targetUserId = channelModel.targetUserId
                    let responseViewModel = ApiResponseViewModelBuilder<ServerDefaultResponseModel> (successHandlerWithDefaultError: { [weak self] (model) -> Void in
                        // 방정보 갱신 후 가능하면 대화 참여
                        _app.talkChannelsViewModel.bindOnce { (model, oldModel) -> () in
                            guard let talkChannels = model else {
                                return
                            }
                            let matchedChannel = talkChannels.filter({ (channel) -> Bool in
                                if channel.channelType == .Opened && channel.channelUrl == channelModel.channelUrl {
                                    return true
                                } else {
                                    return false
                                }
                            }).first
                            if matchedChannel != nil {
                                // 바로 대화 참여
                                self?.chatSegue.performWithSender(sender: sender as AnyObject)
                            }
                        }
                        self?.reloadApi()
                        }).viewModel
                    let _ = _app.api.chatUnlock(targetUserId: targetUserId, apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
                })
            }
        } else if let vc = segue.destination as? CardDetailViewController {
            vc.isFromChatView = true
            
            // 선택한 셀의 id 전달 (target user id)
            if let sender = sender as? UIView , 0 <= sender.tag {
                vc.targetUserId = sender.tag
            }
        } else if let vc = segue.destination as? NewsFullListViewController {
            vc.title = "당신을 좋아해요"
            vc.dataType = .LikeMe
        }
        
    }
}

extension ChatListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .delete {
            // 채널 나가기
            confirm(title: "대화방을 나가시겠습니까?", message: "대화방이 삭제되며 더이상 대화를 진행하실 수 없습니다") { (action) -> Void in
                
                if let channelModel = _app.talkChannelsViewModel.model?[indexPath.row] {
                    let channelUrl = channelModel.channel.getUrl()
                    let responseViewModel = ApiResponseViewModelBuilder<ServerDefaultResponseModel>(successHandlerWithDefaultError: {(response) -> Void in
                        _app.sendBird.endMessagingWithChannelUrl(channelUrl: channelUrl!)
                    }).viewModel
                    let _ = _app.api.chatLeave(targetUserId: channelModel.targetUserId, apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: // chat info cell
            return 60
        case 1: // channel cell
            if let c = _app.talkChannelsViewModel.model?.count, c > 0 {
                return 95
            }
            return 470  // empty cell
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 채팅방 선택시
        if indexPath.section == 1 {
            if let cell = tableView.cellForRow(at: indexPath) as? ChatChannelCell, let channelModel = cell.channelModel {
                switch channelModel.channelType {
                case .Locked:   // 잠김상태임 결제 후 open
                    popupSegue.performWithSender(sender: DViewModel<ChannelModel>(channelModel))
                case .Opened:
                    chatSegue.performWithSender(sender: DViewModel<ChannelModel>(channelModel))
                    break
                case .Closed:
                    break
                }
            }
        }
    }
}

extension ChatListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard _app.talkChannelsViewModel.model != nil else {
            // 로딩전에는 좋아요 수만 보여줌
            return 1
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1    // chat info cell
        case 1:
            if let count = _app.talkChannelsViewModel.model?.count {
                return count
            } else {
                return 1    // empty cell 보여줄거임
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatInfoCell") as! ChatInfoCell
            cell.likeCount = cardListNotificationModel.model?.likeMeCount ?? 0
            return cell
        case 1:
            if let c = _app.talkChannelsViewModel.model?.count, c > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelCell") as! ChatChannelCell
                if let channel = _app.talkChannelsViewModel.model?[indexPath.row] {
                    cell.channelModel = channel
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatEmptyCell")!
                return cell
            }
        default:
            fatalError()
        }
    }
}

extension ChatListViewController: ApiReloadable {
    func reloadApi() {
        
        _app.talkChannelsViewModel.reloadWithLoadingViewModel(loadingViewModel: _app.loadingViewModel)
        
        // 나를 좋아요로 응답해야할 카드 수 확인
        let responseViewModel = ApiResponseViewModelBuilder<CardListNotificationModel>(successHandler: { [weak self] (cardListNotificationModel) -> Void
            in
            self?.cardListNotificationModel.model = cardListNotificationModel
        }).viewModel
        let _ = _app.api.cardListNotification(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
    }
}

extension ChatListViewController {
    
    @objc func close(_ sender: AnyObject?) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func pulldown(_ sender: AnyObject?) {
        reloadApi()
    }
    
    /*
    func updatedChannel(channel: ChannelModel?) {
        // channel 정보 바뀌었습니다. 가장 상단으로 이동 되어야 합니다.
        guard let channel = channel else {
            return
        }
        var channels = _app.talkChannelsViewModel.model?.filter { (channelElm) -> Bool in
            if channel.channel.getId() == channelElm.channel.getId() {
                return false
            }
            return true
        }
        channels?.insert(channel, atIndex: 0)
        _app.talkChannelsViewModel.model = channels
    }*/
}
