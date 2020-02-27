//
//  Models+JsonExtension.swift
//  DateApp
//
//  Created by ryan on 12/26/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import Foundation
import SwiftyJSON

extension ServerDefaultResponseModel {
    
    init(json: JSON) {
        code = json["code"].string
        title = json["title"].string
        description = json["description"].string
        
        self.json = json
    }
}

extension ServerSystemInformationModel {
    
    init(json: JSON) {
        self.init()
        
        status = json["status"].string
        title = json["title"].string
        description = json["description"].string
        minVersion = json["minVersion"].string
        latestVersion = json["latestVersion"].string
        url = json["url"].string
        extra = json["extra"].string
        noticeId = String(json["noticeid"].intValue)
    }
}

extension MatchTodayAgeModel {
    init(json: JSON) {
        self.init()
        
        minAge = json["minAge"].intValue
        maxAge = json["maxAge"].intValue
    }
}

extension SettingInfoModel {
    convenience init(json: JSON) {
        self.init()
        hopeKmMax = json["hopeKmMax"].int
        hopeHeightMax = json["hopeHeightMax"].int
        hopeKmMin = json["hopeKmMin"].int
        hopeBody = json["hopeBody"].int
        facebookAvoid = json["facebookAvoid"].bool
        hopeHeightMin = json["hopeHeightMin"].int
        lat = json["lat"].string
        lng = json["lng"].string
    }
    
    var parameters: [String: AnyObject] {
        var parameters: [String: AnyObject] = [:]
        
        parameters["hopeKmMax"] = hopeKmMax as AnyObject
        parameters["hopeHeightMax"] = hopeHeightMax as AnyObject
        parameters["hopeKmMin"] = hopeKmMin as AnyObject
        parameters["hopeBody"] = hopeBody as AnyObject
        parameters["facebookAvoid"] = (facebookAvoid == true ? "true" : "false")  as AnyObject
        parameters["hopeHeightMin"] = hopeHeightMin as AnyObject
        parameters["lat"] = lat as AnyObject
        parameters["lng"] = lng as AnyObject
        
        return parameters
    }
}

/*
 {
 "voice": "",
 "score": 0,
 
 "regDttm": 1518173135200,
 
 "statusName": "",
 "loggedDayCount": 0,
 
 }
 */

extension MemberModel {
    
    init(json: JSON) {
        self.init()
        if let idInt64 = json["id"].int64 {
            id = Int(idInt64)
        }else {
            id = json["id"].int
        }

        mainImageUrl = json["mainImageUrl"].string
        email = json["email"].string
        name = json["name"].string
        gender = json["gender"].string
        point = json["point"].int
        loginPoint = json["loginPoint"].int
        hometown = CodeValueModel(json: json["hometown"])
        loggedDayCount = json["loggedDayCount"].int
        voice = json["voice"].string
        if let approved = json["approvedAt"].double {
            approvedAt = Date(timeIntervalSince1970: approved / 1000)
        }
        
        if let statusString = json["status"].string, let status = MemberStatus(rawValue: statusString) {
            self.status = status
        }
    }
}

extension VoiceLikedModel {
    init(json: JSON) {
        self.init()
        profileOpened = json["profileOpened"].bool
        if let expireDate = json["expireDate"].double {
            self.expireDate = Date(timeIntervalSince1970: expireDate / 1000)
        }
        user = VoiceLikedUserModel(json: json["user"])
    }
    
    func convertCardModel() -> CardModel {
        var model = CardModel()
        model.name = self.user?.name
        model.birthDate = self.user?.birthDate
        model.mainImageUrl = self.user?.mainImageUrl
        model.id = self.user?.id
        model.status = self.user?.status
        model.hometown = self.user?.hometown
        model.gender = self.user?.gender
        model.expiredDttm = self.expireDate
        if let opened = self.profileOpened {
            model.isHidden = !opened
        }
        
        /*
        if model.isHidden == false {
            if let d = model.expiredDttm {
                model.isHidden = !(d.isFuture())
            }
        }*/
        
        return model
    }
}

