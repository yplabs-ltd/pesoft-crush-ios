//
//  EmailSignupViewModel.swift
//  DateApp
//
//  Created by Lim Daehyun on 2018. 2. 11..
//  Copyright © 2018년 iflet.com. All rights reserved.
//

import FBSDKLoginKit
import Foundation
class EmailSignupViewModel: VerifyViewModel {
    
    func signup(email: String, password: String, chosenGenderCode: String, recommend: String?, phone: String, code: String, loadingViewModel: DViewModel<LoadingModel>?) {
        let signupViewModel = DViewModel<ApiResponse>(self, { (model, oldModel) -> () in
            guard let apiResponse = model else {
                return
            }
            
            if let member = apiResponse.model as? MemberModel , apiResponse.statusCode == 200 {
                _app.sessionViewModel.makeSession(member: member, email: email, password: password)
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
        _app.api.accountSignupForEmail(email: email, password: password, genderCode: chosenGenderCode == "남자" ? "M" : "F", recommendId: recommend, phone: phone, code: code,apiResponseViewModel: signupViewModel, loadingViewModel: loadingViewModel)
    }
}
