//
//  VoiceChatViewModel.swift
//  DateApp
//
//  Created by Yang Hyeon Gyu on 2017. 3. 26..
//  Copyright © 2017년 iflet.com. All rights reserved.
//

import Foundation

class VoiceChatViewModel : DViewModel<[VoiceChatModel]> {
    func find(voiceChatRoomModel : VoiceChatRoomModel) {
        let responseViewModel = ApiResponseViewModelBuilder<[VoiceChatModel]>(successHandlerWithDefaultError: { [weak self] (voiceChatModels) -> Void in
            print("voiceChatModels")
            print(voiceChatModels)
            self?.model = voiceChatModels
            }).viewModel
        
        let _ = _app.api.voiceChatList(parameters: voiceChatRoomModel.parameters, apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
    }
}