extension VoiceLikedUserModel {
    init(json: JSON) {
        self.init()
        
        id = json["id"].int
        score = json["score"].int
        status = json["status"].string
        if let regDttm = json["regDttm"].double {
            self.regDttm = Date(timeIntervalSince1970:  regDttm / 1000)
        }
        birthDate = json["birthDate"].string
        statusName = json["statusName"].string
        mainImageUrl = json["mainImageUrl"].string
        loggedDayCount = json["loggedDayCount"].int
        hometown = CodeValueModel(json: json["hometown"])
        point = json["point"].int
        
        email = json["email"].string
        name = json["name"].string
        gender = json["gender"].string
    }
}

extension CardModel {
    init(json: JSON) {
        self.init()
        id = json["id"].int
        name = json["name"].string
        birthDate = json["birthDate"].string
        gender = json["gender"].string
        bloodType = CodeValueModel(json: json["bloodType"])
        hometown = CodeValueModel(json: json["hometown"])
        religion = CodeValueModel(json: json["religion"])
        job = CodeValueModel(json: json["job"])
        bodyType = CodeValueModel(json: json["bodyType"])
        height = json["height"].float
        school = json["school"].string
        status = json["status"].string
        grade = json["grade"].string
        score = json["score"].float
        isILike = json["isILike"].bool
        isHidden = json["isHidden"].bool
        newlikecheck = json["newLikeCheck"].boolValue
        likeMeVoiceMessage = json["likeMeVoiceMessage"].string
        
        
        if isHidden != nil {
            print("")
        }
        if let reply = json["reply"].string, let replyType = ReplyType(rawValue: reply) {
            self.reply = replyType
        }
        isLikeMe = json["isLikeMe"].bool
        isLikeCheck = json["likecheck"].boolValue
    
        likeMeMessage = json["likeMeMessage"].string
        if let joinDate = json["joinDate"].double {
            self.joinDate = Date(timeIntervalSince1970:  joinDate / 1000)
        }
        if let updateDate = json["updateDate"].double {
            self.updateDate = Date(timeIntervalSince1970:  updateDate / 1000)
        }
        mainImageUrl = json["mainImageUrl"].string
        
        if let expiredDttm = json["expiredDttm"].double {
            self.expiredDttm = Date(timeIntervalSince1970:  expiredDttm / 1000)
        }
        
        if let likeCheckedAt = json["likeCheckedAt"].double {
            self.likeCheckedAt = Date(timeIntervalSince1970:  likeCheckedAt / 1000)
        }
        
        if likeCheckedAt != nil {
            //isLikeCheck = true
        }
    }
    
    var summary: String {
        var summary = birthDate?.ageFromBirthDate ?? ""
        if let hometown = hometown?.value {
            if summary != "" {
                summary += ", "
            }
            summary += hometown
        }
        if let job = job?.value {
            if summary != "" {
                summary += ", "
            }
            summary += job
        }
        return summary
    }
}

extension CardDetailModel {
    init(json: JSON) {
        self.init()
        profileModel = ProfileModel(json: json)
        isILike = json["isILike"].bool
        isLikeMe = json["isLikeMe"].bool
        isLikeCheck = json["likeCheck"].boolValue
        meterDistance = json["distance"].float
        likeMeMessage = json["likeMeMessage"].string
        likeMeVoiceMessage = json["likeMeVoiceMessage"].string
        
        if let reply = json["reply"].string, let replyType = ReplyType(rawValue: reply) {
            self.reply = replyType
        }
 
        if let likeCheckedAt = json["likeCheckedAt"].double {
            self.likeCheckedAt = Date(timeIntervalSince1970:  likeCheckedAt / 1000)
        }
        
        if likeCheckedAt != nil {
            //isLikeCheck = true
        }
    }
}

