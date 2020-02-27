//
//  ReplyEventViewController.swift
//  DateApp
//
//  Created by ryan on 2/10/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import UIKit

class ReplyEventViewController: UIViewController, NextDttmRequired {
    @IBOutlet weak var inviteFriendBGView: UIView!
    @IBOutlet weak var inviteFriendDescLabel: UILabel!
    
    @IBOutlet weak var expireDateLabel: UILabel!
    @IBOutlet weak var messageContainerView: UIView!
    @IBAction func review(sender: AnyObject) {
        // 보상 10버찌 지급 하고 앱스토어 이동
        let responseViewModel = ApiResponseViewModelBuilder<PointValueModel>(successOrErrorHandler: { () -> Void in
            if let url = URL(string: _app.config.appstoreUrl) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }).viewModel
        let _ = _app.api.pointStoreReview(apiResponseViewModel: responseViewModel, loadingViewModel: nil)
    }

    var nextDttm: Date!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guardForRequiredParameter()
        
        title = "버찌 무료받기"
        let _ = messageContainerView.makeBottomBorder(borderWidth: 1.0, borderColor: UIColor(rgba: "#ecebea"))
        
        makeInviteFriendUI()
        
        _app.secondViewModel.bindThenFire (view: self) { [weak self] (model, oldModel) -> () in
            guard let nextDttm = self?.nextDttm else {
                return
            }
            
            let interval = Date().timeIntervalSince(nextDttm)
            self?.expireDateLabel.text = String.stringDDayAndTimeFromTimeInterval(interval: interval)
        }
        
        checkEnableWhichView()
        
        let _ = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillEnterForeground, object: nil, queue: OperationQueue.main) {
            [weak self] notification in
            guard let wself = self else { return }
            
            wself.checkEnableWhichView()
        }
    }
    
    deinit {
        print(#function, "\(self)")
    }
    
    func makeInviteFriendUI() {
        let attrs = [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor : UIColor(rgba: "#726763")]
        let str1 = "카톡을 통해 초대받은 친구가 가입 시\n제공된 추천 코드를 입력하면,\n가입 승인이 완료될 때\n당신과 친구 모두 "
        let str2 = "20버찌"
        let str3 = "를 드려요"
        
        let attributedString = NSMutableAttributedString(string:"\(str1)\(str2)\(str3)", attributes:attrs)
        attributedString.addAttribute(.foregroundColor, value: UIColor(rgba: "#F2503B"), range: NSMakeRange(str1.length, str2.length))
        
        inviteFriendDescLabel.attributedText = attributedString
    }
    
    func checkEnableWhichView() {
        
        guard
            let savedAppVersion = _app.userDefault.savedAppVersion , savedAppVersion == _app.userDefault.lastestAppVersion else {
                _app.userDefault.savedAppVersion = _app.userDefault.lastestAppVersion
                inviteFriendBGView.isHidden = true
                return
        }
        inviteFriendBGView.isHidden = false
    }
    
    @IBAction func onClickInviteFriend() {
        ShareManager.actionShareKakaoTalk()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _app.ga.trackingViewName(viewName: .contact)
    }
}
