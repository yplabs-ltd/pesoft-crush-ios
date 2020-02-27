//
//  AddressBookModel.swift
//  DateApp
//
//  Created by ryan on 12/18/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

// 서버 에러코드 참조: https://bitbucket.org/pesoft/crush-for-server/wiki/Home#markdown-header-_5
struct ServerDefaultResponseModel {
    var code: String?
    var title: String?
    var description: String?
    var json: JSON?
    
    init(code: String?, title: String?, description: String?, json: JSON? = nil) {
        self.code = code
        self.title = title
        self.description = description
        self.json = json
    }
}

struct ServerSystemInformationModel {
    var status: String?
    var title: String?
    var description: String?
    var minVersion: String?
    var latestVersion: String?
    var url: String?
    var extra: String?
    var noticeId: String?
}

struct MatchTodayAgeModel {
    var minAge: Int?
    var maxAge: Int?
}

class SettingInfoModel {
    var hopeKmMax: Int?
    var hopeHeightMax: Int?
    var hopeKmMin: Int?
    var hopeBody: Int?
    var facebookAvoid: Bool?
    var hopeHeightMin: Int?
    var lat: String?
    var lng: String?
}


struct MemberModel {
    var id: Int?
    var mainImageUrl: String?
    var email: String?
    var name: String?
    var gender: String?
    var point: Int?
    var loginPoint: Int?
    var status: MemberStatus?
    var hometown: CodeValueModel?
    var mainImage: UIImage? // from mainImageUrl
    var loggedDayCount: Int?
    var voice: String?
    var approvedAt: Date?
    
    mutating func loadMainImage() {
        if let mainImageUrl = mainImageUrl, let url = URL(string: mainImageUrl) {
            do {
                let data = try Data(contentsOf: url)
                mainImage = UIImage(data: data)
            }catch {
                
            }
        }
    }
    
}

enum MemberStatus: String {
    case Preview = "P"    // 가입만 한 상태, 미리보기중
    case Waiting = "W"    // 프로필 최초심사중
    case Blocked = "B"    // 차단 (신고나 기타 사유에 의해 차단된 ID)
    case Deleted = "D"    // 삭제 (앱에서는 받아볼 수 없음. 무시해도 됨)
    case Normal = "N"     // 정상 회원. 추가 회원 정보 입력까지 완료 (소개풀에도 등록)
}

// null (진행중), "A" 성공 (응답OK), "R" 실패 (거절)
enum ReplyType: String {
    case Unknown = ""
    case Accept = "A"
    case Reject = "R"
}

struct CardModel {
    var id: Int?
    var name: String?
    var birthDate: String?  // 나이 (YYYY-MM-DD)
    var gender: String?
    var bloodType: CodeValueModel?
    var hometown: CodeValueModel?
    var religion: CodeValueModel?
    var job: CodeValueModel?
    var bodyType: CodeValueModel?
    var height: Float?
    var school: String?
    var status: String?
    var grade: String?
    var score: Float?
    var isILike: Bool?
    var reply = ReplyType.Unknown
    var isLikeMe: Bool?
    var likeMeMessage: String?
    var joinDate: Date?
    var updateDate: Date?
    var mainImageUrl: String?
    var mainImage: UIImage?
    var isHidden: Bool?
    var expiredDttm: Date?
    var isLikeCheck: Bool!
    var likeCheckedAt: Date?
    var newlikecheck: Bool!
    var likeMeVoiceMessage: String?
    
    mutating func loadMainImage() {
        if let mainImageUrl = mainImageUrl, let url = URL(string: mainImageUrl) {
            do {
                let data = try Data(contentsOf: url)
                mainImage = UIImage(data: data)
            }catch {
                print("Error Load Image")
            }
            
        }
    }
}

