//
//  OneSignalWrapper.swift
//  DateApp
//
//  Created by ryan on 2/6/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import Foundation

struct OneSignalWrapper {
    
    var oneSignal: OneSignal!
    
    func getTags() {
        
        _app.loadingViewModel.model?.add()
        OneSignal.getTags({ (tags) -> () in
            guard let tags = tags as? [String:String] else {
                 _app.oneSignalTagsViewModel.model = nil
                return
            }
            _app.oneSignalTagsViewModel.model = OneSignalTags(tags: tags)
            _app.loadingViewModel.model?.del()
        })
    }
    
    func sendTags(tags: OneSignalTags) {
        OneSignal.sendTags(tags.dictionary)
    }
    
    func sendTagEnableCard(value: Bool) {
        OneSignal.sendTag("enableCard", value: "\(value)")
    }
    
    func sendTagEnableChat(value: Bool) {
        OneSignal.sendTag("enableChat", value: "\(value)")
    }
    
    func sendTagEnableLike(value: Bool) {
        OneSignal.sendTag("enableLike", value: "\(value)")
    }
    
    func onTagWaitEvaluate() {
        OneSignal.sendTag("waitEvaluate", value: "true")
    }
    
    func offTagWaitEvaluate() {
        // ""를 세팅해서 는 key 삭제
        OneSignal.sendTag("waitEvaluate", value: "")
    }
}
