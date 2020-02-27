//
//  VoiceChatViewController.swift
//  DateApp
//
//  Created by Yang Hyeon Gyu on 2017. 3. 26..
//  Copyright © 2017년 iflet.com. All rights reserved.
//

import UIKit
import AVFoundation

class VoiceChatViewController : UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate, VoiceChatRoomModelRequeired {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var replyActionButton: UIButton!
    
    private var openProfileSegue: DSegue!
    private var moveToProfile: DSegue!
    private var reportBadVoiceSegue: DSegue!
    private var replyRecordVoiceSegue: DSegue!
    private var moreChattingConfirmSegue: DSegue!
    private var replyRecordBuzzieVoiceSegue: DSegue!
    private var voiceChatRoomId: String?
    private var likeMessagePopupSegue: DSegue!
    
    var voiceChatRoomModel : VoiceChatRoomModel!
    
    private var directionOfScroll : ScrollDirection!
    private var scrollBounce: Bool = false
    private var preContentOffsetY: CGFloat = 0

    @IBOutlet weak var bottomButtonView: NSLayoutConstraint!
    
    private var isCanReportBadVoice: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guardForRequiredParameter()
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
        navigationController?.makeNavigationBarDefaultStyle()
        navigationItem.title = self.voiceChatRoomModel.name
        