struct CardDetailModel {
    var profileModel: ProfileModel?
    var isILike: Bool?
    var isLikeMe: Bool?
    var likeMeMessage: String?
    var likeMeVoiceMessage: String?
    var reply = ReplyType.Unknown
    var isLikeCheck: Bool!
    var meterDistance: Float?
    var likeCheckedAt: Date?
    var distance: String? {
        get {
            guard let m = meterDistance else {
                return nil
            }
            if m < 5000 {
                return "1km 이내"
            }else if m >= 5000 && m < 10000 {
                return "5km 이내"
            }else if m >= 10000 && m < 20000 {
                return "10km 이내"
            }else if m >= 20000 && m < 30000 {
                return "20km 이내"
            }else if m >= 30000 && m < 50000 {
                return "30km 이내"
            }else if m >= 50000 && m < 70000 {
                return "50km 이내"
            }else if m >= 70000 && m < 100000 {
                return "70km 이내"
            }else if m >= 100000 {
                return "100km 이내"
            }
            /*else if m >= 100000 && m < 150000 {
                return "100km 이내"
            }
            else if m >= 150000 && m < 200000 {
                return "150km 이내"
            }else if m >= 200000 && m < 300000 {
                return "200km 이내"
            }else if m >= 300000 && m < 500000 {
                return "300km 이내"
            }else if m >= 500000 {
                return "500km 이내"
            }*/else {
                return String(format: "%.1f", m / 1000) + "km 이내"
            }
        }
    }
}

struct ProfileModel {
    var id: Int?
    var name: String?
    var imageId: Int?
    var urlPath: String?
    var birthDate: String?
    var gender: String?
    var idealType: CodeValueModel?
    var bloodType: CodeValueModel?
    var hometown: CodeValueModel?
    var religion: CodeValueModel?
    var job: CodeValueModel?
    var bodyType: CodeValueModel?
    var height: Float?
    var school: String?
    var status: MemberStatus?
    var score: Float?
    var joinDttm: Date?
    var updateDttm: Date?
    var reviewStatus: String?
    var reviewMessage: String?
    var _mainImageUrl: String?
    
    var imageInfoList: [ImageInfo] = []
    var favorMatch: Bool?
    var voiceUrl: String?
    
    var hobbyCode: [CodeValueModel] = []
    var charmFTypeCode: [CodeValueModel] = []
    var charmMTypeCode: [CodeValueModel] = []
    var favoriteTypeCode: [CodeValueModel] = []
    
    mutating func loadImageInfoList() {
        for (index, _) in imageInfoList.enumerated() {
            imageInfoList[index].loadImage()
        }
    }
    
    struct ImageInfo {
        
        var imageId: Int?
        var urlPath: String?
        var ordering: Int?
        var imageUrl: String?
        var largeImageUrl: String?
        
        // addition
        var image: UIImage?
        
        var hidden: Bool?
        
        mutating func loadImage() {
            if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
                do {
                    let data = try Data(contentsOf: url)
                    image = UIImage(data: data)
                }catch {
                    print("Load Image Error")
                }
            }
        }
    }
    
    var mainImageUrl: String? {
        return _mainImageUrl ?? firstImageUrl
    }
    
    var firstImageUrl: String? {
        get {
            return imageInfoList.first?.imageUrl
        }
    }
}

extension ProfileModel.ImageInfo: Equatable {}
func ==(info1: ProfileModel.ImageInfo, info2: ProfileModel.ImageInfo) -> Bool {
    return (info1.imageId == info2.imageId
        && info1.urlPath == info2.urlPath
        && info1.ordering == info2.ordering
        && info1.imageUrl == info2.imageUrl
        && info1.largeImageUrl == info2.largeImageUrl)
}

struct CodeValueModel {
    var code: String?
    var value: String?
    var extra: String?
    
    init(code: String, value: String) {
        self.code = code
        self.value = value
    }
}

struct ProfileCodeInfoModel {
    var bloodTypeCode: [CodeValueModel] = []
    var hometownCode: [CodeValueModel] = []
    var religionCode: [CodeValueModel] = []
    var bodyMTypeCode: [CodeValueModel] = []
    var bodyFTypeCode: [CodeValueModel] = []
    var jobCode: [CodeValueModel] = []
    var idealMTypeCode: [CodeValueModel] = []
    var idealFTypeCode: [CodeValueModel] = []
    var hobbyCode: [CodeValueModel] = []
    var charmFTypeCode: [CodeValueModel] = []
    var charmMTypeCode: [CodeValueModel] = []
    var favoriteTypeCode: [CodeValueModel] = []
}

