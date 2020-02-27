//
//  ChatListViewController+Cell.swift
//  DateApp
//
//  Created by ryan on 12/24/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit


final class ChatInfoCell: UITableViewCell {
    
    @IBOutlet weak var infoCardLabel: UILabel!
    
    var likeCount = 0 {
        didSet {
            setInfoCardLabelMsgWithCount(count: likeCount)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setInfoCardLabelMsgWithCount(count: Int) {
        let t1 = "나에게 좋아요를 보낸 카드 "
        let t2 = "\(count)개"
        let msg = t1 + t2
        let infoCard = NSMutableAttributedString(string: msg)
        infoCard.addAttribute(.foregroundColor, value: UIColor(rgba: "#726763"), range: NSMakeRange(0, t1.length))
        infoCard.addAttribute(.foregroundColor, value: UIColor(rgba: "#f2503b"), range: NSMakeRange(t1.length, t2.length))
        infoCardLabel.attributedText = infoCard;
    }
}

final class ChatChannelCell: UITableViewCell {
    
    @IBOutlet weak var coverImageContainerView: UIView!
    @IBOutlet weak var coverImageButton: UIButton!
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var channelLastMessageLabel: UILabel!
    @IBOutlet weak var channelLastMessageTimeLabel: UILabel!
    @IBOutlet weak var newBadgeLabel: UILabel!
    @IBOutlet weak var newCountLabel: UILabel!
    @IBOutlet weak var profileBGView: UIView!
    
    var channelModel: ChannelModel? {
        didSet {
            guard let channelModel = channelModel else {
                return
            }
            
            self.coverImageButton.setImage(UIImage(named: "home_thumbnail_default"), for: UIControlState.normal)
            self.coverImageButton.layer.cornerRadius = 37
            self.coverImageButton.layer.masksToBounds = true
            if let url = channelModel.coverImageUrl {
                let loadingViewModel = LoadingViewModelBuilder(superview: coverImageButton).viewModel
                let responseViewModel = ApiResponseViewModelBuilder<Data>(successHandler: { [weak self] (data) -> Void in
                    self?.coverImageButton.setImage(UIImage(data: data), for: UIControlState.normal)
                }).viewModel
                let _ = _app.api.download(url: url, apiResponseViewModel: responseViewModel, loadingViewModel: loadingViewModel)
            }
            coverImageButton.tag = channelModel.targetUserId
            channelNameLabel.text = channelModel.channelName
            if channelModel.lastMessage == "MSG_BLOCK" {
                newBadgeLabel.isHidden = false
                channelLastMessageLabel.text = "[매칭이 성공하였습니다.]"
            } else if channelModel.lastMessage == "MSG_UNBLOCK" {
                newBadgeLabel.isHidden = true
                channelLastMessageLabel.text = "[대화방이 생성되었습니다.]"
            } else {
                newBadgeLabel.isHidden = true
                channelLastMessageLabel.text = channelModel.lastMessage
            }
            channelLastMessageTimeLabel.text = channelModel.lastMessageTimeString(dateFormat: "YY/MM/dd HH:mm")
            if 0 < channelModel.unreadCount && channelModel.channelType == .Opened {
                newCountLabel.isHidden = false
                newCountLabel.text = "\(channelModel.unreadCount)"
            } else {
                newCountLabel.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        newBadgeLabel.makeCircleStyle()
        newBadgeLabel.isHidden = true
        
        profileBGView.layer.cornerRadius = 37
        profileBGView.layer.masksToBounds = true
        
        coverImageContainerView.makeCircleImageContainerWithBorder(borderWidth: 1.0, borderColor: UIColor(rgba: "#e3e1e0"))
        newCountLabel.makeCircleStyle()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
