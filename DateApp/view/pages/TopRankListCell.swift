//
//  TopRankListCell.swift
//  DateApp
//
//  Created by Daehyun Lim on 2018. 5. 18..
//  Copyright © 2018년 iflet.com. All rights reserved.
//

import Foundation
import AVFoundation
import SnapKit
import SDWebImage


final class TopRankListCell: UITableViewCell {
    var downloadProfileImage: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileImageViewContainer: UIView!
    
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var heartCountLabel: UILabel!
    @IBOutlet weak var rankImageView: UIImageView!
    
    var voiceChatRoomModel: VoiceChatRoomModel? {
        didSet {
            guard let voiceChatRoomModel = voiceChatRoomModel else {
                return
            }
            
            self.userNameLabel.text = voiceChatRoomModel.name
            
        }
    }
    
    var isEnableBlurImage: Bool = false
    
    var rank: Int? = nil {
        didSet {
            rankLabel.text = ""
            if let r = rank {
                rankLabel.text = "\(r)위"
                
                if rank == 1 {
                    rankImageView.image = UIImage(named: "icoGold")
                }else if rank == 2 {
                    rankImageView.image = UIImage(named: "icoSilver")
                }else if rank == 3 {
                    rankImageView.image = UIImage(named: "icoBronze")
                }
            }
        }
    }
    
    var heartCount: Int = 0 {
        didSet {
            heartCountLabel.attributedText = heartCount.heartCountLabelText
        }
    }
    
    func setRankInfo(rank: VoiceRankModel) {
        setProfileImage(imageUrl: rank.profileImageUrl)
        self.rank = rank.highestRank
        heartCount = rank.heartCount ?? 0
        userNameLabel.text = rank.name
    }
    
    func enableRankImageView(isEnable: Bool) {
        rankImageView.isHidden = !isEnable
    }
    
    func setProfileImage(imageUrl: String?) {
        self.profileImageView.image = nil
        if let url = imageUrl {
            downloadProfileImage.sd_setImage(with: URL(string: url)) { (image , error , cachType , url ) in
                if let img = image {
                    DispatchQueue.main.async {
                        let resizedImage = img.ResizeImage(targetSize: CGSize(width: 150, height: 150))
                        self.profileImageView.image = self.isEnableBlurImage ? resizedImage.applyLightEffect() : resizedImage
                    }
                }
                
                if let err = error {
                    #if DEBUG
                        print("url::: \(url), error::: \(err)")
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
    }
}


final class TopRankInfoCell: UITableViewCell {
    @IBOutlet weak var topLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let topMessage = "현재 가장 많은 하트를 받은 오늘의 목소리입니다."
        let topInfoCard = NSMutableAttributedString(string: topMessage)
        topLabel.attributedText = topInfoCard;
    }
}

final class TopRankSectionCell: UITableViewCell {
    @IBOutlet weak var topLabel: UILabel!
    
    var isBold: Bool = false {
        didSet {
            if isBold {
                topLabel.font = UIFont.boldSystemFont(ofSize: 14)
            }else {
                topLabel.font = UIFont.systemFont(ofSize: 14)
            }
        }
    }
    
    var titleColor: UIColor = UIColor.black {
        didSet {
            topLabel.textColor = titleColor
        }
    }
    
    var title: String? = nil {
        didSet {
            topLabel.text = title
        }
    }
}