struct PointValueModel {
    var point: Int?
}

struct PointLogModel {
    var id: Int?
    var userId: Int?
    var code: String?
    var description: String?
    var pointDiff: Int?
    var adjustPoint: Int?
    var regDttm: Date?
}

struct UrlDataModel {
    var url: String
    var data: NSData?
    
    init(url: String) {
        self.url = url
    }
}

struct OneSignalTags {
    var userId: Int?
    var enableCard: Bool?
    var enableChat: Bool?
    var enableLike: Bool?
    var waitEvaluate: Bool?
    
    init () {
    }
    
    init (tags: [String: String]) {
        if let userIdString = tags["userId"], let userId = Int(userIdString) {
            self.userId = userId
        }
        if let stringValue = tags["enableCard"], let boolValue = stringValue.boolValue {
            enableCard = boolValue
        }
        if let stringValue = tags["enableChat"], let boolValue = stringValue.boolValue {
            enableChat = boolValue
        }
        if let stringValue = tags["enableLike"], let boolValue = stringValue.boolValue {
            enableLike = boolValue
        }
        
        if let stringValue = tags["waitEvaluate"], let boolValue = stringValue.boolValue {
            waitEvaluate = boolValue
        }
    }
    
    var dictionary: [String: String] {
        var dict: [String: String] = [:]
        if let userId = userId {
            dict["userId"] = "\(userId)"
        } else {
            dict["userId"] = ""
        }
        if let enableCard = enableCard {
            dict["enableCard"] = "\(enableCard)"
        } else {
            dict["enableCard"] = ""
        }
        if let enableChat = enableChat {
            dict["enableChat"] = "\(enableChat)"
        } else {
            dict["enableChat"] = ""
        }
        if let enableLike = enableLike {
            dict["enableLike"] = "\(enableLike)"
        } else {
            dict["enableLike"] = ""
        }
        if let waitEvaluate = waitEvaluate {
            dict["waitEvaluate"] = "\(waitEvaluate)"
        } else {
            dict["waitEvaluate"] = ""
        }
        return dict
    }
}

struct S3InformationModel {
    var xAmzMetaUuid: String?
    var xAmzAlgorithm: String?
    var acl: String?
    var host: String?
    var contentType: String?
    var xAmzDate: String?
    var policy: String?
    var xAmzSignature: String?
    var uploadImagePath: String?
    var xAmzCredential: String?
    var key: String?
    var urlPath: String?
    var index: Int?
    