        // profile segue
        moveToProfile = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "CardDetailViewController")
            (destination as! CardDetailViewController).targetUserId = self.voiceChatRoomModel.userId
            let style = DSegueStyle.Show(animated: true)
            return (destination, style)
        })
        
        likeMessagePopupSegue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "MultilineMessagePopupController") as! MultilineMessagePopupController
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: 322.0)
            })
            
            
            var buzzieMessage: String
            if _app.sessionViewModel.model?.gender == "F" {
                buzzieMessage = "무료로 보낼 수 있어요!"
            }else {
                buzzieMessage = "15버찌 필요"
            }
            destination.useAddVoice = false
            destination.containerHeight = 100
            destination.titleMessage = "상대방에게 좋아요를 보낼까요?"
            destination.subtitleMessage = "좋아요를 보내고 나면\n상대방의 프로필을\n열람하실 수 있습니다.\n\(buzzieMessage)"
            destination.placeholder = "어떤 부분이 마음에 들었는지 메시지를 이 곳에 적어 함께 보내 보세요"
            destination.submitHandler = { (popup) -> () in
                guard let userId = self?.voiceChatRoomModel.userId else { return }
                
                if _app.sessionViewModel.model?.gender == "M" {
                    if 15 > (_app.sessionViewModel.model?.point)! {
                        popup.dismiss(animated:true, completion: { () -> Void in
                            alert(title: "포인트 부족", message: "버찌가 부족합니다.")
                        })
                        
                        return
                    }
                }
                
                // 좋아요 api 호출
                let responseViewModel = DViewModel<ApiResponse>(self, { [weak self] (model, oldModel) -> () in
                    guard let apiResponse = model else {
                        return
                    }
                    if apiResponse.statusCode == 200 {
                        var profileModel = self?.voiceChatRoomModel
                        profileModel?.profileOpened = true
                        self?.voiceChatRoomModel = profileModel
                        self?.tableView.reloadData()
                        self?.moveToProfile.perform()
                        popup.dismiss(animated:true, completion: nil)
                    }else {
                        if let error = apiResponse.serverErrorModel {
                            if let title = error.title, let desc = error.description {
                                alert(title: title, message: desc)
                            }
                        }
                    }
                    })
                let _ = _app.api.cardLike(userId: userId, comment: popup.message, fromType: "V", apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
                
            }
            return (destination, style)
            })
        
        openProfileSegue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "ConfirmPopupController") as! ConfirmPopupController
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: 172.0)
            })
            destination.line1 = ("상대방의 프로필을 보시겠습니까?", .Title)
            destination.line2 = ("", .Title)
            destination.line3 = ("1버찌 필요", .Red)
            destination.submit = "네"
            destination.cancel = "아니오"
            destination.submitHandler = { (popup: UIViewController) -> Void in
                popup.dismiss(animated:true, completion: { () -> Void in
                    guard let id = self?.voiceChatRoomModel.userId else { return }
                    
                    let responseViewModel = DViewModel<ApiResponse>(self, { [weak self] (model, oldModel) -> () in
                        guard let apiResponse = model else {
                            return
                        }
                        guard self!.voiceChatRoomModel.id != nil else {
                            return
                        }
                        
                        if apiResponse.statusCode == 200 || apiResponse.statusCode == 400 {
                            var profileModel = self?.voiceChatRoomModel
                            profileModel?.profileOpened = true
                            self?.voiceChatRoomModel = profileModel
                            self?.tableView.reloadData()
                            self?.moveToProfile.perform()
                        }})
                    let _ = _app.api.openVoiceProfile(targetUserId: id, fromType: "V", apiResponseViewModel: responseViewModel, loadingViewModel: nil)
                })
            }
            return (destination, style)
            })
        
        reportBadVoiceSegue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "ConfirmPopupController") as! ConfirmPopupController
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: 192.0)
            })
            destination.line1 = ("신고하기", .Red)
            destination.line2 = ("불쾌한 음성인가요?", .Title)
            destination.line3 = ("지금 바로 신고해주세요.\n(신고하면 방은 삭제됩니다)", .Title)
            destination.submit = "신고하기"
            destination.cancel = "취소"
            destination.submitHandler = { (popup: UIViewController) -> Void in
                popup.dismiss(animated:true, completion: { () -> Void in
                    var passVoiceModel = PassVoiceModel()
                    passVoiceModel.voiceChatRoomId = self!.voiceChatRoomId
                    passVoiceModel.passType = "REPORT"
                    _app.passVoiceViewModel.passVoiceWithRoom(passVoiceModel: passVoiceModel, loadingViewModel: _app.loadingViewModel) {() -> Void in
                        self?.navigationController?.popViewController(animated: true)
                    }
                })
            }
            return (destination, style)
            })
        
        moreChattingConfirmSegue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "ConfirmPopupController") as! ConfirmPopupController
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: 172.0)
            })

            destination.line1 = ("답장을 보내시겠습니까?", .Title)
            destination.line2 = ("첫 답장에만 5버찌가 사용됩니다.", .Title)
            destination.line3 = ("(상대방은 무료로 답장할 수 있습니다.)", .Red)
            destination.submitHandler = { (popup: UIViewController) -> Void in
                
                popup.dismiss(animated:true, completion: { () -> Void in
                    /*
                    _app.voiceViewModel.replyVoiceUseBuzzie(_app.loadingViewModel) {() -> Void in
                        self?.replyRecordBuzzieVoiceSegue.perform()
                    }*/
                    self?.replyRecordBuzzieVoiceSegue.perform()
                })
            }
            return (destination, style)
        })
        
        replyRecordBuzzieVoiceSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "NewVoiceRecordPopupController") as! NewVoiceRecordPopupController
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: 448.5)
            })
            destination.popupType = .Reply
            destination.useBuzzie = true
            
            destination.voiceChatRoomId = self.voiceChatRoomId
            destination.submitHandler = { (popup: UIViewController) -> Void in
                popup.dismiss(animated:true, completion: { () -> Void in
                    _app.voiceChatViewModel.find(voiceChatRoomModel: self.voiceChatRoomModel)
                    self.tableView.reloadData()
                })
            }
            return (destination, style)
        })
        
        replyRecordVoiceSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "NewVoiceRecordPopupController") as! NewVoiceRecordPopupController
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: 448.5)
            })
            destination.popupType = .Reply
            destination.useBuzzie = false
            
            destination.voiceChatRoomId = self.voiceChatRoomId
            destination.submitHandler = { (popup: UIViewController) -> Void in
                popup.dismiss(animated:true, completion: { () -> Void in
                    _app.voiceChatViewModel.find(voiceChatRoomModel: self.voiceChatRoomModel)
                    self.tableView.reloadData()
                })
            }
            return (destination, style)
        })
        
        _app.voiceChatViewModel.bind (view: self) { [weak self] (model, oldModel) -> () in
            var voiceChatModels : [VoiceChatModel] = []
            voiceChatModels = model!
            
            if voiceChatModels.count > 0 {
                let voiceChatModel = voiceChatModels[voiceChatModels.endIndex - 1]
                self?.voiceChatRoomId = self?.voiceChatRoomModel.id
                if voiceChatModel.userId != _app.sessionViewModel.model?.id {
                    self?.replyActionButton.isUserInteractionEnabled = true
                    self?.isCanReportBadVoice = true
                    self?.replyActionButton.backgroundColor = UIColor(red: 242/255, green: 80/255, blue: 59/255, alpha: 1.0)
                } else {
                    self?.replyActionButton.isUserInteractionEnabled = false
                    self?.isCanReportBadVoice = false
                    self?.replyActionButton.backgroundColor = UIColor(red: 114/255, green: 103/255, blue: 99/255, alpha: 1.0)
                }
            }
            
            self?.tableView.reloadData()
        }
        
        _app.voiceChatViewModel.model = []
        _app.voiceChatViewModel.find(voiceChatRoomModel: voiceChatRoomModel)
        
    }
    
    deinit {
        print(#function, "\(self)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func animateReplyButton(direction: ScrollDirection){
        var bottomSpace: CGFloat = 0
        if direction == ScrollDirection.Up {
            bottomSpace = -48
        }
        
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut,
                                   animations: {
                                    [weak self] in
                                    if let wself = self {
                                        wself.bottomButtonView.constant = bottomSpace
                                        wself.view.layoutIfNeeded()
                                    }
            },  completion:nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if _app.chatViewCell.count > 0 {
            _app.chatViewCell.popLast()?.stop()
            _app.chatViewCell.removeAll()
        }
        
        animateReplyButton(direction: ScrollDirection.Down)
    }
    
    @IBAction func reportBadVoice(sender: AnyObject) {
        reportBadVoiceSegue.perform()
    }
    
    @IBAction func cellPlay(sender: AnyObject) {
        self.tableView.selectAll(sender)
    }
    
    
    @IBAction func replyAction(sender: AnyObject) {
        guard let isShowPopup = checkShowPayPopup() else {
            return
        }
        
        if isShowPopup {
            moreChattingConfirmSegue.perform()
        } else {
            let loadingViewModel = LoadingViewModelBuilder(superview: self.view).viewModel
            let responseViewModel = DViewModel<ApiResponse>(self, { [weak self] (model, oldModel) -> () in
                if let wself = self {
                    if let errorModel = model?.serverErrorModel {
                        if errorModel.code == "WrongData" {
                            // 대화 상대 없음
                            if let title = errorModel.title, let msg = errorModel.description {
                                alert(title: title, message: msg)
                            }
                            return
                        }else if errorModel.code == "ChatOpenRequired" || isShowPopup {
                            wself.moreChattingConfirmSegue.perform()
                        }
                    }
                    
                    guard let apiResponse = model?.model as? ServerDefaultResponseModel else {
                        return
                    }
                    if apiResponse.code == "OK" {
                        wself.replyRecordVoiceSegue.perform()
                        return
                    } else if apiResponse.code == "ChatOpenRequired" || isShowPopup {
                        wself.moreChattingConfirmSegue.perform()
                    }
                }
                })
            
            _app.api.checkAvailableVoiceChat(parameter: ["chatId":voiceChatRoomModel.id! as AnyObject], apiResponseViewModel: responseViewModel, loadingViewModel: loadingViewModel)
        }
    }
    
    func checkShowPayPopup() -> Bool? {
        guard let chatRooms = _app.voiceChatViewModel.model else {
            return nil
        }
        guard let myPofile = _app.sessionViewModel.model else {
            return nil
        }
        
        var myReplyCount: Int = 0
        for room in chatRooms {
            if room.userId == myPofile.id {
                myReplyCount += 1
            }
        }
        
        if myReplyCount == 0 && myPofile.gender == "M" {
            return true
        }

        return false
    }
}

