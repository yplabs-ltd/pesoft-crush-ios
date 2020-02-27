//
//  Models+Extension.swift
//  DateApp
//
//  Created by ryan on 1/8/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import Foundation

extension CodeValueModel {
    var parameters: [String:AnyObject]? {
        guard let code = code, let value = value else {
            return nil
        }
        var codeValue: [String:AnyObject] = [:]
        codeValue["code"] = code as AnyObject
        codeValue["value"] = value as AnyObject
        return codeValue
    }
}

extension VoiceModel {
    var parameters: [String: AnyObject] {
        var parameters: [String: AnyObject] = [:]
        
        parameters["userId"] = userId as AnyObject
        parameters["urlPath"] = urlPath as AnyObject
        parameters["otherUserId"] = otherUserId as AnyObject
        parameters["otherVoiceCloudId"] = otherVoiceCloudId as AnyObject
        parameters["voiceChatRoomId"] = voiceChatRoomId as AnyObject
        
        return parameters
    }
}

extension VoiceChatRoomModel {
    var parameters: [String: AnyObject] {
        var parameters: [String: AnyObject] = [:]
        
        parameters["voiceChatRoomId"] = id as AnyObject
        
        return parameters
    }
}

extension PassVoiceModel {
    var parameters: [String: AnyObject] {
        var parameters: [String: AnyObject] = [:]
        parameters["voiceChatRoomId"] = voiceChatRoomId as AnyObject
        parameters["voiceCloudId"] = voiceCloudId as AnyObject
        if let type = passType {
            parameters["passType"] = type as AnyObject
        }
        
        
        return parameters
    }
}


extension ProfileModel {
    
    var parameters: [String: AnyObject] {
        var parameters: [String: AnyObject] = [:]
        
        parameters["name"] = name as AnyObject
        parameters["birthDate"] = birthDate as AnyObject
        parameters["gender"] = gender as AnyObject
        parameters["idealType"] = idealType?.parameters as AnyObject
        parameters["bloodType"] = bloodType?.parameters as AnyObject
        parameters["hometown"] = hometown?.parameters as AnyObject
        parameters["religion"] = religion?.parameters as AnyObject
        parameters["job"] = job?.parameters as AnyObject
        parameters["bodyType"] = bodyType?.parameters as AnyObject
        parameters["height"] = height as AnyObject
        parameters["school"] = school as AnyObject
        
        if let v = voiceUrl {
            parameters["voice"] = v as AnyObject
        }
        
        var imageInfos:[AnyObject] = []
        imageInfoList.forEach({ (imageInfo) -> () in
            var param = [String:AnyObject]()
            param["imageid"] = imageInfo.imageId as AnyObject
            param["urlpath"] = imageInfo.urlPath as AnyObject
            param["ordering"] = imageInfo.ordering as AnyObject
            imageInfos.append(param as AnyObject)
        })
        parameters["imageInfoList"] = imageInfos as AnyObject
        
        var hobbList:[AnyObject] = []
        hobbyCode.forEach({ (hobbyInfo) -> () in
            if let code = hobbyInfo.code, code.length > 0 {
                var param = [String:AnyObject]()
                param["code"] = hobbyInfo.code as AnyObject
                hobbList.append(param as AnyObject)
            }
        })
        parameters["hobbyList"] = hobbList as AnyObject
        
        var charmTypeList:[AnyObject] = []
        if gender == "F" {
            charmFTypeCode.forEach({ (codeInfo) -> () in
                if let code = codeInfo.code, code.length > 0 {
                    var param = [String:AnyObject]()
                    param["code"] = codeInfo.code as AnyObject
                    charmTypeList.append(param as AnyObject)
                }
            })
            parameters["charmTypeList"] = charmTypeList as AnyObject
        }else {
            charmMTypeCode.forEach({ (codeInfo) -> () in
                if let code = codeInfo.code, code.length > 0 {
                    var param = [String:AnyObject]()
                    param["code"] = code as AnyObject
                    charmTypeList.append(param as AnyObject)
                }
            })
            parameters["charmTypeList"] = charmTypeList as AnyObject
        }
        
        var favoriteTypeList:[AnyObject] = []
        favoriteTypeCode.forEach({ (codeInfo) -> () in
            if let code = codeInfo.code, code.length > 0 {
                var param = [String:AnyObject]()
                param["code"] = code as AnyObject
                favoriteTypeList.append(param as AnyObject)
            }
        })
        parameters["favoriteTypeList"] = favoriteTypeList as AnyObject
        
        return parameters
    }
}

