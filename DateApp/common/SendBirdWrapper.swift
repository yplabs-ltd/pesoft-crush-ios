//
//  JiverWrapper.swift
//  DateApp
//
//  Created by ryan on 12/23/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit

class SendBirdWrapper {
    
    weak var messagingTableViewController: MessagingTableViewController?    // 채팅방 instance (메시지 전달을 위한 참조)
    
    // app 시작시 sendbird 연결 필요
    func initialize() {
        
        igawInitAppId(appId: _app.config.jiverAppId, withDeviceId: _app.uuid)
        
        var sendBirdNotificationHandlers = SendBirdNotificationHandlers()
        sendBirdNotificationHandlers.channelUpdatedBlock = { (channel: ChannelModel?) -> () in
            
            // chating 방 객체가 있으면 그쪽으로도 noti 보낸다.
            self.messagingTableViewController?.notifyUpdatedMessagingChannel(channel?.channel)
        }
        registerNotificationHandlerMessagingChannelUpdatedBlock(handlers: sendBirdNotificationHandlers)
        setEventHandlerConnectBlock()
        
    }
    
    func igawInitAppId(appId: String, withDeviceId: String) {
        SendBird.igawInitAppId(appId, withDeviceId: withDeviceId)
    }
    
    func igawLoginWithUserId(userId: String, userName: String, userImageUrl: String, accessToken: String) {
        SendBird.igawLogin(withUserId: userId, andUserName: userName, andUserImageUrl: userImageUrl, andAccessToken: accessToken)
    }
    
    func registerNotificationHandlerMessagingChannelUpdatedBlock(handlers: SendBirdNotificationHandlers) {
        
        SendBird.registerNotificationHandlerMessagingChannelUpdatedBlock( { (channel: SendBirdMessagingChannel?) -> () in
            // 누군가 말을 걸을때 callback
            print("\(#function) messagingChannelUpdatedBlock")
            guard let channel = channel else {
                return
            }
            
            let channelModel = ChannelModel(channel:channel)
            handlers.channelUpdatedBlock?(channelModel)
            
            // chennelViewmodel갱신
            _app.talkChannelsViewModel.reload()
            
            },
            mentionUpdatedBlock: { (mention: SendBirdMention?) -> () in
                print("\(#function) mentionUpdatedBlock")
                handlers.mentionUpdatedBlock?(mention)
        })
    }
    
