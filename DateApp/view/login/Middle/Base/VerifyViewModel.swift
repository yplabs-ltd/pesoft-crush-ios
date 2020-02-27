//
//  VerifyViewModel.swift
//  vegas-ios
//
//  Created by Lim Daehyun on 2018. 1. 24..
//  Copyright © 2018년 refactoring. All rights reserved.
//

import Foundation

struct VerifyItem {
    enum TypingType {
        case normal
        case secure
    }
    
    enum ItemType: String {
        case button = "button"
        case email = "email"
        case recommendId = "recommendId"
        case password = "password"
        case repassword = "repassword"
        case mobile = "mobile"
        case verifyCode = "verifyCode"
        case selectGender = "selectGender"
    }
    
    let type: TypingType!
    let item: ItemType?
    let title: String?
    let placeHolderText: String?
    var content: String?
    var warnMessage: String?
}

extension VerifyItem: Equatable {}
    func ==(lhs: VerifyItem, rhs: VerifyItem) -> Bool {
        return (lhs.type == rhs.type &&
            lhs.item == rhs.item &&
            lhs.title == rhs.title &&
            lhs.placeHolderText == rhs.placeHolderText &&
            lhs.content == rhs.content &&
            lhs.warnMessage == rhs.warnMessage)
    }

protocol Verifyable {
    var verifyItems: [VerifyItem] { get set }
    func getItem(item: VerifyItem.ItemType) -> VerifyItem?
    func updateContentWithIndex(index: Int, content: String?) -> Bool
    func requestToVerify(target: String?, type: VerifyItem.ItemType?, onStart: (()->Void)?, onSuccess: (()->Void)?, onFail: (()->Void)?, onFinish: (()->Void)?)
    func callAPI(onSuccess: ((Bool) -> Void)?, onFail: ((NSError?) -> Void)?, onFinish: (() -> Void)?)
}

class VerifyViewModel: Verifyable {
    private var _verifyItems = [VerifyItem]()
    var verifyItems: [VerifyItem] {
        get {
            return _verifyItems
        }
        
        set {
            _verifyItems.removeAll()
            _verifyItems.append(contentsOf: newValue)
        }
    }

    func requestToVerify(target: String?, type: VerifyItem.ItemType?, onStart: (() -> Void)?, onSuccess: (() -> Void)?, onFail: (() -> Void)?, onFinish: (() -> Void)?) { }
    
    func callAPI(onSuccess: ((Bool) -> Void)?, onFail: ((NSError?) -> Void)?, onFinish: (() -> Void)?) { }
    
    func getItem(item: VerifyItem.ItemType) -> VerifyItem? {
        return verifyItems.filter { $0.item == item }.first
    }
    
    func updateContentWithIndex(index: Int, content: String?) -> Bool {
        var isUpdated: Bool = false
        guard verifyItems.count > index else {
            return false
        }
        verifyItems.modifyElement(atIndex: index, modifyElement: {
            $0.content = content?.trimWhiteSpace()
            isUpdated = true
        })
        
        return isUpdated
    }
    
    func requestCheckRecommendCode(_ code: String, complete: @escaping ((Bool) -> Void)) {
        let responseViewModel = ApiResponseViewModelBuilder<ServerDefaultResponseModel>(successHandlerWithDefaultError: { (responseModel) -> Void in
        }).viewModel

        let _ = _app.api.checkRecommendCode(code: code, apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel, onFinish: complete)
    }
}
