//
//  VoiceViewModel.swift
//  DateApp
//
//  Created by Yang Hyeon Gyu on 2017. 3. 12..
//  Copyright © 2017년 iflet.com. All rights reserved.
//

import Foundation

class VoiceViewModel: DViewModel<VoiceModel> {
    // api 로 로드한 원본 model
    
    
    func uploadVoice(loadingViewModel: DViewModel<LoadingModel>?, voiceFile: Data, completeHandler: @escaping (VoiceModel?) -> ()) {
        guard let voiceModel = model else {
            return
        }
        
        var newVoiceModel = voiceModel
        
        let s3uploadViewModel = DViewModel<ApiResponse>(self, { (model, oldModel) -> () in
            completeHandler(newVoiceModel)
        })
        
        let s3InforViewModel = DViewModel<ApiResponse>(self, { (model, oldModel) -> () in
            guard let apiResponse = model, let s3 = apiResponse.model as? S3InformationModel else {
                completeHandler(nil)
                return
            }
            
            newVoiceModel.urlPath = s3.uploadImagePath
            newVoiceModel.userId = _app.sessionViewModel.model?.id
            _app.api.s3VoiceUpload(s3: s3, file: voiceFile, apiResponseViewModel: s3uploadViewModel, loadingViewModel: loadingViewModel)
        })
        let _ = _app.api.s3VoiceInformation(apiResponseViewModel: s3InforViewModel, loadingViewModel: loadingViewModel)
    }
    
    func uploadVoiceWithReply(loadingViewModel: DViewModel<LoadingModel>?, voiceFile: Data, completeHandler: @escaping (VoiceModel) -> ()) {
        guard let voiceModel = model else {
            return
        }
        
        var newVoiceModel = voiceModel
        
        let s3uploadViewModel = DViewModel<ApiResponse>(self, { (model, oldModel) -> () in
            completeHandler(newVoiceModel)
            Toast.showToast(message: "음성이 발송되었습니다", duration: 1.0)
        })
        
        let s3InforViewModel = DViewModel<ApiResponse>(self, { (model, oldModel) -> () in
            guard let apiResponse = model, let s3 = apiResponse.model as? S3InformationModel else {
                return
            }
            
            newVoiceModel.urlPath = s3.uploadImagePath
            newVoiceModel.userId = _app.sessionViewModel.model?.id
            let _ = _app.api.s3VoiceUpload(s3: s3, file: voiceFile, apiResponseViewModel: s3uploadViewModel, loadingViewModel: loadingViewModel)
        })
        let _ = _app.api.s3VoiceInformation(apiResponseViewModel: s3InforViewModel, loadingViewModel: loadingViewModel)
    }


    func insertStartVoice(voiceModel: VoiceModel, loadingViewModel: DViewModel<LoadingModel>, completeHandler: @escaping () -> ()) {
        let completeModel = ApiResponseViewModelBuilder<UploadVoice>(successHandlerWithDefaultError: { (response) -> Void in
            var userDefault = UserDefault()
            userDefault.uploadVoiceTime = response.updateTime
            completeHandler()
            Toast.showToast(message: "음성이 발송되었습니다", duration: 1.0)
        }).viewModel
        let _ = _app.api.insertStartVoice(parameter: voiceModel.parameters,apiResponseViewModel: completeModel, loadingViewModel: loadingViewModel)
    }
    
    func replyStartVoice(voiceModel: VoiceModel, loadingViewModel: DViewModel<LoadingModel>, onSuccess:(() -> Void)?) {
        let _ = _app.api.replyStartVoice(parameter: voiceModel.parameters, loadingViewModel: loadingViewModel, onFinish: {
            response in
            if response?.statusCode == 200 {
                onSuccess?()
                Toast.showToast(message: "음성이 발송되었습니다", duration: 1.0)
            }
        })
    }
    
    func replyVoice(voiceModel: VoiceModel, loadingViewModel: DViewModel<LoadingModel>, completeHandler: @escaping () -> ()) {
        let completeModel = ApiResponseViewModelBuilder<ServerDefaultResponseModel>(successHandlerWithDefaultError: { (response) -> Void in
            Toast.showToast(message: "음성이 발송되었습니다", duration: 1.0)
            completeHandler()
        }).viewModel
        
        let _ = _app.api.replyVoice(parameter: voiceModel.parameters, apiResponseViewModel: completeModel, loadingViewModel: loadingViewModel)
    }
    
    func checkVoiceBuzzie(loadingViewModel: DViewModel<LoadingModel>, completeHandler: @escaping () -> ()) {
        let completeModel = ApiResponseViewModelBuilder<ServerDefaultResponseModel>(successHandlerWithDefaultError: { (response) -> Void in
            Toast.showToast(message: "음성이 발송되었습니다", duration: 1.0)
            completeHandler()
        }).viewModel
        
        let _ = _app.api.checkVoiceBuzzie(apiResponseViewModel: completeModel, loadingViewModel: loadingViewModel)
    }
    
    func replyVoiceUseBuzzie(voiceModel: VoiceModel, loadingViewModel: DViewModel<LoadingModel>, completeHandler: @escaping () -> ()) {
        let completeModel = ApiResponseViewModelBuilder<ServerDefaultResponseModel>(successHandlerWithDefaultError: { (response) -> Void in
            Toast.showToast(message: "음성이 발송되었습니다", duration: 1.0)
            completeHandler()
        }).viewModel
        
        let _ = _app.api.replyVoiceUseBuzzie(parameter: voiceModel.parameters, apiResponseViewModel: completeModel, loadingViewModel: loadingViewModel)
    }
}