extension Date {
    func isFuture() -> Bool {
        let interval = Date().timeIntervalSince(self)
        return String.isFutureDate(interval: interval)
    }
}

extension CardModel {
    
    // 표시가 몇일 남았는지 문자열 반환(D-N 형식)
    var expiredString: String {
        guard let expiredDttm = expiredDttm else {
            return ""
        }
        let interval = NSDate().timeIntervalSince(expiredDttm as Date)
        let dayCount = String.stringDDayFromTimeInterval(interval: interval)
        return dayCount
    }
    
    var isFuture: Bool {
        guard let expiredDttm = expiredDttm else {
            return false
        }
        return expiredDttm.isFuture()
    }
}

extension PointLogModel {
    // 날짜 표시를 위한 string 반환
    var regDttmText: String {
        guard let regDttm = regDttm else {
            return ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy.MM.dd"
        return dateFormatter.string(from: regDttm)
    }
}

extension Sequence where Iterator.Element == ProfileModel.ImageInfo {
    var validImageCount: Int {
        let count = filter { (imageInfo) -> Bool in
            if imageInfo.image != nil {
                return true
            }
            return false
        }.count
        return count
    }
}

extension Sequence where Iterator.Element == CodeValueModel {

    // [CodeValueModel] -> [SelectItemModel]
    var selectItemModels: [SelectItemModel] {
        var items: [SelectItemModel] = []
        forEach { (codeValueModel) -> () in
            guard let code = codeValueModel.code, let value = codeValueModel.value else {
                return
            }
            let item = SelectItemModel(name: code, value: value, children: nil)
            items.append(item)
        }
        return items
    }
    
    // [CodeValueModel] -> [SelectItemModel] for 2 depth
    var selectItemModelsFor2Depth: [SelectItemModel] {
        
        // extra 값 있는 것들만 모으기
        var extras:[String] = []
        forEach { (codeValueModel) -> () in
            guard let extra = codeValueModel.extra else {
                return
            }
            if !extras.contains(extra) {
                extras.append(extra)
            }
        }
        
        // children 먼저 추출
        var children: [String:[SelectItemModel]] = [:] // extra:[item]
        forEach { (codeValueModel) -> () in
            guard let code = codeValueModel.code, let value = codeValueModel.value else {
                return
            }
            guard let extra = codeValueModel.extra, extra != "" else {
                return
            }
            // child 는 extra 값을 가지고 있음
            if children[extra] == nil {
                children[extra] = []
            }
            children[extra]?.append(SelectItemModel(name: code, value: value, children: nil))
        }
        
        var items: [SelectItemModel] = []
        var parents: [CodeValueModel] = []
        extras.forEach { (extra) -> () in
            parents.append(CodeValueModel(code: extra, value: extra))
        }
        parents.forEach { (codeValueModel) -> () in
            guard let code = codeValueModel.code, let value = codeValueModel.value else {
                return
            }
            let item = SelectItemModel(name: code, value: value, children: children[code])
            items.append(item)
        }
        return items
    }
}

extension Sequence where Iterator.Element == SelectItemModel {
    // 표시되는 cell 수
    var countOfVisibleCells: Int {
        let count = reduce(0) { (count, item) -> Int in
            if let children = item.children, item.childrenHidden == false {
                return count + children.count + 1
            }
            return count + 1
        }
        return count
    }
    
    // child 를 포함해서 cellIdx 의 item 얻음 (Bool 은 child 인지 여부, index 는 실제 인덱스)
    func getItem(cellIdx: Int) -> (item:SelectItemModel, child:Bool, parentIndex: Int)? {
        var idx = 0
        var parentIdx = 0
        for item in self {
            if cellIdx == idx {
                return (item, false, parentIdx)
            }
            parentIdx += 1
            idx += 1
            if let children = item.children, item.childrenHidden == false {
                for child in children {
                    if cellIdx == idx {
                        return (child, true, idx)
                    }
                    idx += 1
                }
            }
        }
        return nil
    }
}


