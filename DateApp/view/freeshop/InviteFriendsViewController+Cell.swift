//
//  InviteFriendsViewController+Cell.swift
//  DateApp
//
//  Created by ryan on 12/17/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit

final class InviteFriendCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    
    static let freeshopBtnCheckOn = UIImage(assetIdentifier: UIImage.AssetIdentifier.freeshopBtnCheckOn)
    static let freeshopBtnCheckOff = UIImage(assetIdentifier: UIImage.AssetIdentifier.freeshopBtnCheckOff)
    
    var model: SelectableAddressModel? {
        didSet {
            guard let selectableAddressModel = model, let validAddressModel = selectableAddressModel.validAddressModel else {
                return
            }
            nameLabel.text = validAddressModel.name
            phoneNumberLabel.text = selectableAddressModel.globalFormattedPhoneNumber
            
            if selectableAddressModel.selected {
                checkImageView.image = InviteFriendCell.freeshopBtnCheckOn
            } else {
                checkImageView.image = InviteFriendCell.freeshopBtnCheckOff
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}