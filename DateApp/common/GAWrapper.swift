//
//  GAWrapper.swift
//  DateApp
//
//  Created by ryan on 12/29/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit

enum GAViewName: String {
    case start = "start"
    case sign_up = "sign_up"
    case sign_in = "sign_in"
    case today = "today"
    case story = "story"
    case evaluate = "evaluate"
    case news = "news"
    case news_more = "news_more"
    case drawer = "drawer"
    case user_detail = "user_detail"
    case profile = "profile"
    case shop = "shop"
    case point_log = "point_log"
    case contact = "contact"
    case notice = "notice"
    case setting = "setting"
    case chat_list = "chat_list"
    case chat = "chat"
}

struct GAWrapper {
    
    func initialize() {
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(String(describing: configureError))")
        
        // Optional: configure GAI options.
        let gai = GAI.sharedInstance()
        gai?.trackUncaughtExceptions = true  // report uncaught exceptions
        gai?.logger.logLevel = GAILogLevel.none  // remove before app release
    }
    
    func trackingViewName(viewName: GAViewName) {
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "\(viewName.rawValue)")
        
        if let gender = _app.sessionViewModel.model?.gender {
            tracker?.set(GAIFields.customDimension(for: 1), value: "gender")
            if let builder = GAIDictionaryBuilder.createScreenView().set(gender, forKey:GAIFields.customDimension(for: 1)) {
                tracker?.send(builder.build() as! [AnyHashable : Any])
            }
            
        } else {
            let builder = GAIDictionaryBuilder.createScreenView()
            tracker?.send(builder?.build() as! [AnyHashable : Any])
        }
        _app.log.debug("viewName: \(viewName)")
    }
    
    func trackingEventCategory(category: String, action: String, label: String) {
        let tracker = GAI.sharedInstance().defaultTracker
        guard let builder = GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: nil) else { return }
        tracker?.send(builder.build() as! [AnyHashable : Any])
        
        _app.log.debug("category: \(category), action: \(action), label: \(label)")
    }
}
