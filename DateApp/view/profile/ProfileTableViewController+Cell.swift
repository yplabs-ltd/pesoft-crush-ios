//
//  ProfileViewController+Cell.swift
//  DateApp
//
//  Created by ryan on 12/14/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit

final class ProfileMessageCell: UITableViewCell {
    
    @IBOutlet weak var messageLabel: UILabel!
    
    var message: String {
        get {
            return messageLabel.text ?? ""
        }
        set {
            messageLabel.text = newValue
            messageLabel.sizeToFit()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

final class ProfilePhotosCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

final class ProfileRequiredPhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    let defaultImage = UIImage(assetIdentifier: UIImage.AssetIdentifier.PhotoRequired)
    
    var imageInfo: ProfileModel.ImageInfo? {
        didSet {
            if let image = imageInfo?.image {
                profileImageView.image = image
            } else {
                // default image
                profileImageView.image = defaultImage
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.makeCircleStyleWithBorder(borderWidth: 1.0, borderColor: UIColor(rgba: "#e3e1e0"))
    }
}

final class ProfilePhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImageViewContrainer: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    let defaultImage = UIImage(assetIdentifier: UIImage.AssetIdentifier.PhotoOptional)
    
    var imageInfo: ProfileModel.ImageInfo? {
        didSet {
            if let image = imageInfo?.image {
                profileImageView.image = image
            } else {
                // default image
                profileImageView.image = defaultImage
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageViewContrainer.makeCircleImageContainerWithBorder(borderWidth: 1.0, borderColor: UIColor(rgba: "#e4e3e2"))
    }
}

final class ProfileVoiceCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImageViewContrainer: UIView!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    
    var onClickRecord: (() -> Void)?
    var onClickPlay: (() -> Void)?
    
    let defaultImage = UIImage(assetIdentifier: UIImage.AssetIdentifier.PhotoOptional)
    
    var voiceUrl: String? {
        didSet {
            recordBtn.isHidden = voiceUrl == nil ? false : true
            playBtn.isHidden = voiceUrl == nil ? true : false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        playBtn.makeCircleStyle()
        profileImageViewContrainer.makeCircleImageContainerWithBorder(borderWidth: 1.0, borderColor: UIColor(rgba: "#e4e3e2"))
    }
    
    @IBAction func onPressedRecord() {
        onClickRecord?()
    }
    
    @IBAction func onPressedPlay() {
        onClickPlay?()
    }
}