extension ProfileModel {
    init(json: JSON) {
        self.init()
        
        id = json["id"].int
        name = json["name"].string
        imageId = json["imageid"].int
        urlPath = json["urlpath"].string
        birthDate = json["birthDate"].string
        gender = json["gender"].string
        idealType = CodeValueModel(json: json["idealType"])
        bloodType = CodeValueModel(json: json["bloodType"])
        hometown = CodeValueModel(json: json["hometown"])
        religion = CodeValueModel(json: json["religion"])
        job = CodeValueModel(json: json["job"])
        bodyType = CodeValueModel(json: json["bodyType"])
        height = json["height"].float
        school = json["school"].string
        favorMatch = json["favorMatch"].bool
        voiceUrl = json["voice"].string
        
        if let statusString = json["status"].string, let status = MemberStatus(rawValue: statusString) {
            self.status = status
        }
        score = json["score"].float
        if let joinDttm = json["joinDttm"].double {
            self.joinDttm = Date(timeIntervalSince1970:  joinDttm / 1000)
        }
        if let updateDttm = json["updateDttm"].double {
            self.updateDttm = Date(timeIntervalSince1970:  updateDttm / 1000)
        }
        reviewStatus = json["reviewStatus"].string
        reviewMessage = json["reviewMessage"].string
        _mainImageUrl = json["mainImageUrl"].string
        for (_, subJson): (String, JSON) in json["imageInfoList"] {
            let imageInfo = ImageInfo(json: subJson)
            imageInfoList.append(imageInfo)
        }
        
        let addMoreValue = CodeValueModel(code: "", value: "더보기")
        for (_, subJson): (String, JSON) in json["hobbyList"] {
            let codeValue = CodeValueModel(json: subJson)
            hobbyCode.append(codeValue)
        }
        hobbyCode.append(addMoreValue)
        
        if gender == "F" {
            for (_, subJson): (String, JSON) in json["charmTypeList"] {
                let codeValue = CodeValueModel(json: subJson)
                charmFTypeCode.append(codeValue)
            }
            charmFTypeCode.append(addMoreValue)
        }else {
            for (_, subJson): (String, JSON) in json["charmTypeList"] {
                let codeValue = CodeValueModel(json: subJson)
                charmMTypeCode.append(codeValue)
            }
            charmMTypeCode.append(addMoreValue)
        }
        
        for (_, subJson): (String, JSON) in json["favoriteTypeList"] {
            let codeValue = CodeValueModel(json: subJson)
            favoriteTypeCode.append(codeValue)
        }
        favoriteTypeCode.append(addMoreValue)
    }
    
    var summary: String {
        var summary = birthDate?.ageFromBirthDate ?? ""
        if let hometown = hometown?.value {
            if summary != "" {
                summary += ", "
            }
            summary += hometown
        }
        if let job = job?.value {
            if summary != "" {
                summary += ", "
            }
            summary += job
        }
        return summary
    }

}

extension ProfileModel.ImageInfo {
    init(json: JSON) {
        self.init()
        hidden = json["hidden"].bool
        imageId = json["imageid"].int
        urlPath = json["urlpath"].string
        ordering = json["ordering"].int
        imageUrl = json["imageUrl"].string
        largeImageUrl = json["largeImageUrl"].string
    }
}

extension HistoriesModel {
    init(json: JSON) {
        self.init()
        for (_, subJson): (String, JSON) in json["likeMeCards"] {
            let cardModel = CardModel(json: subJson)
            likeMeCards.append(cardModel)
        }
        for (_, subJson): (String, JSON) in json["ILikeCards"] {
            let cardModel = CardModel(json: subJson)
            iLikeCards.append(cardModel)
        }
        for (_, subJson): (String, JSON) in json["favorMeCards"] {
            let cardModel = CardModel(json: subJson)
            favorMeCards.append(cardModel)
        }
        for (_, subJson): (String, JSON) in json["IfavorCards"] {
            let cardModel = CardModel(json: subJson)
            ifavorCards.append(cardModel)
        }
        for (_, subJson): (String, JSON) in json["historyCards"] {
            let cardModel = CardModel(json: subJson)
            historyCards.append(cardModel)
        }
        for (_, subJson): (String, JSON) in json["favorMeHiddenCards"] {
            let cardModel = CardModel(json: subJson)
            favorMeHiddenCards.append(cardModel)
        }
        for (_, subJson): (String, JSON) in json["favorMatchCards"] {
            let cardModel = CardModel(json: subJson)
            favorMatchCards.append(cardModel)
        }
    }
}

