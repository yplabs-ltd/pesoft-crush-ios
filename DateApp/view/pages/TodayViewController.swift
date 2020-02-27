//
//  TodayViewController.swift
//  DateApp
//
//  Created by ryan on 12/13/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit

enum ScrollDirection {
    case Up
    case Down
}

class TodayViewController: UIViewController {
    @IBOutlet weak var recommendTodayCard: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var bottomSpaceOfButtonBGView: NSLayoutConstraint!
    @IBOutlet var locationButton: UIButton!
    @IBOutlet var recommendButton: UIButton!
    @IBOutlet weak var middelLineView: UIView!
    @IBOutlet var randomButton: UIButton!
    @IBOutlet var bottomButton: UIButton!
    @IBOutlet var topRemainTimeLabel: UILabel!
    @IBAction func detail(sender: AnyObject) {
        
        if _app.sessionViewModel.model?.status == .Normal {
            detailSegue.performWithSender(sender: sender)
        } else {
            if _app.sessionViewModel.model?.status == .Waiting {
                alert(title: "프로필 승인 대기중입니다.", message: "상대방에게 호감을 표현하기 위해서는 프로필 승인이 완료되어야 합니다.")
                return
            }
            
            confirm(title: "프로필 입력화면으로 이동합니다.", message: "상대방에게 호감을 표현하기 위해선 추가 회원정보를 입력해야 합니다.", handler: { [weak self] (action) -> Void in
                self?.profileSegue.perform()
                })
        }
    }
    private var directionOfScroll : ScrollDirection!
    private var scrollBounce: Bool = false
    private var preContentOffsetY: CGFloat = 0
    private var moreButton: UIButton!
    private var profileSegue: DSegue!
    private var moreConfirmSegue: DSegue!
    private var topTenConfirmSegue: DSegue!
    private var moreLocationConfirmSegue: DSegue!
    private var detailSegue: DSegue!
    private var promotionSegue: DSegue!
    private var approvedAt: Date?
    
    var noticePopupSegue: DSegue!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        bottomButton.layer.cornerRadius = bottomButton.frame.size.height / 2
        recommendButton.layer.cornerRadius = recommendButton.frame.size.height / 2
        recommendButton.layer.borderWidth = 1
        recommendButton.layer.borderColor = UIColor(red: 236/255, green: 82/255, blue: 66/255, alpha: 1.0).cgColor

        
        tableView.tableFooterView = UIView(frame: CGRect.zero)   // 내용없는 셀 표시 안함
        tableView.alwaysBounceVertical = true
        tableView.bounces = true
        
        checkShowNotice()
        
        // 소개 더 받기 버튼
        /*
        moreButton = UIButton(frame: CGRect(x: 0,0,185,40))
        moreButton.backgroundColor = UIColor(rgba: "#f2503b")
        moreButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        moreButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        moreButton.setTitle("소개 더 받기", for: UIControlState.normal)
        moreButton.makeHCircleStyle()
        moreButton.addTarget(self, action: Selector("more:"), forControlEvents: UIControlEvents.touchUpInside)
        view.addSubview(moreButton)
        */
        
        // viewmodel
        