    var parts: [(name: String, value: Data)] {
        var parts: [(name: String, value: Data)] = []
        /*
        if let xAmzSignature = xAmzSignature?.data(using: String.Encoding.utf8) {
            parts.append(("X-Amz-Signature", xAmzSignature))
        }
        if let key = key?.data(using: String.Encoding.utf8) {
            parts.append(("key", key))
        }
        if let acl = acl?.data(using: String.Encoding.utf8) {
            parts.append(("acl", acl))
        }
        if let contentType = contentType?.data(using: String.Encoding.utf8) {
            parts.append(("Content-Type", contentType))
        }
        if let xAmzMetaUuid = xAmzMetaUuid?.data(using: String.Encoding.utf8) {
            parts.append(("x-amz-meta-uuid", xAmzMetaUuid))
        }
        if let xAmzCredential = xAmzCredential?.data(using: String.Encoding.utf8) {
            parts.append(("X-Amz-Credential", xAmzCredential))
        }
        if let xAmzAlgorithm = xAmzAlgorithm?.data(using: String.Encoding.utf8) {
            parts.append(("X-Amz-Algorithm", xAmzAlgorithm))
        }
        if let xAmzDate = xAmzDate?.data(using: String.Encoding.utf8) {
            parts.append(("X-Amz-Date", xAmzDate))
        }
        if let policy = policy?.data(using: String.Encoding.utf8) {
            parts.append(("Policy", policy))
        }*/
        
        if let xAmzSignature = xAmzSignature?.data(using: String.Encoding.utf8) {
            let x = "4e04f68fc4aaab8d71e966ddef6da36f9dcfa5da2a304d9229748454cdd088fd"
            parts.append(("X-Amz-Signature", x.data(using: String.Encoding.utf8)!))
        }
        if let key = key?.data(using: String.Encoding.utf8) {
            let x = "image/30_395e7725-40c4-4a93-8bac-4354f84bf50f.jpg"
            parts.append(("key", x.data(using: String.Encoding.utf8)!))
        }
        if let acl = acl?.data(using: String.Encoding.utf8) {
            let x = "public-read"
            parts.append(("acl", x.data(using: String.Encoding.utf8)!))
        }
        if let contentType = contentType?.data(using: String.Encoding.utf8) {
            let x = "image/jpeg"
            parts.append(("Content-Type", x.data(using: String.Encoding.utf8)!))
        }
        if let xAmzMetaUuid = xAmzMetaUuid?.data(using: String.Encoding.utf8) {
            let x = "75bd6c6a-0ed9-48f8-8fd0-ff47dbdcc1e9"
            parts.append(("x-amz-meta-uuid", x.data(using: String.Encoding.utf8)!))
        }
        if let xAmzCredential = xAmzCredential?.data(using: String.Encoding.utf8) {
            let x = "AKIAJPHFZWCKOY7RZZJA/20180804/ap-northeast-2/s3/aws4_request"
            parts.append(("X-Amz-Credential", x.data(using: String.Encoding.utf8)!))
        }
        if let xAmzAlgorithm = xAmzAlgorithm?.data(using: String.Encoding.utf8) {
            let x = "AWS4-HMAC-SHA256"
            parts.append(("X-Amz-Algorithm", x.data(using: String.Encoding.utf8)!))
        }
        if let xAmzDate = xAmzDate?.data(using: String.Encoding.utf8) {
            let x = "20180804T232249Z"
            parts.append(("X-Amz-Date", x.data(using: String.Encoding.utf8)!))
        }
        if let policy = policy?.data(using: String.Encoding.utf8) {
            let x = "eyAiZXhwaXJhdGlvbiI6ICIyMDE4LTA4LTA1VDAxOjIyOjQ5WiIsImNvbmRpdGlvbnMiOiBbeyJidWNrZXQiOiAiaGVsbG92b2ljZWJ1Y2tldCJ9LCBbInN0YXJ0cy13aXRoIiwgIiRrZXkiLCAiaW1hZ2UvMzBfMzk1ZTc3MjUtNDBjNC00YTkzLThiYWMtNDM1NGY4NGJmNTBmLmpwZyJdLHsiYWNsIjogInB1YmxpYy1yZWFkIn0sIFsic3RhcnRzLXdpdGgiLCAiJENvbnRlbnQtVHlwZSIsICJpbWFnZS9qcGVnIl0sIHsieC1hbXotbWV0YS11dWlkIjogIjc1YmQ2YzZhLTBlZDktNDhmOC04ZmQwLWZmNDdkYmRjYzFlOSJ9LCB7IngtYW16LUNSRURFTlRJQUwiOiAiQUtJQUpQSEZaV0NLT1k3UlpaSkEvMjAxODA4MDQvYXAtbm9ydGhlYXN0LTIvczMvYXdzNF9yZXF1ZXN0In0sIHsieC1hbXotYWxnb3JpdGhtIjogIkFXUzQtSE1BQy1TSEEyNTYifSx7IngtYW16LWRhdGUiOiAiMjAxODA4MDRUMjMyMjQ5WiJ9LFsiY29udGVudC1sZW5ndGgtcmFuZ2UiLCAwLCAyMDk3MTUyXV19"
            parts.append(("Policy", x.data(using: String.Encoding.utf8)!))
        }
        
        return parts
    }
}

