//
//  TalkChannelsViewModel.swift
//  DateApp
//
//  Created by ryan on 1/19/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import Foundation

class TalkChannelsViewModel: DViewModel<[ChannelModel]> {
    var hasNewMessage: Bool {
        guard let channels = model else {
            return false
        }
        let unreadChannels = channels.filter { (channelModel) -> Bool in
            if 0 < channelModel.unreadCount {
                return true
            }
            return false
        }
        if 0 < unreadChannels.count {
            return true
        } else {
            return false
        }
    }
    
    var hasNewChannel: Bool {
        
        guard let channels = model else {
            return false
        }
        let unblockedChannels = channels.filter { (channelModel) -> Bool in
            if channelModel.lastMessage == "MSG_BLOCK" {
                return true
            }
            return false
        }
        if 0 < unblockedChannels.count {
            return true
        } else {
            return false
        }
    }
    
    override func reload() {
        guard SendBird.getUserId() != nil else {
            return
        }
        
        reloadWithLoadingViewModel(loadingViewModel: nil)
    }
    
    func reloadWithLoadingViewModel(loadingViewModel: DViewModel<LoadingModel>?) {
        _app.sendBird.messageChannelList(channelListViewModel: self, loadingViewModel: loadingViewModel)
    }
}
