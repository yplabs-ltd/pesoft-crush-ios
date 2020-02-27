//
//  Select1PopupController+Cell.swift
//  DateApp
//
//  Created by ryan on 1/8/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import UIKit


final class Select1Cell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

final class Select1ParentCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var openStateImageView: UIImageView!
    
    private let closedImage = UIImage(assetIdentifier: UIImage.AssetIdentifier.PopupSelectOpenButton)
    private let openedImage = UIImage(assetIdentifier: UIImage.AssetIdentifier.PopupSelectCloseButton)
    var opened: Bool = false {
        didSet {
            if opened {
                openStateImageView.image = openedImage
            } else {
                openStateImageView.image = closedImage
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

final class Select1SubCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}