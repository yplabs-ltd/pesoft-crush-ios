//
//  MenuViewController.swift
//  DateApp
//
//  Created by ryan on 12/12/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit

class MenuViewController: UITableViewController, CenterViewControllerRequired {
    
    @IBOutlet weak var profileImageViewContainer: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var heartCountImageView: UIImageView!
    @IBOutlet weak var heartCountLabel: UILabel!
    @IBOutlet weak var refillCountImageView: UIImageView!
    @IBOutlet weak var refillCountLabel: UILabel!
    
    
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var newEventImageView: UIButton!
    
    
    var centerViewController: UIViewController!
    var noticeId: Int?
    
    private var profileSegue: DSegue!
    private var purchaseSegue: DSegue!
    private var inviteSegue: DSegue!
    private var replyEventSegue: DSegue!
    private var configSegue: DSegue!
    private var noticeSegue: DSegue!
    
    private var approvedAt: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guardForRequiredParameter()
        
        newEventImageView.layer.cornerRadius = 7
        newEventImageView.layer.masksToBounds = true
        newEventImageView.isHidden = true
        
        profileImageViewContainer.makeCircleImageContainerWithBorder(borderWidth: 1.0, borderColor: UIColor(rgba: "#e5e3e3"))
        heartCountImageView.makeCircleStyleWithBorder(borderWidth: 1.0, borderColor: UIColor(rgba: "#f35c48"))
        heartCountLabel.makeHCircleStyle()
        refillCountImageView.makeCircleStyleWithBorder(borderWidth: 1.0, borderColor: UIColor(rgba: "#726763"))
        refillCountLabel.makeHCircleStyle()
        
        // member prfile 정보
        if let member = _app.sessionViewModel.model {
            
            if member.status == .Preview {
                nameLabel.text = "프로필을 입력해주세요"
            } else if member.status == .Waiting {
                nameLabel.text = "프로필 심사중입니다."
            } else {
                nameLabel.text = member.name
            }
            
            if let mainImage = member.mainImage {
                profileImageView.image = mainImage
            }
        }
        
        // 현재 하트 갯수 어디선가 업데이트되는 상황
        _app.sessionViewModel.bind (view: self) { [weak self] (model, oldModel) -> () in
            guard let member = model else {
                return
            }
            if let point = member.point {
                self?.heartCountLabel.text = "\(point)개"
            }
        }
        
        // segue
        
