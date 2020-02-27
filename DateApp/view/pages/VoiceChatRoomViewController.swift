//
//  VoiceChatRoomViewController.swift
//  DateApp
//
//  Created by Yang Hyeon Gyu on 2017. 3. 19..
//  Copyright © 2017년 iflet.com. All rights reserved.
//

import UIKit

class VoiceChatRoomViewController : UIViewController {
    private var profileRequireSegue: DSegue!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var refreshControl: UIRefreshControl!
    
    private var chatSegue: DSegue!
    
    private var myHeartListSegue: DSegue!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.makeNavigationBarDefaultStyle()
        
        navigationItem.title = "이야기 보관함"
        
        profileRequireSegue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "FillProfileInformationViewController")
            let style = DSegueStyle.Show(animated: true)
            return (destination, style)
            })
        
        if _app.sessionViewModel.model?.status != .Normal {
            if _app.sessionViewModel.model?.status == .Waiting {
                alert(title: "프로필 승인 대기중입니다.", message: "서비스를 이용하기 위해선 프로필 승인이 완료되어야 합니다.")
                return
            }
            
            confirm(title: "프로필 입력화면으로 이동합니다.", message: "서비스를 이용하기 위해선 추가 회원정보를 입력해야 합니다", handler: { [weak self] (action) -> Void in
                self?.profileRequireSegue.perform()
                })
        }
        
        _app.voiceChatRoomViewModel.bind (view: self) { [weak self] (model, oldModel) -> () in
            self?.tableView.reloadData()
        }
        
        chatSegue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "voiceChatViewController") as! VoiceChatViewController
            let style = DSegueStyle.Show(animated: true)
            return (destination, style)
        })
        
        myHeartListSegue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "MyHeartListViewController") as! MyHeartListViewController
            let style = DSegueStyle.Show(animated: true)
            return (destination, style)
            })
        
        
        _app.voiceChatRoomViewModel.model = []
        _app.voiceChatRoomViewModel.reload()
        
        _app.voiceChatRoomViewModel.onShouldUpdateMyChatList = { [weak self] in
            guard let wself = self else { return }
            wself.tableView.reloadData()
        }
        _app.voiceChatRoomViewModel.getMyVoiceChatList()
        _app.voiceChatRoomViewModel.getMyVoiceRank()
        _app.voiceChatRoomViewModel.getVoiceRankList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "이야기 보관함"
        
        if animated {
            _app.voiceChatRoomViewModel.model = []
            _app.voiceChatRoomViewModel.reload()
        }
        
        if _app.sessionViewModel.model?.status != .Normal {
            if _app.sessionViewModel.model?.status == .Waiting {
                alert(title: "프로필 승인 대기중입니다.", message: "서비스를 이용하기 위해선 프로필 승인이 완료되어야 합니다.")
                return
            }
            
            confirm(title: "프로필 입력화면으로 이동합니다.", message: "서비스를 이용하기 위해선 추가 회원정보를 입력해야 합니다", handler: { [weak self] (action) -> Void in
                self?.profileRequireSegue.perform()
                })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? VoiceChatViewController, let voiceChatRoomModel = (sender as? DViewModel<VoiceChatRoomModel>)?.model {
            _app.voiceChatRoomViewModel.check(voiceChatRoomModel: voiceChatRoomModel)
            vc.voiceChatRoomModel = voiceChatRoomModel
        }
    }
}

extension VoiceChatRoomViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: // chat info cell
            return 60
        case 1: // channel cell
            if indexPath.row == 0 {
                if _app.voiceChatRoomViewModel.myChatList?.first != nil {
                    return 95
                }else {
                    return 0
                }
            }else {
                if let c = _app.voiceChatRoomViewModel.model?.count, c > 0 {
                    return 95
                }
            }
            
            return 470  // empty cell
        default:()
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 채팅방 선택시
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                myHeartListSegue.perform()
            }else {
                if let cell = tableView.cellForRow(at: indexPath) as? VoiceChatChannelCell, let voiceChatRoomModel = cell.voiceChatRoomModel {
                    cell.newLabel.isHidden = true
                    chatSegue.performWithSender(sender: DViewModel<VoiceChatRoomModel>(voiceChatRoomModel))
                }
            }
        }
    }
}

extension VoiceChatRoomViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return 1
            case 1: // cards
                if let count = _app.voiceChatRoomViewModel.model?.count , count != 0 {
                    return count + 1
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
            return tableView.dequeueReusableCell(withIdentifier: "ChatInfoCell")!
        case 1:
            if let c = _app.voiceChatRoomViewModel.model?.count, c > 0, indexPath.row > 0 {
                print("ChannelCell")
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelCell") as! VoiceChatChannelCell
                if let channel = _app.voiceChatRoomViewModel.model?[indexPath.row - 1] {
                    cell.voiceChatRoomModel = channel
                    cell.setProfileImage(imageUrl: channel.largeImageUrl)
                }
                return cell
            } else {
                if let l = _app.voiceChatRoomViewModel.myChatList , l.count > 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MyVoiceChatChannelCell") as! MyVoiceChatChannelCell
                    if let channel = _app.voiceChatRoomViewModel.myChatList?.first {
                        cell.voiceChatRoomModel = channel
                        cell.setProfileImage(imageUrl: channel.profileImageUrl)
                        cell.heartCount = _app.voiceChatRoomViewModel.myReceivedHeartCount
                        cell.chatCount = _app.voiceChatRoomViewModel.myVoiceChatListCount
                    }
                    return cell
                    
                }
                
                if _app.voiceChatRoomViewModel.model?.count == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ChatEmptyCell") as! VoiceChatRoomEmptyCell
                    return cell
                }
            }
        default:()
        }
        
        return UITableViewCell()
    }
}

//extension VoiceChatRoomViewController: ApiReloadable {
//    func reloadApi() {
//        
//        _app.voiceChatRoomViewModel.reloadWithLoadingViewModel(_app.loadingViewModel)
//        
//        // 나를 좋아요로 응답해야할 카드 수 확인
//        let responseViewModel = ApiResponseViewModelBuilder<CardListNotificationModel>(successHandler: { [weak self] (cardListNotificationModel) -> Void
//            in
//            self?.cardListNotificationModel.model = cardListNotificationModel
//            }).viewModel
//        _app.api.cardListNotification(responseViewModel, loadingViewModel: _app.loadingViewModel)
//    }
//}
//
//extension VoiceChatRoomViewController {
//    func pulldown(sender: AnyObject?) {
//        reloadApi()
//    }
//}
