//
//  VoiceChatRoomViewModel.swift
//  DateApp
//
//  Created by Yang Hyeon Gyu on 2017. 3. 25..
//  Copyright © 2017년 iflet.com. All rights reserved.
//

import Foundation

class VoiceChatRoomViewModel : DViewModel<[VoiceChatRoomModel]> {
    
    // My Voice Chat List
    var onShouldUpdateMyChatList: (() -> Void)?
    var myReceivedHeartCount: Int {
        get {
            guard let l = myChatList else { return 0 }
            return l.compactMap{ $0.heartCount }.reduce(0, +)
        }
    }
    
    var myVoiceChatListCount: Int {
        get {
            guard let l = myChatList else { return 0 }
            return l.count
        }
    }
    
    var myChatList: [VoiceChatRoomModel]? {
        get {
            return _myChatList
        }
        
        set {
            if _myChatList == nil {
                _myChatList = []
            }else {
                _myChatList!.removeAll()
            }
            
            if let n = newValue {
                _myChatList!.append(contentsOf: n)
            }
            onShouldUpdateMyChatList?()
        }
    }
    private var _myChatList: [VoiceChatRoomModel]?
    
    var myRank: VoiceRankModel?
    var topRankList: VoiceRankListModel? {
        didSet {
            onShouldUpdateMyChatList?()
        }
    }
    
    override func reload() {
        let responseViewModel = ApiResponseViewModelBuilder<[VoiceChatRoomModel]>(successHandlerWithDefaultError: { [weak self] (voiceChatRoomModels) -> Void in
            self?.model = voiceChatRoomModels
            }).viewModel
        
        let _ = _app.api.voiceChatRoomList(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
    }
    
    func check(voiceChatRoomModel: VoiceChatRoomModel) {
        let _ = _app.api.voiceChatRoomCheck(parameters: voiceChatRoomModel.parameters)
    }
    
    func getMyVoiceChatList() {
        let responseViewModel = ApiResponseViewModelBuilder<[VoiceChatRoomModel]>(successHandlerWithDefaultError: { [weak self] (voiceChatRoomModels) -> Void in
            guard let wself = self else { return }
            wself.myChatList = voiceChatRoomModels
            }).viewModel
        
        let _ = _app.api.voiceMyChatList(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
    }
    
    func getMyVoiceRank() {
        let responseViewModel = ApiResponseViewModelBuilder<VoiceRankModel>(successHandlerWithDefaultError: { [weak self] (voiceRankModel) -> Void in
            guard let wself = self else { return }
            wself.myRank = voiceRankModel
            wself.onShouldUpdateMyChatList?()
            }).viewModel
        if let id = _app.sessionViewModel.model?.id {
            let _ = _app.api.voiceRank(userId: id ,apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
        }
    }
    
    func getVoiceRankList() {
        let responseViewModel = ApiResponseViewModelBuilder<VoiceRankListModel>(successHandlerWithDefaultError: { [weak self] (rankList) -> Void in
            guard let wself = self else { return }
            wself.topRankList = rankList
            wself.onShouldUpdateMyChatList?()
            }).viewModel
        
        let _ = _app.api.voiceRankList(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
    }
    
    func getMyVoiceLikedList(voiceId: String) {
        let responseViewModel = ApiResponseViewModelBuilder<[VoiceLikedModel]>(successHandlerWithDefaultError: { [weak self] (rankList) -> Void in
            guard let wself = self else { return }
            
            print("")
            }).viewModel
        
        let _ = _app.api.myVoiceLikedList(voiceId: voiceId, apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
    }
}
