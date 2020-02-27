//
//  VoiceLikeModel.swift
//  DateApp
//
//  Created by Daehyun Lim on 2018. 5. 20..
//  Copyright © 2018년 iflet.com. All rights reserved.
//

import Foundation

class VoiceLikeViewModel : DViewModel<[VoiceChatRoomModel]> {
    
    var onShouldUpdate: (() -> Void)?
    var voiceLikedModel: [VoiceLikedModel] {
        get {
            return _voiceLikedModel
        }
        
        set {
            _voiceLikedModel.removeAll()
            _voiceLikedModel.append(contentsOf: newValue)
            onShouldUpdate?()
        }
    }
    private var _voiceLikedModel = [VoiceLikedModel]()
    
    
    func getMyVoiceLikedList(voiceId: String) {
        let responseViewModel = ApiResponseViewModelBuilder<[VoiceLikedModel]>(successHandlerWithDefaultError: { [weak self] (rankList) -> Void in
            guard let wself = self else { return }
            wself.voiceLikedModel = rankList
            wself.onShouldUpdate?()
        }).viewModel
        
        let _ = _app.api.myVoiceLikedList(voiceId: voiceId, apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
    }
}
