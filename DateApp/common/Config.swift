//
//  Config.swift
//  DateApp
//
//  Created by ryan on 12/23/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import Foundation

//net.pesofts.DateApp
//969402257b907c13ce9239a5ab241651


//15e5effef0256a60e3b254e63b3f8946
struct Config {
    var version: String {
        get {
            var appVersion: String?
            if let info = Bundle.main.infoDictionary {
                appVersion = info["CFBundleShortVersionString"] as? String
            }
            return appVersion ?? ""
        }
    }
    
    let jiverAppId = "8C8A1FA6-DD89-42F7-8FFE-C1C5226FFB5B"
    let onsignalAppId = "c90a541f-9c41-49ea-bdbb-ac1742cc33a5"
    
    var apiUrl: String
    let noticeUrl = "http://devpesoft.cafe24.com/notice"
    let serviceRuleUrl = "https://www.ablesquare.co.kr/clause/service"
    let privacyRuleUrl = "https://www.ablesquare.co.kr/clause/private"
    let locationRuleUrl = "https://www.ablesquare.co.kr/clause/location"
    let appstoreUrl = "https://itunes.apple.com/app/id1078504854"
    
    let masterEmailAddress = "help.ablesquare@gmail.com"
    let devUrl: String = "http://122.44.185.135:8080"
    
    var devServerOn: String? {
        get {
            return UserDefaults.standard.string(forKey: "devServerOn")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "devServerOn")
            UserDefaults.standard.synchronize()
        }
    }
    
    init() {
        #if DEBUG
            /* OLD
            apiUrl = "http://crush-dev.herokuapp.com"
            */
            
            // dev.ablesquare.co.kr 요걸로 변경해야 함
            apiUrl = "https://www.ablesquare.co.kr"
            //apiUrl = "http://122.44.203.239:8080"
            //apiUrl = "http://122.44.202.25:8080"
            //apiUrl = "http://dev.ablesquare.co.kr"
        #else
            /* OLD
            apiUrl = "https://crush-2015.herokuapp.com"
            */
            apiUrl = "https://www.ablesquare.co.kr"
            //apiUrl = "http://122.44.185.135:8080"
            //apiUrl = "http://dev.ablesquare.co.kr"
        #endif
    }
}