struct SelectItemModel {
    var name: String
    var value: String
    var children: [SelectItemModel]?
    var childrenHidden = true
    var extra: String?  // parent value 을 넣자 (일반 의사 이런 표현을 위함)
    
    init(name: String, value: String, children: [SelectItemModel]?) {
        self.name = name
        self.value = value
        
        if let children = children {
            var childrenWithParent: [SelectItemModel] = []
            children.forEach({ (child) -> () in
                var childWithParent = child
                childWithParent.extra = value   // 부모의 value extra 에 세팅해서 활용
                childrenWithParent.append(childWithParent)
            })
            self.children = childrenWithParent
        }
    }
}

struct NextDttmModel {
    var nextDttm: Date?
}

struct EvaluationCardsModel {
    var nextDttm: Date?
    var list: [CardModel] = []
}

struct VoiceModel {
    var urlPath: String?
    var userId: Int?
    var otherUserId: Int?
    var otherVoiceCloudId: String?
    var voiceChatRoomId: String?
}

struct UploadVoice {
    var updateTime: Double?
}

struct StoryCardsModel {
    var nextDttm: Date?
    var list: [VoiceModel] = []
}

struct VoiceRankModel {
    var name: String?
    var profileImageUrl: String?
    var highestRank: Int?
    var id: String?
    var heart: Bool?
    var voicePath: String?
    var userId: Int?
    var createdAt: Date?
    var heartCount: Int?
    
    func convertToVoiceOneModel() -> UserVoiceOneModel {
        var model = UserVoiceOneModel()
        model.heartCount = self.heartCount
        model.voiceCloudId = self.id
        model.userId = self.userId
        model.userName = self.name
        model.imageUrlPath = self.profileImageUrl
        model.profileOpened = false
        model.voiceUriPath = self.voicePath
        model.isHearted = self.heart
        
        return model
    }
}

struct VoiceRankListModel {
    var femaleList: [VoiceRankModel]?
    var maleList: [VoiceRankModel]?
}

struct VoiceLikedModel {
    var profileOpened: Bool?
    var expireDate: Date?
    var user : VoiceLikedUserModel?
}

struct VoiceLikedUserModel {
    var id: Int?
    var score: Int?
    var status: String?
    var regDttm: Date?
    var birthDate: String?  // 나이 (YYYY-MM-DD)
    var statusName: String?
    var mainImageUrl: String?
    var hometown: CodeValueModel?
    var loggedDayCount: Int?
    var point: Int?
    var email: String?
    var name: String?
    var gender: String?
}

struct VoiceChatRoomModel {
    var userId: Int?
    var id: String?
    var largeImageUrl: String?
    var profileImageUrl: String?
    var heartCount: Int?
    var name: String?
    var isNew: Bool?
    var count: String?
    var modifiedAt: Date?
    var createdAt: Date?
    var voicePath: String?
    var remainTime: Double?
    var remainHourTime: String?
    var remainDayTime: String?
    var image: UIImage?
    var blurImage: UIImage?
    var profileOpened: Bool?
    
    func convertVoiceRankModel() -> VoiceRankModel {
        var model = VoiceRankModel()
        model.id = self.id
        
        model.name = self.name
        model.profileImageUrl = self.profileImageUrl
        model.voicePath = self.voicePath
        model.createdAt = self.createdAt
        model.userId = self.userId
        model.heartCount = self.heartCount
        
        return model
    }
    
    mutating func loadRemainDayTime() {
        let day = (Int(remainTime!) / 24)
        if day == 0 {
            remainDayTime = "D-DAY"
        } else {
            remainDayTime = "D-\(day)"
        }
        
    }
    
    mutating func loadRemainHourTime() {
        guard let r = remainTime else { return }
        
        if r < Double(1) {
            remainHourTime = "방금전"
        } else if r < Double(24) {
            remainHourTime = String(Int(remainTime!)) + "시간전"
        } else {
            let day = Int(remainTime!) / 24
            let hour = Int(remainTime!) % 24
            remainHourTime = String(day) + "일 " + String(hour) + "시간전"
        }
    }
    
