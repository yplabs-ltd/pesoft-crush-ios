//
//  VoiceChatRoomViewController+Cell.swift
//  DateApp
//
//  Created by Yang Hyeon Gyu on 2017. 3. 19..
//  Copyright © 2017년 iflet.com. All rights reserved.
//

import UIKit
import SDWebImage

final class VoiceChatRoomInfoCell: UITableViewCell {
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let top1 = "이야기는 첫 대화 이후 "
        let top2 = "무료로"
        let top3 = " 서로 주고 받을 수 있으며"
        let topMessage = top1 + top2 + top3
        
        let topInfoCard = NSMutableAttributedString(string: topMessage)
        topInfoCard.addAttribute(.foregroundColor, value: UIColor(rgba: "#f2503b"), range: NSMakeRange(top1.length, top2.length))
        topLabel.attributedText = topInfoCard;
        
        let bottom1 = "첫 대화가 시작된 후 "
        let bottom2 = "2일"
        let bottom3 = " 이후에는 자동으로 소멸됩니다."
        let bottomMessage = bottom1 + bottom2 + bottom3
        let bottomInfoCard = NSMutableAttributedString(string: bottomMessage)
        bottomInfoCard.addAttribute(.foregroundColor, value: UIColor(rgba: "#f2503b"), range: NSMakeRange(bottom1.length, bottom2.length))
        bottomLabel.attributedText = bottomInfoCard;
    }
}

final class VoiceChatRoomEmptyCell: UITableViewCell {
    @IBOutlet weak var emptyCellInfoLabel: UILabel!
    
    override func awakeFromNib() {
        emptyCellInfoLabel.text = "이야기 보관함이 비어있습니다\n다른 사람의 이야기에 답장을 하거나\n새 이야기를 시작해 보세요"
    }
}

final class VoiceChatChannelCell: UITableViewCell {
    var downloadProfileImage: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileImageViewContainer: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var remainHourTimeLabel: UILabel!
    @IBOutlet weak var chatCountLabel: UILabel!
    @IBOutlet weak var remainDayTimeLabel: UILabel!
    @IBOutlet weak var newLabel: UILabel!
    
    var voiceChatRoomModel: VoiceChatRoomModel? {
        didSet {
            guard var voiceChatRoomModel = voiceChatRoomModel else {
                return
            }
            let chatCount: String = voiceChatRoomModel.count ?? "\(0)"
            self.chatCountLabel.text = chatCount + "개의 대화"
            self.userNameLabel.text = voiceChatRoomModel.name
            self.remainHourTimeLabel.text = voiceChatRoomModel.modifiedAt?.timeAgoForComment()
            self.newLabel.isHidden = true
            if voiceChatRoomModel.isNew! {
                self.newLabel.isHidden = false
            }
            voiceChatRoomModel.loadRemainDayTime()
            self.remainDayTimeLabel.text = voiceChatRoomModel.remainDayTime
        }
    }
    
    func setProfileImage(imageUrl: String?) {
        self.profileImageView.image = nil
        if let url = imageUrl {
            downloadProfileImage.sd_setImage(with: URL(string: url)) { (image , error , cachType , url ) in
                if let img = image {
                    DispatchQueue.main.async {
                        let resizedImage = img.ResizeImage(targetSize: CGSize(width: 150, height: 150))
                        self.profileImageView.image = self.voiceChatRoomModel?.profileOpened == true ? resizedImage : resizedImage.applyLightEffect()
                    }
                }
                
                if let err = error {
                    #if DEBUG
                    print("url::: \(String(describing: url)), error::: \(err)")
                    #endif
                }
            }
        }
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        downloadProfileImage = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageViewContainer.makeCircleStyleWithBorder(borderWidth: 1.0, borderColor: UIColor(rgba: "#e3e1e0"))
        profileImageView.makeCircleStyle()
        
        newLabel.layer.cornerRadius = 18 / 2
        newLabel.layer.masksToBounds = true
    }
}


final class MyVoiceChatChannelCell: UITableViewCell {
    var downloadProfileImage: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileImageViewContainer: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var remainHourTimeLabel: UILabel!
    @IBOutlet weak var chatCountLabel: UILabel!
    @IBOutlet weak var remainDayTimeLabel: UILabel!
    @IBOutlet weak var newLabel: UILabel!
    
    var voiceChatRoomModel: VoiceChatRoomModel? {
        didSet {
            guard let voiceChatRoomModel = voiceChatRoomModel else {
                return
            }
            
            self.userNameLabel.text = voiceChatRoomModel.name

        }
    }
    
    var chatCount: Int = 0 {
        didSet {
            self.chatCountLabel.text = "\(chatCount)" + "개의 대화"
        }
    }
    
    var heartCount: Int = 0 {
        didSet {
            remainHourTimeLabel.attributedText = heartCount.heartCountLabelText
        }
    }
    
    func setProfileImage(imageUrl: String?) {
        self.profileImageView.image = nil
        if let url = imageUrl {
            downloadProfileImage.sd_setImage(with: URL(string: url)) { (image , error , cachType , url ) in
                if let img = image {
                    DispatchQueue.main.async {
                        let resizedImage = img.ResizeImage(targetSize: CGSize(width: 150, height: 150))
                        self.profileImageView.image = resizedImage
                    }
                }
                
                if let err = error {
                    #if DEBUG
                    print("url::: \(String(describing: url)), error::: \(err)")
                    #endif
                }
            }
        }
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        downloadProfileImage = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageViewContainer.makeCircleStyleWithBorder(borderWidth: 1.0, borderColor: UIColor(rgba: "#e3e1e0"))
        profileImageView.makeCircleStyle()
        
        newLabel.layer.cornerRadius = 18 / 2
        newLabel.layer.masksToBounds = true
    }
}