        _app.todayCardsViewModel.bind (view: self) { [weak self] (model, oldModel) -> () in
            self?.enableTodaRecommendCardView(isEnable: false)
            if model?.count == 0 || model == nil {
                self?.enableTodaRecommendCardView(isEnable: true)
            }
            self?.middelLineView.isHidden = false
            self?.tableView.reloadData()
            self?.setLocationLabelTitle()
        }
        // segue
        profileSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            // 프로필 입력창으로 이동
            let destination = UIViewController.viewControllerFromStoryboard(name: "Profile", identifier: "ProfileViewController")
            let style = DSegueStyle.Show(animated: true)
            return (destination, style)
        })
        
        promotionSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Shop", identifier: "ShopViewController")
            (destination as! ShopViewController).expiredDttm = self.approvedAt
            let style = DSegueStyle.Show(animated: true)
            return (destination, style)
        })
        moreConfirmSegue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "ConfirmPopupController") as! ConfirmPopupController
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: 172.0)
            })
            destination.line1 = ("한번 더 소개받으실래요?", .Title)
            destination.line2 = ("최근 접속한 이성 세분이 소개됩니다.", .Title)
            destination.line3 = ("30버찌 필요", .Red)
            destination.submitHandler = { (popup: UIViewController) -> Void in
                popup.dismiss(animated:true, completion: { () -> Void in
                    _app.todayCardsViewModel.more()
                    self?.tableView.setContentOffset(CGPoint.zero, animated: true)
                })
                
                _app.ga.trackingEventCategory(category:"today", action: "today_more", label: "confirm")
            }
            return (destination, style)
        })
        
        topTenConfirmSegue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "ConfirmPopupController") as! ConfirmPopupController
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: 172.0)
            })
            
            if let member = _app.sessionViewModel.model {
                if member.gender == "F" {
                    destination.line1 = ("우수 회원들을", .Title)
                }
                else {
                    destination.line1 = ("상위 10% 이성들을", .Title)
                }
            }
            destination.line2 = ("한번 더 소개받으시겠어요?", .Title)
            destination.line3 = ("30버찌 필요", .Red)
            destination.submitHandler = { (popup: UIViewController) -> Void in
                popup.dismiss(animated:true, completion: { () -> Void in
                    _app.todayCardsViewModel.more() 
                    self?.tableView.setContentOffset(CGPoint.zero, animated: true)
                })
                
                _app.ga.trackingEventCategory(category:"today", action: "today_more", label: "confirm")
            }
            return (destination, style)
        })

        moreLocationConfirmSegue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "ConfirmPopupController") as! ConfirmPopupController
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: 172.0)
            })
            
            var locationStr = "근처 지역 이성들을"
            if let member = _app.sessionViewModel.model {
                if let locationName = member.hometown?.value {
                    locationStr = String(format: "%@ 지역 이성들을", locationName)
                }
            }
            
            destination.line1 = (locationStr, .Title)
            destination.line2 = ("한번 더 소개받으시겠어요?", .Title)
            destination.line3 = ("30버찌 필요", .Red)
            destination.submitHandler = { (popup: UIViewController) -> Void in
                popup.dismiss(animated:true, completion: { () -> Void in
                    _app.todayCardsViewModel.moreLocation()
                    self?.tableView.setContentOffset(CGPoint.zero, animated: true)
                })
                
                _app.ga.trackingEventCategory(category:"today", action: "today_more", label: "confirm")
            }
            return (destination, style)
            })
        
        detailSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "CardDetailViewController")
            let style = DSegueStyle.Show(animated: true)
            return (destination, style)
        })
        
        // today 리스트 reload
        _app.todayCardsViewModel.model = nil
        _app.todayCardsViewModel.reload()
    }
    
    func checkShowPromotionPopup(approvedAt: Date? = nil) {
        self.approvedAt = approvedAt
        
        guard let a = approvedAt else { return }
        
        let calendar = NSCalendar.current
        
        let date1 = calendar.startOfDay(for: a)
        let date2 = calendar.startOfDay(for: Date())
        
        
        let components = calendar.dateComponents([.day], from: date1, to: date2)

        if let d = components.day, d < 3 {
            _app.userDefault.isShowedPromotionPopup = true
            let titleStyle = LabelStyle(font: UIFont.systemFont(ofSize: 15), normalColor: UIColor(rgba: "#736763"), highlightColor: nil)
            let messagStyle = LabelStyle(font: UIFont.systemFont(ofSize: 15), normalColor: UIColor(rgba: "#f2503b"), highlightColor: nil)
            KMPopupView().show(title: "프로필 승인이 되신 것을 축하드립니다!",
                               titleStyle: titleStyle,
                               message: "신규 가입 기념으로 3일동안\n버찌 프로모션 이벤트가 진행됩니다!\n지금 이벤트르르 보러 가실래요?\n\n버찌 충전하러 가기에서 보실 수 있어요!",
                               messageStyle: messagStyle,
                               otherButtonTitle: "닫기",
                               okButtonTitle: "보러가기",
                               otherButtonAction: {},
                               confirmAction: { [weak self] text in
                                guard let wself = self else { return }
                                print("tapped")
                                wself.promotionSegue.perform()
                })
        }
    }
    
    func checkShowPromotionAlert() {
        guard _app.userDefault.isShowedPromotionPopup == false else { return }
        let responseViewModel = ApiResponseViewModelBuilder<MemberModel>(successHandler: { [weak self] (memberModel) -> Void in
            _app.sessionViewModel.model = memberModel
            
            if let loginPoint = memberModel.loginPoint , loginPoint > 0 {
                _app.sessionViewModel.pointAlert = true
            }
            
            let time = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time) {
                self!.checkShowPromotionPopup(approvedAt: memberModel.approvedAt)
            }
            
            
        }).viewModel
        let _ = _app.api.myInfo(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
    }
    
    func checkShowNotice() {
        setUpNoticePopupView()
        
        if let title = _app.userDefault.noticeTitle, let message = _app.userDefault.noticeMessage {
            var isShowNoticeView: Bool = true
            if let noticeId = _app.userDefault.noticeID, let checkedNoticeId = _app.userDefault.checkedNoticeID {
                if noticeId == checkedNoticeId {
                    isShowNoticeView = false
                }
            }
            
            if isShowNoticeView {
                KMPopupView().show(title: title, message: message, otherButtonTitle: "다시 보지 않기", okButtonTitle: "닫기", otherButtonAction: {
                    let nId = _app.userDefault.noticeID
                    _app.userDefault.checkedNoticeID = nId
                    }, confirmAction: nil)
            }
        }
    }
    
    func setUpNoticePopupView() {
        noticePopupSegue = DSegue(source: self, destination: {
            [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "MultilineMessagePopupController") as! MultilineMessagePopupController
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: 372.0)
            })
            destination.useAddVoice = true
            destination.rightButtonTitle = "다시 보지 않기"
            destination.leftButtonTitle = "닫기"

            destination.titleMessage = _app.userDefault.noticeTitle!
            destination.subtitleMessage = _app.userDefault.noticeMessage!
            destination.placeholder = "어떤 부분이 마음에 들었는지 메시지를 이 곳에 적어 함께 보내 보세요"
            destination.submitHandler = { (popup) -> () in
                print(_app.userDefault.noticeID)
                _app.userDefault.checkedNoticeID = _app.userDefault.noticeID
                popup.dismiss(animated:true, completion: nil)
            }
            return (destination, style)
            })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        animateBottomBGView(direction: ScrollDirection.Down)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
    }
    
    deinit {
        print(#function, "\(self)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 가로 센터
        /*
        let x = (view.frame.size.width / 2) - (moreButton.frame.size.width / 2)
        let y = view.frame.height - moreButton.frame.height - 10
        moreButton.frame.origin = CGPointMake(x, y)
        */
    }

    func setLocationLabelTitle(){
        /*
        if let member = _app.sessionViewModel.model {
            if member.gender == "F" {
                locationButton.setTitle("우수회원 소개받기", for: UIControlState.normal)
            }
            else {
                locationButton.setTitle("상위 10% 소개받기", for: UIControlState.normal)
            }
        }*/
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? CardDetailViewController {
     
            // 선택한 셀의 id 전달 (target user id)
            if let sender = sender as? UIView , 0 <= sender.tag {
                let targetUserId = sender.tag
                if let cardModel = _app.todayCardsViewModel.cardModelFromUserId(userId: targetUserId) {
                    vc.targetUserId = cardModel.id
                    
                    if cardModel.expiredDttm?.expired() == true {
                        // 아직 expired 됐음 (오늘 소개받은 카드가 아님)
                        vc.fromType = "H" // (버찌 10개 차감)
                    } else {
                        vc.fromType = "T" // (버찌 5개 차감)
                    }
                }
            }
        }
    }
    
    func animateBottomBGView(direction: ScrollDirection){
        var bottomSpace: CGFloat = 15
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
    
    func enableTodaRecommendCardView(isEnable: Bool) {
        recommendTodayCard.isHidden = !isEnable
    }
    
    @IBAction func requestTodayRecommendCards() {
        _app.todayCardsViewModel.model = nil
        _app.todayCardsViewModel.requestTodayRecommendCards()
    }
}

extension TodayViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let c = _app.todayCardsViewModel.model?.count, c > 0 else {
            return 0
        }
        switch indexPath.section {
        case 0:
            return 19   // top margin (첫번째 마진 공간이 필요함)
        case 1: // cards
            let expiredChanged = _app.todayCardsViewModel.expiredTimeChangedOfIndex(index: indexPath.row)
            if expiredChanged {
                return 204
            }
            return 147
        case 2: // 더보기 버튼
            return 65
        default:
            return 0
        }
    }
}