    mutating func loadMainImage() {
        if let imageUrlPath = largeImageUrl, let url = URL(string: imageUrlPath) {
            do {
                let data = try Data(contentsOf: url)
                image = UIImage(data: data)
            }catch {
                print("error load image")
            }
        }
    }
    
    mutating func loadBlurImage() -> UIImage? {
        if blurImage == nil {
            blurImage = image?.applyHeavyDarkEffect()
        }
        
        return blurImage
    }
}

struct VoiceChatModel {
    var userId: Int?
    var remainTime: Double?
    var name: String?
    var voiceUrl: String?
    var voice: Data?
    var remainHourTime: String?
    var isLast: Bool?
    var order: Int?
    var modifiedAt: Date?
    var profileOpened: Bool?
    
    mutating func loadVideo() {
        if let voiceUrlPath = voiceUrl, let url = URL(string: voiceUrlPath) {
            do {
                let data = try Data(contentsOf: url)
                voice = data
            }catch {
                print("Error Load Voice")
            }
        }
    }
    
    mutating func loadRemainMinuteTime() {
        guard let r = remainTime else { return }
        if r < 1 {
            remainHourTime = "방금전"
        } else if r < 24 {
            remainHourTime = String(Int(remainTime!)) + "시간전"
        } else {
            let day = Int(remainTime!) / 24
            remainHourTime = String(day) + "일전"
        }
    }
}

struct UserVoiceOneModel {
    var userId: Int?
    var voiceCloudId: String?
    var imageUrlPath: String?
    var userName: String?
    var voiceUriPath: String?
    var image: UIImage?
    var profileOpened: Bool?
    var heartCount: Int?
    var isHearted: Bool?
    
    mutating func loadMainImage() {
        if let imageUrlPath = imageUrlPath, let url = URL(string: imageUrlPath) {
            do {
                let data = try Data(contentsOf: url)
                image = UIImage(data: data)
            }catch {
                print("Error load Image")
            }
        }
    }
}



struct PassVoiceModel {
    var voiceChatRoomId: String?
    var voiceCloudId: String?
    var passType : String?
    
}

struct CardListNotificationModel {
    var evaluateCount: Int?
    var likeMeCount: Int?
}

struct HistoriesModel {
    var favorMatchCards: [CardModel] = []
    var likeMeCards: [CardModel] = []
    var iLikeCards: [CardModel] = []
    var favorMeCards: [CardModel] = []
    var ifavorCards: [CardModel] = []
    var historyCards: [CardModel] = []
    var favorMeHiddenCards: [CardModel] = []
    
    mutating func loadMainImages() {
        favorMatchCards = favorMatchCards.map({ (cardModel) -> CardModel in
            var new = cardModel
            new.loadMainImage()
            return new
        })
        
        favorMeHiddenCards = favorMeHiddenCards.map({ (cardModel) -> CardModel in
            var new = cardModel
            new.loadMainImage()
            return new
        })
        
        likeMeCards = likeMeCards.map({ (cardModel) -> CardModel in
            var new = cardModel
            new.loadMainImage()
            return new
        })
        
        iLikeCards = iLikeCards.map({ (cardModel) -> CardModel in
            var new = cardModel
            new.loadMainImage()
            return new
        })
        
        favorMeCards = favorMeCards.map({ (cardModel) -> CardModel in
            var new = cardModel
            new.loadMainImage()
            return new
        })
        
        ifavorCards = ifavorCards.map({ (cardModel) -> CardModel in
            var new = cardModel
            new.loadMainImage()
            return new
        })
        
        historyCards = historyCards.map({ (cardModel) -> CardModel in
            var new = cardModel
            new.loadMainImage()
            return new
        })
    }
}

struct AddressModel {
    var name: String?
    var phoneNumber: String?
}

struct PromotionValidUser {
    var recipient: Bool?
}

struct NewNoticeModel {
    var id: Int?
}

struct LoadingModel {
    private var count = 0
    var loading: Bool {
        get {
            if 0 < count {
                return true
            }
            return false
        }
    }
    mutating func add() {
        count += 1
    }
    mutating func del() {
        count -= 1
    }
}