    func setEventHandlerConnectBlock() {
        
        SendBird.setEventHandlerConnect( { (channel: SendBirdChannel?) -> () in
            print("\(#function) connectBlock")
            self.messagingTableViewController?.connectBlock(channel)
            },
            errorBlock: { (code: NSInteger) -> () in
                print("\(#function) errorBlock")
                self.messagingTableViewController?.errorBlock(code)
            },
            channelLeftBlock: { (channel: SendBirdChannel?) -> () in
                print("\(#function) channelLeftBlock")
                self.messagingTableViewController?.channelLeftBlock(channel)
            },
            messageReceivedBlock: { (message: SendBirdMessage?) -> () in
                print("\(#function) messageReceivedBlock")
                self.messagingTableViewController?.messageReceivedBlock(message)
            },
            systemMessageReceivedBlock: { (message: SendBirdSystemMessage?) -> () in
                print("\(#function) systemMessageReceivedBlock")
                self.messagingTableViewController?.systemMessageReceivedBlock(message)
            },
            broadcastMessageReceivedBlock: { (message: SendBirdBroadcastMessage?) -> () in
                print("\(#function) broadcastMessageReceivedBlock")
                self.messagingTableViewController?.broadcastMessageReceivedBlock(message)
            },
            fileReceivedBlock: { (fileLink: SendBirdFileLink?) -> () in
                print("\(#function) fileReceivedBlock")
                self.messagingTableViewController?.fileReceivedBlock(fileLink)
            },
            messagingStartedBlock: { (channel: SendBirdMessagingChannel?) -> () in
                print("\(#function) messagingStartedBlock")
                self.messagingTableViewController?.messagingStartedBlock(channel)
            },
            messagingUpdatedBlock: { (channel: SendBirdMessagingChannel?) -> () in
                print("\(#function) messagingUpdatedBlock")
                self.messagingTableViewController?.messagingUpdatedBlock(channel)
            },
            messagingEndedBlock: { (channel: SendBirdMessagingChannel?) -> () in
                // 대화방 나가기
                print("\(#function) messagingEndedBlock")
                self.messagingTableViewController?.messagingEndedBlock(channel)
                _app.talkChannelsViewModel.reload()
            },
            allMessagingEndedBlock: { () -> () in
                print("\(#function) allMessagingEndedBlock")
                self.messagingTableViewController?.allMessagingEndedBlock()
            },
            messagingHiddenBlock: { (channel: SendBirdMessagingChannel?) in
                print("\(#function) messagingHiddenBlock")
                self.messagingTableViewController?.messagingHiddenBlock(channel)
            },
            allMessagingHiddenBlock: { () -> () in
                print("\(#function) allMessagingHiddenBlock")
                self.messagingTableViewController?.allMessagingHiddenBlock()
            },
            readReceivedBlock: { (status: SendBirdReadStatus?) -> () in
                print("\(#function) readReceivedBlock")
                self.messagingTableViewController?.readReceivedBlock(status)
            },
            typeStartReceivedBlock: { (status: SendBirdTypeStatus?) -> () in
                print("\(#function) typeStartReceivedBlock")
                self.messagingTableViewController?.typeStartReceivedBlock(status)
            },
            typeEndReceivedBlock: { (status: SendBirdTypeStatus?) -> () in
                print("\(#function) typeEndReceivedBlock")
                self.messagingTableViewController?.typeEndReceivedBlock(status)
            },
            allDataReceivedBlock: { (jiverDataType: UInt, count: Int32) -> () in
                print("\(#function) allDataReceivedBlock")
                self.messagingTableViewController?.allDataReceivedBlock(jiverDataType, withCount: count)
            },
            messageDeliveryBlock: { (send: Bool, message: String?, data: String?, messageId: String?) -> () in
                print("\(#function) messageDeliveryBlock")
                self.messagingTableViewController?.messageDeliveryBlock(send, withMessage: message, withData: data, withMessageId: messageId)
        })
    }
    
    func joinChannel(channelUrl: String) {
        SendBird.joinChannel(channelUrl)
    }

    func login(memberModel: MemberModel) {
        
        guard let userId = memberModel.id else {
            return
        }
        let userImageUrl = memberModel.mainImageUrl ?? ""
        igawLoginWithUserId(userId: "\(userId)",
            userName: memberModel.name ?? "",
            userImageUrl: userImageUrl,
            accessToken: "")
        
        joinChannel(channelUrl: "")
    }
    
    func joinMessagingWithChannelUrl(channelUrl: String) {
        SendBird.joinMessaging(withChannelUrl: channelUrl)
    }
    
    func markAsRead() {
        SendBird.markAsRead()
    }
    
    func endMessagingWithChannelUrl(channelUrl: String) {
        SendBird.endMessaging(withChannelUrl: channelUrl)
    }
    
    // jiver channel list
    func messageChannelList(channelListViewModel: DViewModel<[ChannelModel]>, loadingViewModel: DViewModel<LoadingModel>?) {
        loadingViewModel?.model?.add()
        var channels: [ChannelModel] = []
        if let channelList = SendBird.queryMessagingChannelList() {
            channelList.setLimit(1000)
            channelList.next( resultBlock: { (queryResult: NSMutableArray?) -> () in
                queryResult?.forEach({ (item) -> () in
                    print("adadad")
                    if let channel = item as? SendBirdMessagingChannel {
                        if channel.lastMessage != nil {
                            let channelModel = ChannelModel(channel: channel)
                            channels.append(channelModel)
                            
                            print("channelName: \(channelModel.channelName), lastMessage: \(channelModel.lastMessage), lastTime: \(channelModel.lastMessageTimeString(dateFormat: "MM/dd/YY, HH:mm")), coverImageUrl: \(channelModel.coverImageUrl)")
                        }
                    }
                })
                
                channelListViewModel.model = channels
                loadingViewModel?.model?.del()
            },
                              end: { (code: NSInteger) in
            })
        }
    }
    
    
    func isOpenedChatViewController(viewController: UIViewController, channelUrl: String) -> Bool {
        
        if let navi = viewController as? UINavigationController, let vc = navi.visibleViewController {
            if let vc = vc as? MessagingTableViewController, let cu = vc.channelUrl , cu == channelUrl {
                return true
            }
        }
        return false
    }
    