extension TodayViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1: // cards
            return _app.todayCardsViewModel.model?.count ?? 0
        case 2: // buttons
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            return tableView.dequeueReusableCell(withIdentifier: "TopMarginCell")!
        case 1:
            let cardCell = tableView.dequeueReusableCell(withIdentifier: "CardCell") as! TodayCardCell
            cardCell.rowIndex = indexPath.row
            if let todayCard = _app.todayCardsViewModel.model?[indexPath.row] {
                cardCell.model = todayCard
            }
            
            let expiredChanged = _app.todayCardsViewModel.expiredTimeChangedOfIndex(index: indexPath.row)
            if expiredChanged {
                cardCell.expiredTimeHidden = false
            } else {
                cardCell.expiredTimeHidden = true
            }
            
            if indexPath.row == 0 {
                cardCell.expiredTimeHidden = true
                cardCell.updateRemainTime = {
                    elaspe in
                    print(elaspe)
                    self.topRemainTimeLabel.text = elaspe
                }
            }
            
            return cardCell
        case 2:
            let moreCell = tableView.dequeueReusableCell(withIdentifier: "MoreCell")!
            return moreCell
        default:
            fatalError()
        }
    }
}

extension TodayViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        /*
        moreButton.alpha = 0.0
        */
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
        
        /// Detect Scrolling Direction
        if scrollView.contentOffset.y > preContentOffsetY && scrollView.contentOffset.y > 0{
            directionOfScroll = .Up;
        }else{
            directionOfScroll = .Down;
        }
        
        animateBottomBGView(direction: directionOfScroll)
        
        preContentOffsetY = scrollView.contentOffset.y;
        
        let scrollOffsetY = scrollView.contentOffset.y;
        if scrollOffsetY > scrollView.contentSize.height - scrollView.frame.size.height{
            scrollBounce = true
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        /*
        UIView.animate(withDuration: 0.5) { () -> Void in
            self.moreButton.alpha = 1.0
        }
        */
    }
}

