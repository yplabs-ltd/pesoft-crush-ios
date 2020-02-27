//
//  UserVoiceOneViewModel.swift
//  DateApp
//
//  Created by Yang Hyeon Gyu on 2017. 3. 19..
//  Copyright © 2017년 iflet.com. All rights reserved.
//

import Foundation

class UserVoiceOneViewModel: DViewModel<UserVoiceOneModel> {
    override func reload() {
        reloadWithCompletion(completion: nil)
    }
    
    override func reloadWithCompletion(completion:(() -> Void)? = nil) {
        let responseViewModel = ApiResponseViewModelBuilder<UserVoiceOneModel>(successHandlerWithDefaultError: { [weak self] (userVoiceModel) -> Void in
            _app.userVoiceOneViewModel.model = userVoiceModel
            }).viewModel
        let _ = _app.api.findVoinceRandomOneUser(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel, onFinish: completion)
    }
    
    func find(loadingViewModel: DViewModel<LoadingModel>?, completeHandler: @escaping (UserVoiceOneModel) -> ()) {
        let responseViewModel = DViewModel<ApiResponse>(self, { (model, oldModel) -> () in
            guard let apiResponse = model, let newUserVoiceModel = apiResponse.model as? UserVoiceOneModel else {
                return
            }
            
            completeHandler(newUserVoiceModel)
        })

        let _ = _app.api.findVoinceRandomOneUser(apiResponseViewModel: responseViewModel, loadingViewModel: loadingViewModel)
    }
    
    // dirtyFlag 를 true 해둔 후 나중에 reload 하기위함
    var dirtyFlag = false
    
    func reloadIfDirty() {
        if dirtyFlag {
            dirtyFlag = false
            reload()
        }
    }
}
