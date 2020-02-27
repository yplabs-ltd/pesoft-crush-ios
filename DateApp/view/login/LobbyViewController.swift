//
//  LoginViewController.swift
//  DateApp
//
//  Created by ryan on 12/26/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit

class LobbyViewController: UIViewController {

    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var birdImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.makeNavigationBarTransparentStyle()
        
        registerButton.makeHCircleStyle()
        facebookButton.makeHCircleStyle()
        
        // 밑줄 달린 회원로그인 버튼

        let attributedString = NSMutableAttributedString(string:"회원 로그인", attributes:[.font : UIFont.systemFont(ofSize: 14.0), .foregroundColor : UIColor(rgba: "#726763"), kCTUnderlineStyleAttributeName as NSAttributedStringKey : 1])
        loginButton.setAttributedTitle(attributedString, for: .normal)
        
        // 새 애니메이션
        birdImageView.animationDuration = 0.5
        birdImageView.animationImages = UIImage.birdFrames
        birdImageView.startAnimating()
        
        // viewmodel 초기화
        _app.cardDetailViewModel.model = nil
        _app.profileViewModel.model = nil
        _app.evaluationCardsViewModel.model = nil
        _app.historiesViewModel.model = nil
        _app.talkChannelsViewModel.model = nil
        
        if let serverInfo = _app.serverSystemInformation, let minVersion = serverInfo.minVersion {
            let _ = "version: \(minVersion) <= \(_app.config.version)"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _app.ga.trackingViewName(viewName: .start)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickFacebookLogin() {
        AdBrix.firstTimeExperience("페북] 회원가입 시작")
        let vc = FacebookLoginViewController()
        navigationController?.pushViewController(vc, animated: false)
    }
    
    @IBAction func onClickEmailSigup() {
        AdBrix.firstTimeExperience("이멜] 회원가입 시작")
        let vc = EmailSignupViewController()
        navigationController?.pushViewController(vc, animated: false)
    }
    
    deinit {
        print(#function, "\(self)")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
