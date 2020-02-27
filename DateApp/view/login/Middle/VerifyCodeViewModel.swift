//
//  VerifyCodeViewModel.swift
//  DateApp
//
//  Created by Lim Daehyun on 2018. 2. 11..
//  Copyright © 2018년 iflet.com. All rights reserved.
//

import Foundation
class VerifyCodeViewModel: VerifyViewModel {
    func requestSMSCode(phone: String, onSuccess: (() -> Void)?, onFailed: ((NSError?) -> Void)?, loadingViewModel: DViewModel<LoadingModel>?) {
        
        let signupViewModel = DViewModel<ApiResponse>(self, { (model, oldModel) -> () in
            guard let apiResponse = model else {
                return
            }
            
            if apiResponse.statusCode == 200 {
                onSuccess?()
            } else {
                _app.sessionViewModel.removeSession()
                if let error = apiResponse.serverErrorModel, let description = error.description {
                    alert(message: "\(description)")
                } else {
                    alert(message: "문자 요청에 실패하였습니다.")
                }
            }
        })
        let _ = _app.api.requestSMSCode(phone: phone, apiResponseViewModel: signupViewModel, loadingViewModel: loadingViewModel)
    }

    func requestAuthCode(phone: String, code: String, onSuccess: (() -> Void)?, onFailed: ((NSError?) -> Void)?, loadingViewModel: DViewModel<LoadingModel>?) {
        
        let signupViewModel = DViewModel<ApiResponse>(self, { (model, oldModel) -> () in
            guard let apiResponse = model else {
                return
            }
            
            if apiResponse.statusCode == 200 {
                onSuccess?()
            } else {
                _app.sessionViewModel.removeSession()
                if let error = apiResponse.serverErrorModel, let description = error.description {
                    alert(message: "\(description)")
                } else {
                    alert(message: "인증에 실패하였습니다.")
                }
            }
        })
        let _ = _app.api.requestAuthCode(phone: phone, code: code, apiResponseViewModel: signupViewModel, loadingViewModel: loadingViewModel)
    }

}
