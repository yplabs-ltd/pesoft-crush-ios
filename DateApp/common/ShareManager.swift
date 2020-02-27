//
//  ShareManager.swift
//  DateApp
//
//  Created by Daehyun Lim on 2018. 2. 20..
//  Copyright © 2018년 iflet.com. All rights reserved.
//

import Foundation

let ShareManager = _ShareManager.sharedInstance
class _ShareManager: NSObject{
    static let sharedInstance = _ShareManager()
    
    func actionShareKakaoTalk() {
        if let userId = _app.profileViewModel.model?.id {
            ShareManager.shareWithUserId(userId: userId)
        }else {
            let responseViewModel = ApiResponseViewModelBuilder<ProfileModel>(successHandlerWithDefaultError: { (profileModel) -> Void in
                _app.profileViewModel.model = profileModel
                ShareManager.shareWithUserId(userId: _app.profileViewModel.model?.id)
            }).viewModel
            let _ = _app.api.profileEdit(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
        }
    }
    /*
    func sendKakaoShareMessage(userId: Int?) {
        guard let id = userId else {
            return
        }
        
        let recommendId = String(id, radix: 36).uppercased
        let linkImageObject: AnyObject! = KakaoTalkLinkObject.createImage("https://s3-ap-northeast-1.amazonaws.com/pesofts-image/images/logo.png", width: 200, height: 150)
        let linkLabel = "매일 23명 소개하는\n목소리 소개팅 '그당반'에 초대합나다.\n추천인 코드는 [\(recommendId)]입니다."
        let linkLabelObject = KakaoTalkLinkObject.createLabel(linkLabel)
        let webLink : KakaoTalkLinkObject = KakaoTalkLinkObject.createWebLink(NSLocalizedString("설치하러 가기", comment: ""), url: "https://goo.gl/qnwSqa")
        
        KOAppCall.openKakaoTalkAppLink([linkImageObject!, linkLabelObject, webLink], forwardable: true)
    }*/
    
    func shareWithUserId(userId: Int?) {
        guard let id = userId else {
            return
        }
        
        let number = UInt(exactly: id)!
        let recommendId = String(number, radix: 36, uppercase: true)
        let linkLabel = "매일 23명 소개하는 목소리 소개팅 '그당반'에 초대합니다. 추천인 코드는 [\(recommendId)]입니다."
        
        let linkObject = KMTLinkObject()
        
        if let url = URL(string: "https://goo.gl/qnwSqa") {
            linkObject.mobileWebURL = url
            linkObject.webURL = url
        }
        
        let buttonObject = KMTButtonObject()
        buttonObject.title = "'그당반'에 초대합니다."
        buttonObject.link = linkObject
        
        var contentObject: KMTContentObject? = nil
        let imageUrl = "https://s3-ap-northeast-1.amazonaws.com/pesofts-image/images/logo.png"
        if let url = URL(string: imageUrl) {
            contentObject = KMTContentObject()
            contentObject?.imageWidth = 300
            contentObject?.imageHeight = 200
            contentObject?.imageURL = url
            contentObject?.title = "'그당반'에 초대합니다."
            contentObject?.desc = linkLabel
            contentObject?.link = linkObject
        }
        
        shareViaKakaoTalk(contentObject!, buttonObjects: [buttonObject])
        
    }
    
    func shareViaKakaoTalk(_ contentObject: KMTContentObject, buttonObjects: [KMTButtonObject]) {
        let template = KMTFeedTemplate(content: contentObject)
        template.buttons = buttonObjects
        KLKTalkLinkCenter.shared().sendDefault(with: template, success: { (warningMsg, argumentMsg) in
            
        }, failure: { (error) in
            
        })
    }
}