extension NextDttmModel {
    init(json: JSON) {
        self.init()
        if let nextDttm = json["nextDttm"].double {
            self.nextDttm = Date(timeIntervalSince1970:  nextDttm / 1000)
        }
    }
}

extension EvaluationCardsModel {
    init(json: JSON) {
        self.init()
        if let nextDttm = json["nextDttm"].double {
            self.nextDttm = Date(timeIntervalSince1970:  nextDttm / 1000)
        } else if let nextDttmString = json["nextDttm"].string, let nextDttm = Double(nextDttmString) {
            self.nextDttm = Date(timeIntervalSince1970:  nextDttm / 1000)
        }
        for (_, subJson): (String, JSON) in json["list"] {
            let cardModel = CardModel(json: subJson)
            list.append(cardModel)
        }
    }
}

extension CardListNotificationModel {
    init(json: JSON) {
        self.init()
        evaluateCount = json["evaluateCount"].int
        likeMeCount = json["likeMeCount"].int
    }
}

extension CodeValueModel {
    init(json: JSON) {
        code = json["code"].string
        value = json["value"].string
        extra = json["extra"].string
    }
}

extension ProfileCodeInfoModel {
    init(json: JSON) {
        self.init()
        
        for (_, subJson): (String, JSON) in json["bloodTypeCode"] {
            let codeValue = CodeValueModel(json: subJson)
            bloodTypeCode.append(codeValue)
        }
        for (_, subJson): (String, JSON) in json["hometownCode"] {
            let codeValue = CodeValueModel(json: subJson)
            hometownCode.append(codeValue)
        }
        for (_, subJson): (String, JSON) in json["religionCode"] {
            let codeValue = CodeValueModel(json: subJson)
            religionCode.append(codeValue)
        }
        for (_, subJson): (String, JSON) in json["bodyMTypeCode"] {
            let codeValue = CodeValueModel(json: subJson)
            bodyMTypeCode.append(codeValue)
        }
        for (_, subJson): (String, JSON) in json["bodyFTypeCode"] {
            let codeValue = CodeValueModel(json: subJson)
            bodyFTypeCode.append(codeValue)
        }
        for (_, subJson): (String, JSON) in json["jobCode"] {
            let codeValue = CodeValueModel(json: subJson)
            jobCode.append(codeValue)
        }
        for (_, subJson): (String, JSON) in json["idealMTypeCode"] {
            let codeValue = CodeValueModel(json: subJson)
            idealMTypeCode.append(codeValue)
        }
        for (_, subJson): (String, JSON) in json["idealFTypeCode"] {
            let codeValue = CodeValueModel(json: subJson)
            idealFTypeCode.append(codeValue)
        }
        
        for (_, subJson): (String, JSON) in json["hobbyCode"] {
            let codeValue = CodeValueModel(json: subJson)
            hobbyCode.append(codeValue)
        }
        
        for (_, subJson): (String, JSON) in json["charmFTypeCode"] {
            let codeValue = CodeValueModel(json: subJson)
            charmFTypeCode.append(codeValue)
        }
        
        for (_, subJson): (String, JSON) in json["charmMTypeCode"] {
            let codeValue = CodeValueModel(json: subJson)
            charmMTypeCode.append(codeValue)
        }
        
        for (_, subJson): (String, JSON) in json["favoriteTypeCode"] {
            let codeValue = CodeValueModel(json: subJson)
            favoriteTypeCode.append(codeValue)
        }
    }
}

extension PointValueModel {
    init(json: JSON) {
        self.init()
        point = json["point"].int
    }
}