    func containsSystemMsg(msg: String) -> Bool {
        if msg.range(of:"MSG_BLOCK") != nil {
            return true
        }
        if msg.range(of:"MSG_UNBLOCK") != nil {
            return true
        }
        return false
    }
}

// SendBirdMessagingChannel 확장 (앱에서 필요한 함수들 추가)

struct ChannelModel {
    
    var channel: SendBirdMessagingChannel
    
    var targetUserId: Int = -1
    var channelName: String
    var lastMessage: String
    var lastMessageTime: TimeInterval?
    var unreadCount = 0
    var coverImageUrl: String?
    var channelType = ChannelType.Locked
    enum ChannelType {
        case Locked // 잠김 (초기에는 잠김)
        case Opened // 활성화 상태, 대화가능
        case Closed // 대화방 파기
    }
    
    var channelUrl: String {
        return channel.getUrl()
    }
    
    private var targetMember: MemberModel? {
        
        let member = channel.members.filter { (member) -> Bool in
            guard let _ = member as? SendBirdMemberInMessagingChannel else {
                return false
            }
            return true
            }.map { (member) -> SendBirdMemberInMessagingChannel in
                return member as! SendBirdMemberInMessagingChannel
            }.filter { (member) -> Bool in
                if member.guestId != SendBird.getUserId() {
                    return true
                }
                return false
            }.first
        if let member = member {
            var targetMember = MemberModel()
            
            if let targetUserId = Int(member.guestId) {
                targetMember.id = targetUserId
            }
            targetMember.name = member.name
            targetMember.mainImageUrl = member.imageUrl
            return targetMember
        }
        return nil
    }
    
    init(channel: SendBirdMessagingChannel) {
        
        self.channel = channel

        lastMessage = channel.lastMessage.message
        lastMessageTime = TimeInterval(channel.lastMessage.getMessageTimestamp())
        unreadCount = Int(channel.unreadMessageCount)
        channelName = ""
        
        if let targetMember = targetMember {
            targetUserId = targetMember.id ?? 0
            channelName = targetMember.name ?? ""
            coverImageUrl = targetMember.mainImageUrl
        }
        
        if lastMessage == "MSG_BLOCK" {
            channelType = .Locked
        } else {
            channelType = .Opened
        }
    }
    
    func lastMessageTimeString(dateFormat: String) -> String {
        guard let lastMessageTime = lastMessageTime else {
            return ""
        }
        
        let date = Date(timeIntervalSince1970: lastMessageTime / 1000)
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from: date)
    }
}

struct SendBirdNotificationHandlers {
    var channelUpdatedBlock: ((ChannelModel?) -> ())?
    var mentionUpdatedBlock: ((SendBirdMention?) -> ())?
}

class MessagingTableViewControllerWrapper {
    
    let viewController = MessagingTableViewController()
    
    func initChannel(channelUrl: String, userName: String, userId: String) {
        viewController?.setViewMode(kMessagingViewMode)  // kMessagingChannelListViewMode, kMessagingViewMode
        viewController?.initChannelTitle()
        viewController?.channelUrl = channelUrl
        viewController?.userName = userName
        viewController?.userId = userId
    }
    
    // MessageTableViewController 에 channel 정보 바뀐 notifycation 전달
    func notifyUpdatedMessagingChannel(channelModel: ChannelModel?) {
        guard let channelModel = channelModel else {
            return
        }
        viewController?.notifyUpdatedMessagingChannel(channelModel.channel)
    }
    
    static func refreshViewController(viewController: UIViewController, channelUrl: String) {
        if let viewController = viewController as? MessagingTableViewController {
            viewController.setViewMode(kMessagingViewMode)
            viewController.channelUrl = channelUrl
        }
    }
}
