//
//  MessagingTableViewController.h
//  SendBirdiOSSample
//
//  Created by SendBird Developers on 2015. 7. 29..
//  Copyright (c) 2015 SENDBIRD.COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import "SendBirdCommon.h"
#import "MessageInputView.h"
#import "MessagingMessageTableViewCell.h"
#import "MessagingMyMessageTableViewCell.h"
#import "MessagingFileLinkTableViewCell.h"
#import "MessagingSystemMessageTableViewCell.h"
#import "MessagingFileMessageTableViewCell.h"
#import "MessagingBroadcastMessageTableViewCell.h"
#import "MessagingMyFileLinkTableViewCell.h"
#import "MemberTableViewCell.h"
#import "MessagingIndicatorView.h"
#import "TypingNowView.h"
#import "MessagingChannelTableViewCell.h"
#import "MessagingMyStructuredMessageTableViewCell.h"
#import "MessagingStructuredMessageTableViewCell.h"

@interface MessagingTableViewController : UIViewController

@property (retain) UIView *container;
@property (retain) UITableView *tableView;
@property (retain) MessageInputView *messageInputView;
@property (retain) NSString *channelUrl;
@property BOOL openImagePicker;
@property (retain) MessagingIndicatorView *indicatorView;
//@property (retain) UILabel *titleLabel;
@property (retain) NSString *userId;
@property (retain) NSString *userName;
@property (retain) UITableView *channelMemberListTableView;
@property (retain) UITableView *messagingChannelListTableView;
@property (retain) SendBirdMessagingChannel *currentMessagingChannel;
@property (retain) TypingNowView *typingNowView;
@property (retain) NSString *targetUserId;

- (id) init;
- (void) setViewMode:(int)mode;
- (void) startChatting;
- (void)setIndicatorHidden:(BOOL)hidden;
- (void) initChannelTitle;
- (void) updateChannelTitle;
- (void) startMessagingWithUser:(NSString *)userId;

- (void) notifyUpdatedMessagingChannel:(SendBirdMessagingChannel *) channel;  // by yjkim

// by yjkim, handlers
- (void)connectBlock:(SendBirdChannel *)channel;
- (void)errorBlock:(NSInteger) code;
- (void)channelLeftBlock:(SendBirdChannel *)channel;
- (void)messageReceivedBlock:(SendBirdMessage*)message;
- (void)systemMessageReceivedBlock:(SendBirdSystemMessage *)message;
- (void)broadcastMessageReceivedBlock:(SendBirdBroadcastMessage *)message;
- (void)fileReceivedBlock:(SendBirdFileLink *)fileLink;
- (void)messagingStartedBlock:(SendBirdMessagingChannel *)channel;
- (void)messagingUpdatedBlock:(SendBirdMessagingChannel *)channel;
- (void)messagingEndedBlock:(SendBirdMessagingChannel *)channel;
- (void)allMessagingEndedBlock;
- (void)messagingHiddenBlock:(SendBirdMessagingChannel *)channel;
- (void)allMessagingHiddenBlock;
- (void)readReceivedBlock:(SendBirdReadStatus *)status;
- (void)typeStartReceivedBlock:(SendBirdTypeStatus *)status;
- (void)typeEndReceivedBlock:(SendBirdTypeStatus *)status;
- (void)allDataReceivedBlock:(NSUInteger)sendBirdDataType withCount: (int) count;
- (void)messageDeliveryBlock:(BOOL)send withMessage:(NSString*)message withData:(NSString *)data withMessageId: (NSString *)messageId;

@end