extension TodayViewController {
     
    @IBAction func more(sender: AnyObject) {
        if _app.sessionViewModel.model?.status == .Normal {
            moreConfirmSegue.perform()
            _app.ga.trackingEventCategory(category:"today", action: "today_more", label: "try")
        } else {
            if _app.sessionViewModel.model?.status == .Waiting {
                alert(title: "프로필 승인 대기중입니다.", message: "소개를 더 받기 위해선 프로필 승인이 완료되어야 합니다.")
                return
            }
            
            confirm(title: "프로필 입력화면으로 이동합니다.", message: "소개를 더 받기 위해선 추가 회원정보를 입력해야 합니다.", handler: { [weak self] (action) -> Void in
                self?.profileSegue.perform()
                })
        }
    }
    
    @IBAction func moreTopten(sender: AnyObject) {
        if _app.sessionViewModel.model?.status == .Normal {
            topTenConfirmSegue.perform()
            _app.ga.trackingEventCategory(category:"today", action: "today_more", label: "try")
        } else {
            if _app.sessionViewModel.model?.status == .Waiting {
                alert(title: "프로필 승인 대기중입니다.", message: "소개를 더 받기 위해선 프로필 승인이 완료되어야 합니다.")
                return
            }
            
            confirm(title: "프로필 입력화면으로 이동합니다.", message: "소개를 더 받기 위해선 추가 회원정보를 입력해야 합니다.", handler: { [weak self] (action) -> Void in
                self?.profileSegue.perform()
                })
        }
    }
    
    @IBAction func moreLocation(sender: AnyObject) {
        if _app.sessionViewModel.model?.status == .Normal {
            moreLocationConfirmSegue.perform()
            _app.ga.trackingEventCategory(category:"local", action: "local_more", label: "try")
        } else {
            if _app.sessionViewModel.model?.status == .Waiting {
                alert(title: "프로필 승인 대기중입니다.", message: "소개를 더 받기 위해선 프로필 승인이 완료되어야 합니다.")
                return
            }
            
            confirm(title: "프로필 입력화면으로 이동합니다.", message: "소개를 더 받기 위해선 추가 회원정보를 입력해야 합니다.", handler: { [weak self] (action) -> Void in
                self?.profileSegue.perform()
                })
        }
    }
}
