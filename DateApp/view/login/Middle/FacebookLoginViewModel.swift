//
//  FacebookLoginViewModel.swift
//  DateApp
//
//  Created by Lim Daehyun on 2018. 2. 10..
//  Copyright © 2018년 iflet.com. All rights reserved.
//
import FBSDKLoginKit
import Foundation
class FacebookLoginViewModel: VerifyViewModel {
    var fbToken: String?
    var fbUserID: String?
    
    override init() {
        if FBSDKAccessToken.current() != nil {
            fbToken = FBSDKAccessToken.current().tokenString
        }
    }
    
    let facebookReadPermissions = ["public_profile", "email"]
    func loginToFacebookWithSuccess(isSignup: Bool = true, successBlock: (() -> ())?, andFailure failureBlock: @escaping (NSError?) -> ()) {
        
        if FBSDKAccessToken.current() != nil {
            //For debugging, when we want to ensure that facebook login always happens
            //FBSDKLoginManager().logOut()
            //Otherwise do:
            return
        }
        
        
        FBSDKLoginManager().logIn(withReadPermissions: self.facebookReadPermissions, from: UIApplication.topViewController()) { [weak self] (r, error) in
            guard let wself = self, let result = r else { return }
            if error != nil {
                FBSDKLoginManager().logOut()
                failureBlock(error! as NSError)
            } else if result.isCancelled {
                FBSDKLoginManager().logOut()
                failureBlock(nil)
            } else {
                var allPermsGranted = true
                let grantedPermissions = result.grantedPermissions.map( {"\($0)"} )
                
                for permission in wself.facebookReadPermissions {
                    if grantedPermissions.contains(permission) == false {
                        allPermsGranted = false
                        break
                    }
                }
                if allPermsGranted {
                    wself.fbToken = result.token.tokenString
                    wself.fbUserID = result.token.userID
                    
                    if isSignup {
                        _app.userDefault.facebookAuthToken = wself.fbToken
                        _app.userDefault.facebookUserId = wself.fbUserID
                        wself.checkAlreadySignupWithFacebook(onSuccess: nil, onFailed: nil, loadingViewModel: nil)
                    }
                    
                    successBlock?()
                } else {
                    failureBlock(nil)
                }
            }
        }
    }
    
    func checkAlreadySignupWithFacebook(onSuccess: (() -> Void)?, onFailed: ((NSError?) -> Void)?, loadingViewModel: DViewModel<LoadingModel>?) {
        guard let token = fbToken else {
            return
        }
        let signupViewModel = DViewModel<ApiResponse>(self, { (model, oldModel) -> () in
            guard let apiResponse = model else {
                return
            }
            
            if let member = apiResponse.model as? MemberModel , apiResponse.statusCode == 200 {
                self.saveFacebookLoginCookies()
                _app.sessionViewModel.makeSession(member: member, email: member.email, password: nil)
                onSuccess?()
                _app.delegate.moveTopAfterLoginSuccess()
            } else {
                _app.sessionViewModel.removeSession()
                onFailed?(nil)
            }
        })
        
        let _ = _app.api.checkFacebookRegistered(token: token, apiResponseViewModel: signupViewModel, loadingViewModel: loadingViewModel)
    }
    
    
    func signupWithFacebook(recommendId: String?, genderCode: String, onSuccess: (() -> Void)?, onFailed: ((NSError?) -> Void)?, loadingViewModel: DViewModel<LoadingModel>?) {
        guard let token = fbToken else {
            return
        }
        let signupViewModel = DViewModel<ApiResponse>(self, { (model, oldModel) -> () in
            guard let apiResponse = model else {
                return
            }
            
            if let member = apiResponse.model as? MemberModel , apiResponse.statusCode == 200 {
                self.saveFacebookLoginCookies()
                _app.sessionViewModel.makeSession(member: member, email: member.email, password: nil)
                _app.delegate.moveTopAfterLoginSuccess()
            } else {
                _app.sessionViewModel.removeSession()
                if let error = apiResponse.serverErrorModel, let description = error.description {
                    alert(message: "\(description)")
                } else {
                    alert(title: "가입 실패", message: "\(apiResponse.statusCode)")
                }
            }
        })
        
        let _ = _app.api.signupWithFacebook(token: token, recommendId: recommendId, genderCode: genderCode == "남자" ? "M" : "F" , apiResponseViewModel: signupViewModel, loadingViewModel: loadingViewModel)
    }
    
    private func saveFacebookLoginCookies() {
        let cookieStorage = HTTPCookieStorage.shared
        guard let cookies = cookieStorage.cookies else {
            return
        }
        
        for cookie in cookies {
            if cookie.name == "CrushAccessToken" {
                _app.userDefault.facebookLogined = true
            }
        }
    }
}
