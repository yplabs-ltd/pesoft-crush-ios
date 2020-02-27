//
//  Session.swift
//  DateApp
//
//  Created by ryan on 12/28/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import Foundation
import FBSDKLoginKit

class SessionViewModel: DViewModel<MemberModel> {
    
    var logined: Bool {
        get {
            guard let _ = model else {
                return false
            }
            return true
        }
    }
    var settingInfoModel = SettingInfoModel()
    
    var pointAlert = false  // 포인트가 지급 되었다면 (한번만) alert 창을 보여줘야합니다.
    
    func makeSession(member: MemberModel, email: String?, password: String?) {
        _app.userDefault.email = email
        _app.userDefault.password = password
        if let p = member.loginPoint, p > 0 {
            pointAlert = true
        }
        model = member
        
        // onesignal tags 세팅이 없으면 초기 세팅 필요함
        _app.oneSignalTagsViewModel.bindOnce { (model, oldModel) -> () in
            
            guard let userId = member.id else {
                return
            }
            
            var tagInit = false
            if model == nil {
                tagInit = true
            }
            if let tags = model , userId != tags.userId {
                tagInit = true
            }
            if tagInit {
                var newTags = OneSignalTags()
                newTags.userId = userId
                newTags.enableCard = true
                newTags.enableChat = true
                newTags.enableLike = true
                newTags.waitEvaluate = nil
                _app.oneSignal.sendTags(tags: newTags)
            }
        }
        _app.oneSignal.getTags()
        
        // sendbird login
        _app.sendBird.login(memberModel: member)
    }
    
    func removeSession() {
        model = nil
        _app.userDefault.email = nil
        _app.userDefault.password = nil
        _app.userDefault.facebookAuthToken = nil
        _app.userDefault.facebookUserId = nil
        _app.userDefault.facebookLogined = false
        _app.userDefault.savedAppVersion = nil
        
        FBSDKLoginManager().logOut()
        
        // onesignal push 해제 (tag 초기화)
        _app.oneSignalTagsViewModel.model = nil
        _app.oneSignal.sendTags(tags: OneSignalTags())
    }
    
    func reloadMemberInfo() {
        let responseViewModel = ApiResponseViewModelBuilder<MemberModel>(successHandler: { [weak self] (memberModel) -> Void in
            self?.model = memberModel
        }).viewModel
        let _ = _app.api.myInfo(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
    }
}
