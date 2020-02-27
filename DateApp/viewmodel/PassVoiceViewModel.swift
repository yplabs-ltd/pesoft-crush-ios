//
//  PassVoiceViewModel.swift
//  DateApp
//
//  Created by Yang Hyeon Gyu on 2017. 4. 5..
//  Copyright © 2017년 iflet.com. All rights reserved.
//

import Foundation

class PassVoiceViewModel : DViewModel<PassVoiceModel> {
    func passVoice(passVoiceModel: PassVoiceModel, loadingViewModel: DViewModel<LoadingModel>, completeHandler: @escaping () -> ()) {
        let completeModel = ApiResponseViewModelBuilder<ServerDefaultResponseModel>(successHandlerWithDefaultError: { (response) -> Void in
            completeHandler()
        }).viewModel
        
        let _ = _app.api.passVoice(parameters: passVoiceModel.parameters, apiResponseViewModel: completeModel, loadingViewModel: loadingViewModel)
    }
    
    func passVoiceWithRoom(passVoiceModel: PassVoiceModel, loadingViewModel: DViewModel<LoadingModel>, completeHandler: @escaping () -> ()) {
        let completeModel = ApiResponseViewModelBuilder<ServerDefaultResponseModel>(successHandlerWithDefaultError: { (response) -> Void in
            completeHandler()
        }).viewModel
        
        let _ = _app.api.passVoiceWithRoom(parameters: passVoiceModel.parameters, apiResponseViewModel: completeModel, loadingViewModel: loadingViewModel)
    }
}
