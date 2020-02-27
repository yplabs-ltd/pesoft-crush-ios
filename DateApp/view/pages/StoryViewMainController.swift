//
//  StoryViewMainController.swift
//  DateApp
//
//  Created by Yang Hyeon Gyu on 2017. 3. 5..
//  Copyright © 2017년 iflet.com. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

class StoryViewMainController : UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    private var promotionNewRecordVoiceSegue: DSegue!
    private var newRecordVoiceSegue: DSegue!
    private var replyRecordVoiceSegue: DSegue!
    private var reportBadVoiceSegue: DSegue!
    private var profileRequireSegue: DSegue!
    private var top10Segue: DSegue!
    private var confirmWaitingSegue: DSegue!
    private var goVoiceChatRoomSegue: DSegue!
    private var openProfileSegue: DSegue!
    private var moveToProfile: DSegue!
    private var promotionSegue: DSegue!
    
    private var freeChattingConfirmSegue: DSegue!
    private var moreChattingConfirmSegue: DSegue!
    private var askPayReplyConfirmSegue: DSegue!
    private var shouldPlayVoice: Bool = false
    private var otherUserId: Int?
    private var otherVoiceCloudId: String?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bottomSpaceOfButtonBGView: NSLayoutConstraint!
    @IBOutlet weak var newLabel: UILabel!
    override func viewDidLoad() {
        _app.userDefault.isTriedProtionUserEvent = false
        super.viewDidLoad()
        newLabel.isHidden = true
        newLabel.layer.cornerRadius = 18 / 2
        newLabel.layer.masksToBounds = true
        
        _ = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillEnterForeground, object: nil, queue: OperationQueue.main) {
            [unowned self] notification in
            
            self.updateRippleLayer()
            self.animateBottomBGView(direction: .Down)
        }
        
        promotionSegue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "ConfirmPopupController") as! ConfirmPopupController
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: 172.0)
            })
            
            destination.line1 = ("새 이야기를 시작하시면 오늘 접속한", .Title)
            destination.line2 = ("우수 회원 세분을 Today에서", .Title)
            destination.line3 = ("지금 바로 추천해드립니다!", .Title)
            destination.submit = "새 이야기 시작"
            destination.cancel = "닫기"
            destination.submitHandler = { (popup: UIViewController) -> Void in
                popup.dismiss(animated:true, completion: { () -> Void in
                    self!.promotionNewRecordVoiceSegue.perform()
                })
                
            }
            return (destination, style)
            })
        
        // profile segue
        top10Segue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "TopRankListViewController")
            let style = DSegueStyle.Show(animated: true)
            return (destination, style)
        })
        
        moveToProfile = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "CardDetailViewController")
            (destination as! CardDetailViewController).targetUserId = _app.userVoiceOneViewModel.model?.userId
            let style = DSegueStyle.Show(animated: true)
            return (destination, style)
        })
        
        openProfileSegue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "ConfirmPopupController") as! ConfirmPopupController
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: 172.0)
            })
            destination.line1 = ("상대방의 프로필을 보시겠습니까?", .Title)
            destination.line2 = ("프로필을 본후에 좋아요를 보내지 않으면\n해당 이성과 다시 매칭될 가능성이 낮습니다.", .Red)
            destination.line3 = ("1버찌 필요", .Red)
            destination.submit = "네"
            destination.cancel = "아니오"
            destination.submitHandler = { (popup: UIViewController) -> Void in
                popup.dismiss(animated:true, completion: { () -> Void in
                    guard let id = _app.userVoiceOneViewModel.model?.userId else { return }
                    
                    let responseViewModel = DViewModel<ApiResponse>(self, { [weak self] (model, oldModel) -> () in
                        guard let apiResponse = model else {
                            return
                        }
                        if apiResponse.statusCode == 200 {
                            var model = _app.userVoiceOneViewModel.model
                            model?.profileOpened = true
                            _app.userVoiceOneViewModel.model = model
                            self!.tableView.reloadData()
                            self!.moveToProfile.perform()
                        }})
                    
                    let _ = _app.api.openVoiceProfile(targetUserId: id, apiResponseViewModel: responseViewModel, loadingViewModel: nil)
                })
            }
            return (destination, style)
            })
        
        reportBadVoiceSegue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "ConfirmPopupController") as! ConfirmPopupController
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: 172.0)
            })
            destination.line1 = ("신고하기", .Red)
            destination.line2 = ("불쾌한 음성인가요?", .Title)
            destination.line3 = ("지금 바로 신고해주세요.", .Title)
            destination.submit = "신고하기"
            destination.cancel = "취소"
            destination.submitHandler = { (popup: UIViewController) -> Void in
                popup.dismiss(animated:true, completion: { () -> Void in
                    var passVoiceModel = PassVoiceModel()
                    passVoiceModel.voiceCloudId = self?.otherVoiceCloudId
                    passVoiceModel.passType = "REPORT"
                    let _ = _app.passVoiceViewModel.passVoice(passVoiceModel: passVoiceModel, loadingViewModel: _app.loadingViewModel, completeHandler: {() -> Void in
                        _app.userVoiceOneViewModel.reload()
                    })
                })
            }
            return (destination, style)
        })
        
        promotionNewRecordVoiceSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "NewVoiceRecordPopupController") as! NewVoiceRecordPopupController
            destination.isPromotion = true
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: 470.5)
            })
            destination.popupType = .New
            return (destination, style)
        })
        
        newRecordVoiceSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "NewVoiceRecordPopupController") as! NewVoiceRecordPopupController
            
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: 448.5)
            })
            destination.popupType = .New
            return (destination, style)
        })
        
        replyRecordVoiceSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "NewVoiceRecordPopupController") as! NewVoiceRecordPopupController
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: 448.5)
            })
            destination.popupType = .FirstReply
            
            destination.otherUserId = self.otherUserId
            destination.otherVoiceCloudId = self.otherVoiceCloudId
            return (destination, style)
        })
        
        goVoiceChatRoomSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "VoiceChatRoomViewController")
            let style = DSegueStyle.Show(animated: true)
            return (destination, style)
        })
    
        _app.userVoiceOneViewModel.bind (view: self) { [weak self] (model, oldModel) -> () in
            self?.tableView.reloadData()
            
            guard let userVoiceOneModel = model else {
                return
            }
            
            if userVoiceOneModel.userId != nil {
                self?.otherUserId = userVoiceOneModel.userId
                self?.otherVoiceCloudId = userVoiceOneModel.voiceCloudId
            }
        }
        
        profileRequireSegue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "FillProfileInformationViewController")
            let style = DSegueStyle.Show(animated: true)
            return (destination, style)
        })
        
        confirmWaitingSegue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "ConfirmWaitingViewController")
            let style = DSegueStyle.Show(animated: true)
            return (destination, style)
        })
        
        moreChattingConfirmSegue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "ConfirmPopupController") as! ConfirmPopupController
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: 172.0)
            })
            
            destination.line1 = ("새로운 이야기를 올리시겠습니까?", .Title)
            destination.line2 = ("5버찌가 사용됩니다.", .Title)
            destination.line3 = ("(상대방은 무료로 답장할 수 있습니다.)", .Title)
            destination.submitHandler = { (popup: UIViewController) -> Void in
                
                popup.dismiss(animated:true, completion: { () -> Void in
                    self?.newRecordVoiceSegue.perform()
                })
            }
            return (destination, style)
            })
        
        freeChattingConfirmSegue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "ConfirmPopupController") as! ConfirmPopupController
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: 172.0)
            })
            
            destination.line1 = ("새로운 이야기를 올리시겠습니까?", .Title)
            destination.line2 = ("지금 올리시면 1버찌를 드립니다!", .Red)
            destination.line3 = ("(상대방은 무료로 답장할 수 있습니다.)", .Title)
            destination.submitHandler = { (popup: UIViewController) -> Void in
                
                popup.dismiss(animated:true, completion: { () -> Void in
                    self?.newRecordVoiceSegue.perform()
                })
            }
            return (destination, style)
            })
        
        askPayReplyConfirmSegue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "ConfirmPopupController") as! ConfirmPopupController
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: 172.0)
            })
            
            destination.line1 = ("답장을 보내시겠습니까?", .Title)
            destination.line2 = ("첫 답장에만 5버찌가 사용됩니다.", .Title)
            destination.line3 = ("(상대방은 무료로 답장할 수 있습니다.)", .Red)
            destination.submitHandler = { (popup: UIViewController) -> Void in
                
                popup.dismiss(animated:true, completion: { () -> Void in
                    self?.replyRecordVoiceSegue.perform()
                })
            }
            return (destination, style)
            })
        
        _app.userVoiceOneViewModel.model = nil
        _app.userVoiceOneViewModel.reload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        checkIsNewChat()
        updateRippleLayer()
    }
    
    func updateRippleLayer() {
        tableView.visibleCells.forEach({ (cell) in
            if let novoiceCell = cell as? StoryNoVoiceCell {
                novoiceCell.setRippleLayer()
            }
        })
    }
    
    func checkIsNewChat() {
        _app.voiceChatRoomViewModel.bind (view: self) { [weak self] (model, oldModel) -> () in
            if let wself = self {
                if let chatModels = _app.voiceChatRoomViewModel.model {
                    for viewModel in chatModels {
                        if let isNew = viewModel.isNew , isNew == true {
                            wself.newLabel.isHidden = false
                            return
                        }
                    }
                    
                    wself.newLabel.isHidden = true
                }
            }
        }

        _app.voiceChatRoomViewModel.model = []
        _app.voiceChatRoomViewModel.reload()
    }
    
    func checkPass5Minute() -> Bool {
        guard let uploadVoiceTime = UserDefault().uploadVoiceTime else {
            return true
        }
        
        let currentTime = NSDate().timeIntervalSince1970
        if currentTime - uploadVoiceTime > 5 * 60 {
            return true
        }
        
        let title = "알림"
        let message = "새로운 이야기는 5분에 하나씩만\n보낼 수 있어요.\n잠시 후 다시 시도해주세요."
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
        
        return false
    }
    
    @IBAction func openProfile() {
        if _app.userVoiceOneViewModel.model?.profileOpened == true {
            moveToProfile.perform()
        }else {
            openProfileSegue.perform()
        }
    }
    
    @IBAction func goTop10(sender: AnyObject) {
        top10Segue.perform()
    }
    
    
    @IBAction func goVoiceChatRoom(sender: AnyObject) {
        if _app.sessionViewModel.model?.status == .Normal {
            goVoiceChatRoomSegue.perform()
        } else {
            if _app.sessionViewModel.model?.status == .Waiting {
                alert(title: "프로필 승인 대기중입니다.", message: "서비스를 이용하기 위해선 프로필 승인이 완료되어야 합니다.")
                return
            }
            
            confirm(title: "프로필 입력화면으로 이동합니다.", message: "서비스를 이용하기 위해선 추가 회원정보를 입력해야 합니다", handler: { [weak self] (action) -> Void in
                self?.profileRequireSegue.perform()
                })
        }
    }
    
    @IBAction func reply(sender: AnyObject) {
        if _app.sessionViewModel.model?.status == .Normal {
            if _app.sessionViewModel.model?.gender == "M" {
                askPayReplyConfirmSegue.perform()
            } else {
                replyRecordVoiceSegue.perform()
            }
        } else {
            if _app.sessionViewModel.model?.status == .Waiting {
                alert(title: "프로필 승인 대기중입니다.", message: "서비스를 이용하기 위해선 프로필 승인이 완료되어야 합니다.")
                return
            }
            
            confirm(title: "프로필 입력화면으로 이동합니다.", message: "서비스를 이용하기 위해선 추가 회원정보를 입력해야 합니다", handler: { [weak self] (action) -> Void in
                self?.profileRequireSegue.perform()
            })
        }
    }
    
    @IBAction func newVoiceRecord(sender: AnyObject) {
        guard checkPass5Minute() else {
            return
        }
        
        if _app.userDefault.isTriedProtionUserEvent == false {
            if _app.sessionViewModel.model?.gender == "F" {
                let responseViewModel = ApiResponseViewModelBuilder<PromotionValidUser>(successHandlerWithDefaultError: { (model) -> Void in
                    _app.userDefault.isTriedProtionUserEvent = true
                    if model.recipient == true {
                        self.promotionSegue.perform()
                    }else {
                        self.executeNewVoiceRecord()
                    }
                }).viewModel
                let _ = _app.api.promotionValid(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
            }else {
                executeNewVoiceRecord()
            }
        }else {
            executeNewVoiceRecord()
        }
    }
    
    func executeNewVoiceRecord() {
        if _app.sessionViewModel.model?.status == .Normal {
            if _app.sessionViewModel.model?.gender == "M" {
                let responseViewModel = ApiResponseViewModelBuilder<ServerDefaultResponseModel>(successHandlerWithDefaultError: { [weak self] (response) -> Void in
                    if let isFree = response.json?["free"].bool , isFree == false {
                        self?.moreChattingConfirmSegue.perform()
                    }else {
                        self?.freeChattingConfirmSegue.perform()
                    }}).viewModel
                let _ = _app.api.checkNewVoiceUpload(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
            } else {
                newRecordVoiceSegue.perform()
            }
        } else {
            if _app.sessionViewModel.model?.status == .Waiting {
                alert(title: "프로필 승인 대기중입니다.", message: "서비스를 이용하기 위해선 프로필 승인이 완료되어야 합니다.")
                return
            }
            
            confirm(title: "프로필 입력화면으로 이동합니다.", message: "서비스를 이용하기 위해선 추가 회원정보를 입력해야 합니다", handler: { [weak self] (action) -> Void in
                self?.profileRequireSegue.perform()
                })
        }
    }
    
    @IBAction func reportBadVoice(sender: AnyObject) {
        if _app.sessionViewModel.model?.status == .Normal {
            reportBadVoiceSegue.perform()
        } else {
            if _app.sessionViewModel.model?.status == .Waiting {
                alert(title: "프로필 승인 대기중입니다.", message: "서비스를 이용하기 위해선 프로필 승인이 완료되어야 합니다.")
                return
            }
            
            confirm(title: "프로필 입력화면으로 이동합니다.", message: "서비스를 이용하기 위해선 추가 회원정보를 입력해야 합니다", handler: { [weak self] (action) -> Void in
                self?.profileRequireSegue.perform()
            })
        }
    }
    
    @IBAction func passedVoice(sender: AnyObject) {
        if _app.userDefault.isTriedProtionUserEvent == false {
            if _app.sessionViewModel.model?.gender == "F" {
                let responseViewModel = ApiResponseViewModelBuilder<PromotionValidUser>(successHandlerWithDefaultError: { (model) -> Void in
                    _app.userDefault.isTriedProtionUserEvent = true
                    if model.recipient == true {
                        self.promotionSegue.perform()
                    }
                }).viewModel
                let _ = _app.api.promotionValid(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
            }
        }
        
        if _app.sessionViewModel.model?.status == .Normal {
            var passVoiceModel:PassVoiceModel = PassVoiceModel()
            passVoiceModel.voiceCloudId = self.otherVoiceCloudId

            _app.passVoiceViewModel.passVoice(passVoiceModel: passVoiceModel, loadingViewModel: _app.loadingViewModel, completeHandler: {
                [weak self] in
                if let wself = self {
                    wself.stopPlayer()
                    _app.userVoiceOneViewModel.reloadWithCompletion(completion: {
                        [weak self] in
                        if let wself = self {
                            wself.shouldPlayVoice = true
                        }
                    })
                }
            })
        } else {
            if _app.sessionViewModel.model?.status == .Waiting {
                alert(title: "프로필 승인 대기중입니다.", message: "서비스를 이용하기 위해선 프로필 승인이 완료되어야 합니다.")
                return
            }
            
            confirm(title: "프로필 입력화면으로 이동합니다.", message: "서비스를 이용하기 위해선 추가 회원정보를 입력해야 합니다", handler: { [weak self] (action) -> Void in
                self?.profileRequireSegue.perform()
            })
        }
    }
    
    func stopPlayer() {
        for cell in tableView.visibleCells {
            if cell is StoryReplyCell {
                (cell as! StoryReplyCell).stop()
            }
        }
    }
    
    func animateBottomBGView(direction: ScrollDirection){
        var bottomSpace: CGFloat = 0
        if direction == ScrollDirection.Up {
            bottomSpace = -45
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut,
                                   animations: {
                                    [weak self] in
                                    if let wself = self {
                                        wself.bottomSpaceOfButtonBGView.constant = bottomSpace
                                        wself.view.layoutIfNeeded()
                                    }
            },  completion:nil)
    }
}

extension Double { /// Rounds the double to decimal places value 
    func roundToPlaces(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension StoryViewMainController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 38
        case 1:
            return UIScreen.main.bounds.height - 102 - 45
        default:
            return 0
        }
    }
}

extension StoryViewMainController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1: // voice chat
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "StoryInfoCell") as! StoryInfoCell
            return cell
        case 1:
            if _app.userVoiceOneViewModel.model?.userId == nil {
                let cell = tableView.dequeueReusableCell(withIdentifier: "StoryNoVoiceCell") as! StoryNoVoiceCell
                cell.setRippleLayer()
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "StoryReplyCell") as! StoryReplyCell
                cell.adjustFrame()
                cell.onMoveToProfile = { [weak self] in
                    guard let wself = self else { return }
                    wself.profileRequireSegue.perform()
                }
                if let userVoiceOneModel = _app.userVoiceOneViewModel.model {
                    cell.userVoiceOneModel = userVoiceOneModel
                }
                
                if shouldPlayVoice {
                    shouldPlayVoice = false
                    cell.play()
                }
                return cell
            }
        default:
            fatalError()
        }
    }
    
}