        profileSegue = DSegue(source: centerViewController, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Profile", identifier: "ProfileViewController")
            let style = DSegueStyle.Show(animated: true)
            return (destination, style)
        })
        purchaseSegue = DSegue(source: centerViewController, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Shop", identifier: "ShopViewController")
            (destination as! ShopViewController).expiredDttm = self.approvedAt
            let style = DSegueStyle.Show(animated: true)
            return (destination, style)
        })
        inviteSegue = DSegue(source: centerViewController, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "FreeShop", identifier: "InviteFriendsViewController")
            let style = DSegueStyle.Show(animated: true)
            return (destination, style)
        })
        replyEventSegue = DSegue(source: centerViewController, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "FreeShop", identifier: "ReplyEventViewController")
            let style = DSegueStyle.Show(animated: true)
            return (destination, style)
        })
        configSegue = DSegue(source: centerViewController, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            var destination: UIViewController!
            var style: DSegueStyle!
            if _app.userDefault.facebookAuthToken != nil {
                destination = UIViewController.viewControllerFromStoryboard(name: "Etc", identifier: "ConfigTableViewController")
                style = DSegueStyle.Show(animated: true)
            }else {
                destination = UIViewController.viewControllerFromStoryboard(name: "Etc", identifier: "Config2TableViewController")
                style = DSegueStyle.Show(animated: true)
            }
            
            return (destination, style)
        })
        noticeSegue = DSegue(source: centerViewController, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Etc", identifier: "NoticeViewController")
            let style = DSegueStyle.Show(animated: true)
            return (destination, style)
        })
        
        // 버찌수 보여줘야함
        _app.sessionViewModel.reloadMemberInfo()
        eventImageView.isHidden = true
    }
    
    deinit {
        print(#function, "\(self)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _app.ga.trackingViewName(viewName: .drawer)
        checkShowNewNotice()
        
        let responseViewModel = ApiResponseViewModelBuilder<MemberModel>(successHandler: { [weak self] (memberModel) -> Void in
            self!.checkShowEventImage(approvedAt: memberModel.approvedAt)
            }).viewModel
        let _ = _app.api.myInfo(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkShowNewNotice() {
        let responseViewModel = ApiResponseViewModelBuilder<NewNoticeModel>(successHandlerWithDefaultError: { (model) -> Void in
            self.noticeId = model.id
            self.newEventImageView.isHidden = true
            if let id = model.id, let nId = _app.userDefault.newNoticeId {
                self.newEventImageView.isHidden = !(id > nId)
            }
        }).viewModel
        let _ = _app.api.checkNewNotice(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
    }
    
    func checkShowEventImage(approvedAt: Date? = nil) {
        eventImageView.isHidden = true
        self.approvedAt = approvedAt
        guard let a = approvedAt else { return }
        
        let exp = Date(timeInterval: 259200, since: a)
        let interval = Date().timeIntervalSince(exp)
        if let elapse = String.stringDayHourMinFromTimeInterval(interval: interval, expireDate: exp) , elapse.length > 0 {
            eventImageView.isHidden = false
        }
    }

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = super.tableView(tableView, heightForRowAt: indexPath)
        
        if indexPath.row == 3 {
            var margin: CGFloat = 150 + 130 + 125
            if getScreenSize().width == 320 {
                margin = 150 + 130
            }
            height = getScreenSize().height - margin
        }
        
        return height
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            // profile 편집 화면
            profileSegue.perform()
            dismiss(animated: false, completion: nil)
        case 1:
            // 충전
            purchaseSegue.perform()
            dismiss(animated: false, completion: nil)
        case 2:
            // 하트무료받기
            
            let responseViewModel = ApiResponseViewModelBuilder<NextDttmModel>(successHandlerWithDefaultError: { [weak self] (nextDttmModel) -> Void in
                guard let nextDttm = nextDttmModel.nextDttm else {
                    return
                }
                let interval = NSDate().timeIntervalSince(nextDttm)
                if 0 <= interval {
                    // nextDttm 이 과거면 sms 초대 화면
                    self?.inviteSegue.perform()
                } else {
                    // 아니면 댓글 이벤트
                    let param: [String:AnyObject] = ["nextDttm":nextDttm as AnyObject]
                    self?.replyEventSegue.performWithSender(sender: param as AnyObject)
                }

                self?.dismiss(animated:false, completion: nil)
                }).viewModel
            let loadingViewModel = LoadingViewModelBuilder(superview: refillCountImageView).viewModel
            let _ = _app.api.pointSmsInviteCheck(apiResponseViewModel: responseViewModel, loadingViewModel: loadingViewModel)
            
        default:
            break
        }
    }

    @IBAction func notice(sender: AnyObject) {
        _app.userDefault.newNoticeId = noticeId
        noticeSegue.perform()
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func help(sender: AnyObject) {
        guard let userId = _app.sessionViewModel.model?.id else {
            return
        }
        confirm(title: "문의사항보내기를 위하여 이메일앱으로 연결합니다.") { [weak self] (action) -> Void in
            self?.dismiss(animated:false) { () -> Void in
                let body =
                    "\n\n\n\n" +
                    "--------------------------------\n" +
                    "ios,\(userId)\n" +
                    "*주의: 위의 문자는 문제를 해결하기위해 필요한 정보입니다. 지우지 마세요.\n" +
                    "--------------------------------\n"
                _app.delegate.openEmailAppToMasterWithSubject(subject: "그당반 문의사항이 있습니다.", body: body)
            }
        }
    }
    @IBAction func config(sender: AnyObject) {
        configSegue.perform()
        dismiss(animated: false, completion: nil)
    }
}
