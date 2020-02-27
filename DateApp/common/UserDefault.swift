//
//  UserDefault.swift
//  DateApp
//
//  Created by ryan on 12/27/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import Foundation

struct UserDefault {
    var email: String? {
        get {
            return UserDefaults.standard.string(forKey: "email")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "email")
            UserDefaults.standard.synchronize()
        }
    }
    var password: String? {
        get {
            return UserDefaults.standard.string(forKey:"password")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "password")
            UserDefaults.standard.synchronize()
        }
    }
    
    var checkedNoticeID: String? {
        get {
            return UserDefaults.standard.string(forKey:"checkedNoticeID")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "checkedNoticeID")
            UserDefaults.standard.synchronize()
        }
    }
    
    var noticeID: String? {
        get {
            return UserDefaults.standard.string(forKey:"noticeID")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "noticeID")
            UserDefaults.standard.synchronize()
        }
    }
    
    var noticeTitle: String? {
        get {
            return UserDefaults.standard.string(forKey:"noticeTitle")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "noticeTitle")
            UserDefaults.standard.synchronize()
        }
    }
    
    var noticeMessage: String? {
        get {
            return UserDefaults.standard.string(forKey:"noticeMessage")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "noticeMessage")
            UserDefaults.standard.synchronize()
        }
    }
    
    var minAge: String? {
        get {
            return UserDefaults.standard.string(forKey:"minAge")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "minAge")
            UserDefaults.standard.synchronize()
        }
    }
    
    var maxAge: String? {
        get {
            return UserDefaults.standard.string(forKey:"maxAge")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "maxAge")
            UserDefaults.standard.synchronize()
        }
    }
    
    var devServerOn: String? {
        get {
            return UserDefaults.standard.string(forKey:"devServerOn")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "devServerOn")
            UserDefaults.standard.synchronize()
        }
    }
    
    var uploadVoiceTime: Double? {
        get {
            return UserDefaults.standard.double(forKey: "uploadVoiceTime")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "uploadVoiceTime")
            UserDefaults.standard.synchronize()
        }
    }
    var facebookAuthToken: String? {
        get {
            return UserDefaults.standard.string(forKey:"facebookAuthToken")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "facebookAuthToken")
            UserDefaults.standard.synchronize()
        }
    }
    var facebookUserId: String? {
        get {
            return UserDefaults.standard.string(forKey:"facebookUserId")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "facebookUserId")
            UserDefaults.standard.synchronize()
        }
    }
    
    var facebookLogined: Bool? {
        get {
            return UserDefaults.standard.bool(forKey: "facebookLoginCookies")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "facebookLoginCookies")
            UserDefaults.standard.synchronize()
        }
    }
    
    var voiceReplyDate: Date? {
        get {
            guard let date = UserDefaults.standard.value(forKey: "voiceReplyDate") as? NSDate else {
                return nil
            }
            return date as Date
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "voiceReplyDate")
            UserDefaults.standard.synchronize()
        }
    }
    
    var isShowWriteReviewView: Bool? {
        get {
            return UserDefaults.standard.bool(forKey: "isShowWriteReviewView")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "isShowWriteReviewView")
            UserDefaults.standard.synchronize()
        }
    }
    
    var savedAppVersion: String? {
        get {
            return UserDefaults.standard.string(forKey:"savedAppVersion")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "savedAppVersion")
            UserDefaults.standard.synchronize()
        }
    }
    
    var lastestAppVersion: String? {
        get {
            return UserDefaults.standard.string(forKey:"lastestAppVersion")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "lastestAppVersion")
            UserDefaults.standard.synchronize()
        }
    }
    
    var isTriedProtionUserEvent: Bool? {
        get {
            return UserDefaults.standard.bool(forKey: "isTriedProtionUserEvent")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "isTriedProtionUserEvent")
            UserDefaults.standard.synchronize()
        }
    }
    
    var isShowedPromotionPopup: Bool? {
        get {
            return UserDefaults.standard.bool(forKey: "isShowedPromotionPopup")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "isShowedPromotionPopup")
            UserDefaults.standard.synchronize()
        }
    }
    
    var newNoticeId: Int? {
        get {
            return UserDefaults.standard.integer(forKey: "newNoticeId")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "newNoticeId")
            UserDefaults.standard.synchronize()
        }
    }
}