extension VoiceChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: // profile
            return 302
        case 1: // chat
            return 95
        default:
            return 0
        }
    }
}

extension VoiceChatViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return 1
            case 1: // voice chat
                if let count = _app.voiceChatViewModel.model?.count {
                    return count
                } else {
                    return 0
            }	
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileChatInfoCell") as! VoiceChatProfileInfoCell
            cell.onClickProfile = { [weak self] profileOpened in
                guard let wself = self else { return }
                if profileOpened {
                    wself.moveToProfile.perform()
                }else {
                    //wself.openProfileSegue.perform()
                    wself.likeMessagePopupSegue.perform()
                }
            }
            
            cell.voiceChatRoomModel = self.voiceChatRoomModel
            cell.isCanReportBadVoice = self.isCanReportBadVoice
            cell.setProfileImage(imageUrl: voiceChatRoomModel.largeImageUrl)
            return cell
        case 1:
            if let count = _app.voiceChatViewModel.model?.count, 0 < count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "VoiceChatCell") as! VoiceChatCell
                if let channel = _app.voiceChatViewModel.model?[indexPath.row] {
                    cell.voiceChatModel = channel
                }
                return cell
            } else {
                return tableView.dequeueReusableCell(withIdentifier: "")!
            }
        default:
            fatalError()
        }
    }
    
}

extension VoiceChatViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
        
        /// Detect Scrolling Direction
        if scrollView.contentOffset.y > preContentOffsetY && scrollView.contentOffset.y > 0{
            directionOfScroll = .Up;
        }else{
            directionOfScroll = .Down;
        }
        
        animateReplyButton(direction: directionOfScroll)
        
        preContentOffsetY = scrollView.contentOffset.y;
        
        let scrollOffsetY = scrollView.contentOffset.y;
        if scrollOffsetY > scrollView.contentSize.height - scrollView.frame.size.height{
            scrollBounce = true
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

    }
}