extension PointLogModel {
    init(json: JSON) {
        self.init()
        
        id = json["id"].int
        userId = json["userid"].int
        code = json["code"].string
        description = json["description"].string
        pointDiff = json["pointdiff"].int
        adjustPoint = json["adjustpoint"].int
        if let regDttm = json["regDttm"].double {
            self.regDttm = Date(timeIntervalSince1970:  regDttm / 1000)
        }
    }
}

extension S3InformationModel {
    init(json: JSON) {
        self.init()
        xAmzMetaUuid = json["x-amz-meta-uuid"].string
        xAmzAlgorithm = json["X-Amz-Algorithm"].string
        acl = json["acl"].string
        host = json["Host"].string
        contentType = json["Content-Type"].string
        xAmzDate = json["X-Amz-Date"].string
        policy = json["Policy"].string
        xAmzSignature = json["X-Amz-Signature"].string
        uploadImagePath = json["uploadImagePath"].string
        xAmzCredential = json["X-Amz-Credential"].string
        key = json["key"].string
    }
}

extension UserVoiceOneModel {
    init(json: JSON) {
        self.init()
        userId = json["userid"].int
        heartCount = json["heartCount"].int
        voiceCloudId = json["voicecloudid"].stringValue
        imageUrlPath = json["imageurlpath"].string
        userName = json["username"].string
        voiceUriPath = json["voiceuripath"].string
        profileOpened = json["profileOpened"].bool
        isHearted = json["heart"].bool
    }
}

extension UploadVoice {
    init(json: JSON) {
        self.init()
        if let updateTime = json["updateTime"].double {
            //self.updateTime = Date(timeIntervalSince1970:  updateTime / 1000)
            self.updateTime = updateTime / 1000
        }
    }
}

extension PromotionValidUser {
    init(json: JSON) {
        self.init()
        self.recipient = json["recipient"].bool
    }
}

extension NewNoticeModel {
    init(json: JSON) {
        self.init()
        self.id = json["id"].int
    }
}
extension VoiceRankModel {
    init(json: JSON) {
        self.init()
        
        name = json["name"].string
        userId = json["userId"].int
        id = String(json["id"].intValue)
        profileImageUrl = json["profileImageUrl"].string
        heart = json["heart"].boolValue
        highestRank = json["highestRank"].int
        heartCount = json["heartCount"].int
        if let createdAt = json["createdAt"].double {
            self.createdAt = Date(timeIntervalSince1970:  createdAt / 1000)
        }
        voicePath = json["voicePath"].string
    }
}

extension VoiceChatRoomModel {
    init(json: JSON) {
        self.init()
        userId = json["userId"].int
        id = String(json["id"].intValue)
        largeImageUrl = json["largeImageUrl"].string
        name = json["name"].string
        isNew = json["new"].boolValue
        count = "\(json["count"].intValue)"
        profileOpened = json["profileOpened"].bool
        
        if let time = json["remainTime"].string {
            remainTime = Double(time)
        }else {
            remainTime = NSDate().timeIntervalSince1970
        }
        
        if let modifiedAt = json["modifiedat"].double {
            self.modifiedAt = Date(timeIntervalSince1970:  modifiedAt / 1000)
        }
        
        profileImageUrl = json["profileImageUrl"].string
        heartCount = json["heartCount"].int
        if let createdAt = json["createdAt"].double {
            self.createdAt = Date(timeIntervalSince1970:  createdAt / 1000)
        }
        voicePath = json["voicePath"].string
    }
}

extension VoiceChatModel {
    init(json: JSON) {
        self.init()
        userId = json["id"].int
        voiceUrl = json["voiceUrl"].string
        name = json["name"].string
        profileOpened = json["profileOpened"].bool
        if let time = json["remainTime"].string {
            remainTime = Double(time)
        }else {
            remainTime = NSDate().timeIntervalSince1970
        }
        
        if let modifiedAt = json["createdat"].double {
            self.modifiedAt = Date(timeIntervalSince1970:  modifiedAt / 1000)
        }
        
        isLast = json["last"].bool
        order = json["order"].int
    }
}

