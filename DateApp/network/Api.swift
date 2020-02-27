//
//  Api.swift
//  DateApp
//
//  Created by ryan on 1/3/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

struct Api {
    
    func systemCheck(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/systemCheck/ios")
                .method(method:.get)
                .paramEncoding(paramEncoding: ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler: { (req, res, json) -> ApiResponseModel? in
                    _app.userDefault.lastestAppVersion = json["latestVersion"].string
                    let systemInfo = ServerSystemInformationModel(json: json)
                    return systemInfo
                })
                .completionHandler(completionHandler: { (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    func accountSigninForEmail(email: String, password: String, apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/account/signin")
                .method(method:.post)
                .paramEncoding(paramEncoding: ApiParameterEncoding.url)
                .parameters(parameters: [
                    "email": email as AnyObject,
                    "passwd": password as AnyObject
                    ])
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    var member = MemberModel(json: json)
                    member.loadMainImage()
                    return member
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    func myInfo(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        var appVersion: String?
        if let info = Bundle.main.infoDictionary {
            appVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown"
        }
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/account/myinfo")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: [
                    "appVersion": (appVersion ?? "") as AnyObject,
                    "osVersion": "IOS" as AnyObject
                    ])
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    var member = MemberModel(json: json)
                    member.loadMainImage()
                    return member
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // 결제하기(버찌충전), 테스트용, test
    func pointPayment(point: Int, apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/point/payment")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: ["pointdiff" : point as AnyObject])
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return ServerDefaultResponseModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // 결제 (영수증 검증)
    func pointPaymentIos(receipt: Data, apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        
        let receipt64 = receipt.base64EncodedString(options: Data.Base64EncodingOptions.endLineWithLineFeed)
        _app.log.debug("receipt64: \(receipt64)")
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/point/payment/ios")
                .method(method:.put)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: ["appleReceipt" : receipt64 as AnyObject])
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return PointValueModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    func pointLogList(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/point/loglist")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    var pointLogsModel: [PointLogModel] = []
                    for (_, subJson): (String, JSON) in json {
                        let pointLogModel = PointLogModel(json: subJson)
                        pointLogsModel.append(pointLogModel)
                    }
                    return pointLogsModel
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // 월 1회 10명 초대시 30버찌 충전
    // 요청 전에 체크 URL로 먼저 가능여부 확인
    func pointSmsInviteCheck(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/point/smsinvite/check")
                .method(method: .get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: [
                    "iosAppVer": _app.config.version as AnyObject
                    ])
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return NextDttmModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    func pointSmsInvite(phoneNumberList: [String], apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/point/smsinvite")
                .method(method:.post)
                .parameters(parameters: ["phoneNumberList" : phoneNumberList as AnyObject])
                .paramEncoding(paramEncoding:ApiParameterEncoding.json)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return PointValueModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    func accountSignupForEmail(email: String, password: String, genderCode: String, recommendId: String?, phone: String, code: String, apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/account/signup/code")
                .method(method:.put)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: [
                    "email": email as AnyObject,
                    "passwd": password as AnyObject,
                    "gender": genderCode as AnyObject,
                    "recommend": (recommendId ?? "")  as AnyObject,
                    "phone":phone as AnyObject,
                    "code":code as AnyObject
                    ])
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    var member = MemberModel(json: json)
                    member.loadMainImage()
                    return member
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    func accountLogout(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/account/logout")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return ServerDefaultResponseModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    func accountSleepAccount(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/account/signout")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return ServerDefaultResponseModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    func accountSignout(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/account/signout")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: ["status":"D" as AnyObject])
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return ServerDefaultResponseModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    func checkFacebookRegistered(token: String, apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/account/signup/facebook")
                .method(method:.put)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: ["token":token as AnyObject])
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    var member = MemberModel(json: json)
                    member.loadMainImage()
                    return member
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    func signupWithFacebook(token: String, recommendId: String?, genderCode: String, apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/account/signup/facebook")
                .method(method:.put)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: ["recommend": (recommendId ?? "") as AnyObject,
                                         "token":token as AnyObject,
                                         "gender":genderCode as AnyObject])
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    var member = MemberModel(json: json)
                    member.loadMainImage()
                    return member
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    func requestSMSCode(phone: String, apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/account/auth/code/request")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: ["phone":phone as AnyObject])
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return ServerDefaultResponseModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    func requestAuthCode(phone: String, code: String, apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/account/auth/code")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: ["phone":phone as AnyObject,
                                         "code": code as AnyObject])
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return ServerDefaultResponseModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    func requestUpdateSetting(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/account/setting")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: _app.sessionViewModel.settingInfoModel.parameters)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return ServerDefaultResponseModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    func requestGetSettingInfo(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/account/setting")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    let settingInfoModel = SettingInfoModel(json: json)
                    return settingInfoModel
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // 오늘의 카드 리스트
    func cardListToday(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/card/list/today")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    
                    var todayCards: [CardModel] = []
                    for (_, subJson): (String, JSON) in json {
                        let cafe = CardModel(json: subJson)
                        todayCards.append(cafe)
                    }
                    return todayCards
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    func cardListTodayV2(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/card/list/v2/today")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    
                    var todayCards: [CardModel] = []
                    for (_, subJson): (String, JSON) in json {
                        let cafe = CardModel(json: subJson)
                        todayCards.append(cafe)
                    }
                    return todayCards
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // 오늘의 카드 리스트
    func cardListLocal(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/card/list/openLocalTodayList")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    
                    var todayCards: [CardModel] = []
                    for (_, subJson): (String, JSON) in json {
                        let cafe = CardModel(json: subJson)
                        todayCards.append(cafe)
                    }
                    return todayCards
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // 오늘의 카드 더보기
    func openMoreTodayList(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/card/list/openMoreTodayList")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    var todayCards: [CardModel] = []
                    for (_, subJson): (String, JSON) in json {
                        var cafe = CardModel(json: subJson)
                        cafe.loadMainImage()
                        todayCards.append(cafe)
                    }
                    return todayCards
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
     
    func openTopTenTodayList(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/card/list/openExcellentTodayList")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    var todayCards: [CardModel] = []
                    for (_, subJson): (String, JSON) in json {
                        var cafe = CardModel(json: subJson)
                        cafe.loadMainImage()
                        todayCards.append(cafe)
                    }
                    return todayCards
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    func openMoreLocalTodayList(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/card/list/openLocalTodayList")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    var todayCards: [CardModel] = []
                    for (_, subJson): (String, JSON) in json {
                        var cafe = CardModel(json: subJson)
                        cafe.loadMainImage()
                        todayCards.append(cafe)
                    }
                    return todayCards
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    func openHiddenFavoredUser(userId: Int, reply: ReplyType, apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/card/openHiddenFavored")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: [
                    "userid": userId as AnyObject
                    ])
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return ServerDefaultResponseModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    func openHiddenFavoredUser2(userId: Int, reply: ReplyType, apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/card/list/openHiddenFavored")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: [
                    "userid": userId as AnyObject
                    ])
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return ServerDefaultResponseModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
//    func openHiddenFavoredUser(userId: Int) -> ApiRequest {
//        let apiRequest = ApiRequest(
//            ApiRequest.Builder()
//                .url(url: _app.config.apiUrl + "/card/list/openHiddenFavored")
//                .method(method:.post)
//                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
//                .parameters(parameters: ["userid":userId])
//                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
//                    if let result = json["code"].string, let resultUserId = json["userid"].string {
//                        if result == "OK" && Int(resultUserId) == userId {
//                            return true
//                        }
//                    }
//                    return false
//                })
//                .completionHandler(completionHandler:{ (apiResponse) -> () in
//                })
//        )
//        apiRequest.request()
//        return apiRequest
//    }
    
    // 카드보기
    func cardDetail(userId: Int, apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        return cardDetail(userId: userId, likeCheck: nil, apiResponseViewModel: apiResponseViewModel, loadingViewModel: loadingViewModel)
    }
    
    func cardDetail(userId: Int, likeCheck:Bool?, apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        var q = [String: AnyObject]()
        q["userid"] = "\(userId)" as AnyObject
        if likeCheck != nil {
            q["likecheck"] = "\(true)" as AnyObject
        }
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/card/view")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: q)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    var cardDetail = CardDetailModel(json: json)
                    cardDetail.profileModel?.loadImageInfoList()
                    return cardDetail
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // 카드 상세 이미지 3번째 ~ 6번째 구좌 열기 (구좌당 하트 1개)
    func cardOpenImage(userId: Int, apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/card/openImage")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: ["userid":userId as AnyObject])
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    var imageInfo = ProfileModel.ImageInfo(json: json)
                    imageInfo.loadImage()
                    return imageInfo
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    
    // 매력평가, 새로 평가해야할 카드 목록
    func cardListEvaluate(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/card/evaluate")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    if json["id"] == JSON.null {
                        return nil
                    }
                    let evaluationCards = ProfileModel(json: json)
                    return evaluationCards
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // 프로필 코드 정보
    func profileCodeInfo(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/profile/codeInfo")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    let profileCodeInfo = ProfileCodeInfoModel(json: json)
                    return profileCodeInfo
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // 프로필 정보 보기화면 (수정화면이어서 이름이 edit 이라함)
    func profileEdit(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/profile/edit")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    var profileModel = ProfileModel(json: json)
                    
                    // 이미지 로드
                    var imageInfos: [ProfileModel.ImageInfo] = []
                    profileModel.imageInfoList.forEach({ (imageInfo) -> () in
                        var i = imageInfo
                        i.loadImage()
                        imageInfos.append(i)
                    })
                    profileModel.imageInfoList = imageInfos
                    return profileModel
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // 프로필 정보 update 요청
    func profileUpdateForParametes(parametersForUpdate: [String: AnyObject], apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/profile/update")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.json)
                .parameters(parameters: parametersForUpdate)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    // 응답은 갱신된 profile 객체
                    let profileModel = ProfileModel(json: json)
                    return profileModel
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // 좋아요
    func cardLike(userId: Int, comment: String?, fromType: String?, voice: String? = nil, apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        var parameters: [String:AnyObject] = ["userid": userId as AnyObject]
        if let f = fromType {
            parameters["fromType"] = f as AnyObject
        }
        
        if let c = comment, c.length > 0 {
            parameters["comment"] = comment as AnyObject
        }
        if let v = voice {
            parameters["voice"] = v as AnyObject
        }
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/card/like")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: parameters)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return ServerDefaultResponseModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // (좋아요에 대한) 응답하기
    func cardReply(userId: Int, reply: ReplyType, apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/card/reply")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: [
                    "userid": userId as AnyObject,
                    "value": reply.rawValue as AnyObject
                    ])
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return ServerDefaultResponseModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // (호감에 대한) 응답하기
    func favorReply(userId: Int, reply: ReplyType, apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/card/replyfavor")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: [
                    "userid": userId as AnyObject
                    ])
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return ServerDefaultResponseModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // 소식, (지나간)카드 리스트
    func cardListLikeFavor(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/card/list/likefavor")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    let historiesModel = HistoriesModel(json: json)
                    return historiesModel
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // 서로 호감이 있어요 리스트
    func cardListFavorMatch(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/card/list/favormatch")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    var cards: [CardModel] = []
                    for (_, subJson): (String, JSON) in json {
                        let card = CardModel(json: subJson)
                        cards.append(card)
                    }
                    return cards
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // 나를 좋아해요 리스트
    func cardListLikeMe(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/card/list/liked")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    var cards: [CardModel] = []
                    for (_, subJson): (String, JSON) in json {
                        let card = CardModel(json: subJson)
                        cards.append(card)
                    }
                    return cards
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // 내가 좋아요 리스트
    func cardListILike(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/card/list/like")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    var cards: [CardModel] = []
                    for (_, subJson): (String, JSON) in json {
                        let card = CardModel(json: subJson)
                        cards.append(card)
                    }
                    return cards
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    
    // 당신에게 호감이 있어요
    func cardListFavorMe(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/card/list/hiddenfavored")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    var cards: [CardModel] = []
                    for (_, subJson): (String, JSON) in json {
                        let card = CardModel(json: subJson)
                        cards.append(card)
                    }
                    return cards
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // 당신이 호감이 있어요
    func cardListIFavor(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/card/list/favor")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    var cards: [CardModel] = []
                    for (_, subJson): (String, JSON) in json {
                        let card = CardModel(json: subJson)
                        cards.append(card)
                    }
                    return cards
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // 지나간 인연
    func cardListHistory(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/card/list/history")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    var cards: [CardModel] = []
                    for (_, subJson): (String, JSON) in json {
                        let card = CardModel(json: subJson)
                        cards.append(card)
                    }
                    return cards
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // 매력평가, 사용자 매력 평가 (괜찮아요, 별로에요)
    enum CardEvaluateValueType: String {
        case Good = "G"
        case Bad = "B"
        case NotBad = "N"
    }
    
    func cardEvaluate(targetUserId: Int, value: CardEvaluateValueType, apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/card/evaluate")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: [
                    "userid": targetUserId as AnyObject,
                    "value": value.rawValue as AnyObject
                    ])
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return ServerDefaultResponseModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    func openVoiceProfile(targetUserId: Int, fromType: String? = nil, apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/card/openVoiceProfile")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: [
                    "userid": targetUserId as AnyObject, "fromType": (fromType ?? "")  as AnyObject
                    ])
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return ServerDefaultResponseModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    
    
    // 대화잠금 해제
    func chatUnlock(targetUserId: Int, apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/chat/unlock")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: [
                    "userid": targetUserId as AnyObject
                    ])
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return ServerDefaultResponseModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    
    // 스토어(마켓) 리뷰, 버찌 1회 무료 지급(리뷰보상)
    func pointStoreReview(apiResponseViewModel: DViewModel<ApiResponse>?, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/point/storereview")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: [
                    "iosAppVer": _app.config.version as AnyObject
                    ])
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return PointValueModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel?.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    
    // 대화방에서 나가기
    func chatLeave(targetUserId: Int, apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/chat/leave")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: [
                    "userid": targetUserId as AnyObject
                    ])
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return ServerDefaultResponseModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // 나이 정보
    func matchTodayAge(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/profile/matchTodayAge")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    let matchTodayAgeModel = MatchTodayAgeModel(json: json)
                    return matchTodayAgeModel
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    func updateMatchTodayAge(minAge: Int, maxAge: Int, apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/profile/matchTodayAge")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: [
                    "minAge": "\(minAge)" as AnyObject, "maxAge": "\(maxAge)" as AnyObject
                    ])
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return MatchTodayAgeModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // 업데이트 정보
    func cardListNotification(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/card/list/notification")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    let cardListNotificationModel = CardListNotificationModel(json: json)
                    return cardListNotificationModel
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // 다운로드
    func download(url: String, apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: url)
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // aws s3 업로드
    // 참고 (스팩명세) : http://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-UsingHTTPPOST.html
    func s3Information(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?, index: Int? = nil) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/profile/uploadImage/s3")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    var model = S3InformationModel(json: json)
                    model.index = index
                    return model
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // S3 업로드 Operation
    func s3Upload(s3: S3InformationModel, file: Data, apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest? {
        guard let host = s3.host else {
            return nil
        }
        loadingViewModel?.model?.add()
        var parts = s3.parts
        parts.append(("file",file))
        
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: "http://\(host)")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parts(parts: parts)
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }

    func s3VoiceInformation(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/voice/uploadVoice/s3")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return S3InformationModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // S3 업로드 Operation
    func s3VoiceUpload(s3: S3InformationModel, file: Data, apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest? {
        guard let host = s3.host else {
            return nil
        }
        loadingViewModel?.model?.add()
        var parts = s3.parts
        parts.append(("file",file))
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: "http://\(host)")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parts(parts: parts)
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // 시작 녹음
    func insertStartVoice(parameter: [String: AnyObject], apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/voice/start/record")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: parameter)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return UploadVoice(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // 답변(시작) 녹음
    func replyStartVoice(parameter: [String: AnyObject], loadingViewModel: DViewModel<LoadingModel>?, onFinish:((ApiResponse?) -> Void)?) -> ApiRequest {
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/voice/replyStart/record")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: parameter)
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    loadingViewModel?.model?.del()
                    onFinish?(apiResponse)
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // 답변 녹음
    func replyVoice(parameter: [String: AnyObject], apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/voice/reply/record")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: parameter)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return ServerDefaultResponseModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // 답변 녹음 - 버찌 사용
    func replyVoiceUseBuzzie(parameter: [String: AnyObject], apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/voice/reply/record/buzzie")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: parameter)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return ServerDefaultResponseModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    func checkVoiceBuzzie(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/voice/check/buzzie")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return ServerDefaultResponseModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    func checkAvailableVoiceChat(parameter: [String: AnyObject], apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/voice/record/check")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: parameter)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return ServerDefaultResponseModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // 랜덤으로 상대방의 녹음 하나 가져오기
    func findVoinceRandomOneUser(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?, onFinish:(() -> Void)? = nil) -> ApiRequest {
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/voice/random/one")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    var userVoiceOneModel = UserVoiceOneModel(json: json)
                    userVoiceOneModel.loadMainImage()
                    return userVoiceOneModel
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                    onFinish?()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    func voiceChatRoomList(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/voice/chat/rooms")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    var voiceChatRoomModels: [VoiceChatRoomModel] = []
                    for (_, subJson): (String, JSON) in json {
                        if subJson["id"].int != nil {
                            let voiceChatRoom = VoiceChatRoomModel(json: subJson)
                            //voiceChatRoom.loadMainImage()
                            voiceChatRoomModels.append(voiceChatRoom)
                        }
                    }
                    
                    return voiceChatRoomModels
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    func voiceMyChatList(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/voice/myList")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    var voiceChatRoomModels: [VoiceChatRoomModel] = []
                    for (_, subJson): (String, JSON) in json {
                        if subJson["id"].int != nil {
                            let voiceChatRoom = VoiceChatRoomModel(json: subJson)
                            //voiceChatRoom.loadMainImage()
                            voiceChatRoomModels.append(voiceChatRoom)
                        }
                    }
                    
                    return voiceChatRoomModels
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    func voiceChatRoomCheck(parameters: [String: AnyObject]) {
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/voice/chat/room/check")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: parameters)
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                })
        )
        apiRequest.request()
    }
    
    func voiceChatList(parameters: [String: AnyObject], apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/voice/chat/voices")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: parameters)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    var voiceChatModels: [VoiceChatModel] = []
                    for (_, subJson): (String, JSON) in json {
                        print(subJson)
                        var voiceChat = VoiceChatModel(json: subJson)
                        voiceChat.loadRemainMinuteTime()
                        voiceChatModels.append(voiceChat)
                    }
                    return voiceChatModels
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
        
    }
    
    func passVoice(parameters: [String: AnyObject], apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/voice/pass")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: parameters)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return ServerDefaultResponseModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        
        apiRequest.request()
        return apiRequest
    }
    
    func passVoiceWithRoom(parameters: [String: AnyObject], apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/voice/passRoom")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: parameters)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return ServerDefaultResponseModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        
        apiRequest.request()
        return apiRequest
    }
    
    func promotionValid(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/voice/promotion/valid")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return PromotionValidUser(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    func requestHeart(voiceCloudId: String, isHeart: Bool = true, apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/voice/heart")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: ["voiceCloudId": voiceCloudId as AnyObject, "heart":(isHeart ? "true" : "false") as AnyObject])
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return ServerDefaultResponseModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    func requestOpenHeartUser(userId: Int, voiceId: String, fromType: String? = nil, apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        loadingViewModel?.model?.add()
        
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/voice/heart/userOpen")
                .method(method:.post)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: ["voiceId": "\(voiceId)" as AnyObject, "userId":"\(userId)" as AnyObject, "fromType": (fromType ?? "") as AnyObject])
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return ServerDefaultResponseModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    func voiceRank(userId: Int, apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/voice/rank/todayBest")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: ["id": "\(userId)" as AnyObject])
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return VoiceRankModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    func voiceRankList(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/voice/rank/list")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    var femaleList = [VoiceRankModel]()
                    for (_, subJson): (String, JSON) in json["F"] {
                        let voiceRank = VoiceRankModel(json: subJson)
                        femaleList.append(voiceRank)
                    }
                    
                    var maleList = [VoiceRankModel]()
                    for (_, subJson): (String, JSON) in json["M"] {
                        let voiceRank = VoiceRankModel(json: subJson)
                        maleList.append(voiceRank)
                    }
                    
                    var rankList = VoiceRankListModel()
                    rankList.femaleList = femaleList
                    rankList.maleList = maleList
                    
                    return rankList
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    func checkNewVoiceUpload(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/voice/start/free")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return ServerDefaultResponseModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
   
    func myVoiceLikedList(voiceId: String, apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/voice/heart/list")
                .method(method:.get)
                .parameters(parameters: ["id": voiceId as AnyObject])
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    var list = [VoiceLikedModel]()
                    for (_, subJson): (String, JSON) in json {
                        let voiceRank = VoiceLikedModel(json: subJson)
                        list.append(voiceRank)
                    }
                    return list
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // 다른 사람과 녹음한 목록 가져오기
    func voiceListWithPerson(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/card/list/history")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    var voices: [VoiceModel] = []
                    for (_, _): (String, JSON) in json {
                        let card = VoiceModel()
                        voices.append(card)
                    }
                    return voices
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    func checkNewNotice(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/notice/latest")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return NewNoticeModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    func clickFacebookBanner(apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?) -> ApiRequest {
        
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/point/bannerClick")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return ServerDefaultResponseModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                })
        )
        apiRequest.request()
        return apiRequest
    }
    
    // (좋아요에 대한) 응답하기
    func checkRecommendCode(code: String, apiResponseViewModel: DViewModel<ApiResponse>, loadingViewModel: DViewModel<LoadingModel>?, onFinish: @escaping ((Bool) -> Void)) -> ApiRequest {
        loadingViewModel?.model?.add()
        let apiRequest = ApiRequest(
            ApiRequest.Builder()
                .url(url: _app.config.apiUrl + "/account/check/recommendCode")
                .method(method:.get)
                .paramEncoding(paramEncoding:ApiParameterEncoding.url)
                .parameters(parameters: [
                    "code": code as AnyObject
                    ])
                .jsonToModelHandler(jsonToModelHandler:{ (req, res, json) -> ApiResponseModel? in
                    return ServerDefaultResponseModel(json: json)
                })
                .completionHandler(completionHandler:{ (apiResponse) -> () in
                    apiResponseViewModel.model = apiResponse
                    loadingViewModel?.model?.del()
                    
                    onFinish(apiResponse.statusCode != 400)
                })
        )
        apiRequest.request()
        return apiRequest
    }
}
