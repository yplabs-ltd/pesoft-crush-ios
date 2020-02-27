//
//  InitializeViewController.swift
//  DateApp
//
//  Created by ryan on 12/26/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit

class InitializeViewController: UIViewController {
    
    @IBOutlet weak var birdImageView: UIImageView!

    private var systemChecked: Bool? {
        didSet {
            moveNext()
        }
    }
    private var profileCodeReady: Bool? {
        didSet {
            moveNext()
        }
    }
    private var loginChecked: Bool? {
        didSet {
            moveNext()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if DEBUG
            print("### 디버그 모드입니다.")
            
            //_app.session.removeSession() // 임시로 userdefault 로그인 기능은 막음
        #endif
        
        // 새 애니메이션
        birdImageView.animationDuration = 0.5
        birdImageView.animationImages = UIImage.birdFrames
        birdImageView.startAnimating()
        
        
        let systemCheckViewModel = DViewModel<ApiResponse>(self, { [weak self] (model, oldModel) -> () in
            guard let apiResponse = model else {
                return
            }
            guard let system = apiResponse.model as? ServerSystemInformationModel , system.status == "OK" else {
                var errorTitle = "서버오류 입니다."
                var errorMessage = "잠시 후 다시 실행해주세요."
                if let system = apiResponse.model as? ServerSystemInformationModel {
                    if let title = system.title {
                        errorTitle = title
                    }
                    if let description = system.description {
                        errorMessage = description
                    }
                }
                alert(title: errorTitle, message: errorMessage, handler: { (action) -> Void in
                    exit(0)
                })
                return
            }
            
            guard let minVersion = system.minVersion , self?.hasMinVersion(currentVersion: _app.config.version, minVersion: minVersion) ?? true else {
                alert(title: "앱 업데이트가 되었습니다. 앱스토어로 이동합니다.", message: "안내", handler: { (action) -> Void in
                    UIApplication.shared.openURL(NSURL(string: _app.config.appstoreUrl)! as URL)
                    exit(0)
                })
                return
            }
            
            _app.userDefault.noticeTitle = nil
            _app.userDefault.noticeMessage = nil
            _app.userDefault.noticeID = system.noticeId
            if let title = system.title, let message = system.description {
                _app.userDefault.noticeTitle = title
                _app.userDefault.noticeMessage = message
            }
            
            // system information 확인
            _app.log.debug("system: \(system)")
            _app.serverSystemInformation = system
            
            self?.systemChecked = true
        })
        let _ = _app.api.systemCheck(apiResponseViewModel: systemCheckViewModel, loadingViewModel: _app.loadingViewModel)
        
        let profileCodeInfoViewModel = ApiResponseViewModelBuilder<ProfileCodeInfoModel>(errorHandler: { [weak self] (statusCode, serverError) -> Void in
                self?.profileCodeReady = false
            }) { [weak self] (model) -> Void in
                _app.profileCodeInfo = model
                self?.profileCodeReady = true
        }.viewModel
        let _ = _app.api.profileCodeInfo(apiResponseViewModel: profileCodeInfoViewModel, loadingViewModel: _app.loadingViewModel)
        
        // userdefault 에 사용자 인증정보 있으면 사용해서 자동 로그인 시도
        if let email = _app.userDefault.email, let password = _app.userDefault.password , 0 < email.length && 0 < password.length {
            
            let accountSigninViewModel = ApiResponseViewModelBuilder<MemberModel>(errorHandler: { [weak self] (statusCode, serverError) -> Void in
                
                // 서버에서 처리한 뭔가 오류가 났을때만 session제거(서버 장애에 의한 error 는 세션 유지)
                if serverError?.code != nil {
                    _app.sessionViewModel.removeSession()
                    self?.loginChecked = false
                }
                }) { [weak self] (model) -> Void in
                    _app.sessionViewModel.makeSession(member: model, email: email, password: password)
                    self?.loginChecked = true
            }.viewModel
            let _ = _app.api.accountSigninForEmail(email: email, password: password, apiResponseViewModel: accountSigninViewModel, loadingViewModel: _app.loadingViewModel)
        } else {
            checkExistFacebookCookies()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print(#function, "\(self)")
    }
}

extension InitializeViewController {
    func hasMinVersion(currentVersion: String, minVersion: String) -> Bool {
        
        let currentVersionArray = currentVersion.components(separatedBy:".")
        let minVersionArray = minVersion.components(separatedBy:".")
        
        if let currentMajor = Int(currentVersionArray[0]), let minMajor = Int(minVersionArray[0]) , 0 < currentVersionArray.count && 0 < minVersionArray.count {
            // major check
            if currentMajor < minMajor {
                return false
            }
            else if currentMajor == minMajor {
                if let currentMinor = Int(currentVersionArray[1]), let minMinor = Int(minVersionArray[1]) , 1 < currentVersionArray.count && 1 < minVersionArray.count {
                    // minor check
                    if currentMinor < minMinor {
                        return false
                    }
                    else if currentMinor == minMinor {
                        if let currentPatch = Int(currentVersionArray[2]), let minPatch = Int(minVersionArray[2]) , 2 < currentVersionArray.count && 2 < minVersionArray.count {
                            // patch check
                            if currentPatch < minPatch {
                                return false
                            }
                        }
                    }
                }
            }
        }
        
        return true
    }
    
    func checkExistFacebookCookies(){
        guard let isFacebookLogined = _app.userDefault.facebookLogined, isFacebookLogined == true else {
            loginChecked = false
            return
        }
        let facebookViewModel = FacebookLoginViewModel()
        facebookViewModel.checkAlreadySignupWithFacebook(onSuccess: { [weak self] in
            guard let wself = self else { return }
            wself.loginChecked = true
            }, onFailed: { [weak self] error in
                guard let wself = self else { return }
                wself.loginChecked = false
            }, loadingViewModel: nil)
    }
    
    func moveNext() {
        
        guard let _ = systemChecked, let profileCodeReady = profileCodeReady, let loginChecked = loginChecked else {
            return
        }
        
        if !profileCodeReady {
            alert(title: "서버오류 입니다. 잠시 후 다시 실행해주세요.", message: "안내", handler: { (action) -> Void in
                exit(0)
            })
            return
        }
        
        if loginChecked {
            
            _app.log.info("loginid: \(_app.sessionViewModel.model?.id)")
            
            // today page
            let loginViewController = UIViewController.viewControllerFromStoryboard(name: "Main", identifier: "TopContainer")
            _app.delegate.window?.rootViewController = loginViewController
        } else {
            // 로긴/가입 선택 페이지
            let loginViewController = UIViewController.viewControllerFromStoryboard(name: "Login", identifier: "LoginNavigationViewController")
            _app.delegate.window?.rootViewController = loginViewController
        }
    }
}
