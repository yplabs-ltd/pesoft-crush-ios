//
//  App.swift
//  DateApp
//
//  Created by ryan on 12/27/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import Foundation
import XCGLogger

let _app = App()

class App {
    var initialized = false
    let config = Config()
    var userDefault = UserDefault()
    let api = Api()
    let ga = GAWrapper()
    var sendBird = SendBirdWrapper()
    var oneSignal = OneSignalWrapper()
    let utility = Utility()
    let log = XCGLogger.default
    var serverSystemInformation: ServerSystemInformationModel?
    var profileCodeInfo: ProfileCodeInfoModel?
    var matchTodayAge: MatchTodayAgeModel?
    let sessionViewModel = SessionViewModel()
    let loadingViewModel = DViewModel<LoadingModel>(LoadingModel())
    let cardDetailViewModel = DViewModel<CardDetailModel>() // 카드 상세보기 viewmodel
    let profileViewModel = ProfileViewModel()   // profile 정보 관련 viewmodel
    
    let voiceViewModel = VoiceViewModel()
    let userVoiceOneViewModel = UserVoiceOneViewModel()
    let voiceChatRoomViewModel = VoiceChatRoomViewModel()
    let voiceLikeViewModel = VoiceLikeViewModel()
    let voiceChatViewModel = VoiceChatViewModel()
    var passVoiceViewModel = PassVoiceViewModel()
    
    let todayCardsViewModel = TodayCardsViewModel()
    let evaluationCardsViewModel = EvaluationCardsViewModel()
    let storyCardsViewModel = StoryCardsViewModel()
    let historiesViewModel = HistoriesViewModel()   // 소식 정보 관련 viewmodel
    let secondViewModel = DViewModel<Date>()
    let minuteViewModel = DViewModel<Date>()
    let talkChannelsViewModel = TalkChannelsViewModel()
    let profileSubmitButtonShowViewModel = DViewModel<Bool>()   // 프로필 submit 버튼이 보이는가 안보이는가 결정
    var pointsViewModel = PointsViewModel()    // shop에 진열된 상품들
    var oneSignalTagsViewModel = DViewModel<OneSignalTags>()
    var viewDict = [String: UIView]()
    var chatViewCell = [VoiceChatCell]()
    var delegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var copyHobbyList = [String:CodeValueModel]()
    var copyCharmList = [String:CodeValueModel]()
    var copyFavoriteList = [String:CodeValueModel]()
    
    var rootViewController: UIViewController? {
        return delegate.window?.rootViewController
    }
    
    var container: TopContainer {
        get {
            guard let container = delegate.window?.rootViewController as? TopContainer else {
                fatalError()
            }
            return container
        }
    }
    
    var uuid: String {
        get {
            guard let vender = UIDevice.current.identifierForVendor else {
                return ""
            }
            return vender.uuidString
        }
    }
    
    func initViewDict() {
        viewDict.removeAll()
    }
    
    func setCopyProfileCodes() {
        initViewDict()
        copyHobbyList.removeAll()
        if let datas = profileViewModel.getProfileKeywordList(type: .HobbyType) {
            for codeInfo in datas {
                
                if (codeInfo.code?.length)! > 0 {
                    copyHobbyList[codeInfo.code!] = codeInfo
                }
            }
        }
        
        copyCharmList.removeAll()
        if let datas = profileViewModel.getProfileKeywordList(type: .CharmingType) {
            for codeInfo in datas {
                if let count = codeInfo.code?.length, count > 0 {
                    copyCharmList[codeInfo.code!] = codeInfo
                }
            }
        }
        
        copyFavoriteList.removeAll()
        if let datas = profileViewModel.getProfileKeywordList(type: .FavoriteType) {
            for codeInfo in datas {
                if (codeInfo.code?.length)! > 0 {
                    copyFavoriteList[codeInfo.code!] = codeInfo
                }
            }
        }
    }
    
    func mergeForUpdateProfileCodes(type: ProfileKeywordType) {
        switch type {
        case .HobbyType:
            profileViewModel.mergeProfileKeywordList(type: .HobbyType, datas: copyHobbyList)
        case .CharmingType:
            profileViewModel.mergeProfileKeywordList(type: .CharmingType, datas: copyCharmList)
        case .FavoriteType:
            profileViewModel.mergeProfileKeywordList(type: .FavoriteType, datas: copyFavoriteList)
        }
    }
    
    func getProfileTypeCodes(type: ProfileKeywordType) -> [CodeValueModel]?{
        switch type {
        case .HobbyType:
            return profileCodeInfo?.hobbyCode
        case .CharmingType:
            return profileViewModel.model?.gender == "F" ? profileCodeInfo?.charmFTypeCode : profileCodeInfo?.charmMTypeCode
        case .FavoriteType:
            return profileCodeInfo?.favoriteTypeCode
        }
    }
    
    func getCardDetailProfileTypeCodes(_ type: ProfileKeywordType) -> [CodeValueModel]?{
        switch type {
        case .HobbyType:
            if let lastObject = cardDetailViewModel.model?.profileModel?.hobbyCode.last {
                if lastObject.value! == "더보기" {
                    cardDetailViewModel.model?.profileModel?.hobbyCode.removeLast()
                }
            }
            
            return cardDetailViewModel.model?.profileModel?.hobbyCode
        case .CharmingType:
            if cardDetailViewModel.model?.profileModel?.gender == "F" {
                if let lastObject = cardDetailViewModel.model?.profileModel?.charmFTypeCode.last {
                    if lastObject.value! == "더보기" {
                        cardDetailViewModel.model?.profileModel?.charmFTypeCode.removeLast()
                    }
                }
                
                return cardDetailViewModel.model?.profileModel?.charmFTypeCode
            }else {
                if let lastObject = cardDetailViewModel.model?.profileModel?.charmMTypeCode.last {
                    if lastObject.value! == "더보기" {
                        cardDetailViewModel.model?.profileModel?.charmMTypeCode.removeLast()
                    }
                }
                
                return cardDetailViewModel.model?.profileModel?.charmMTypeCode
            }
        case .FavoriteType:
            if let lastObject = cardDetailViewModel.model?.profileModel?.favoriteTypeCode.last {
                if lastObject.value! == "더보기" {
                    cardDetailViewModel.model?.profileModel?.favoriteTypeCode.removeLast()
                }
            }
            
            return cardDetailViewModel.model?.profileModel?.favoriteTypeCode
        }
    }
    
    func getCopyProfileTypeCodes(type: ProfileKeywordType) -> [String:CodeValueModel]?{
        switch type {
        case .HobbyType:
            return copyHobbyList
        case .CharmingType:
            return copyCharmList
        case .FavoriteType:
            return copyFavoriteList
        }
    }
    
    func removeCopyItem(key: String, type: ProfileKeywordType) {
        switch type {
        case .HobbyType:
            copyHobbyList.removeValue(forKey: key)
        case .CharmingType:
            copyCharmList.removeValue(forKey: key)
        case .FavoriteType:
            copyFavoriteList.removeValue(forKey: key)
        }
    }
    
    func insertCopyItem(value: CodeValueModel, type: ProfileKeywordType) {
        switch type {
        case .HobbyType:
            copyHobbyList[value.code!] = value
        case .CharmingType:
            copyCharmList[value.code!] = value
        case .FavoriteType:
            copyFavoriteList[value.code!] = value
        }
    }
}

protocol ApiReloadable {
    func reloadApi()
}

