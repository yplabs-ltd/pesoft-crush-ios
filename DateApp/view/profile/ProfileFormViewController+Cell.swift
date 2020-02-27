//
//  ProfileFormViewController+Cell.swift
//  DateApp
//
//  Created by ryan on 1/4/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import UIKit

final class ProfileInputFieldCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var inputLabel: UILabel!
    @IBOutlet weak var bottomLineView: UIView!
    
    var placeholer: String?
    var data: String = "" {
        didSet {
            
            if data.trim() == "" {
                let color = UIColor(rgba: "#dbd8d8")
                inputLabel.textColor = color
                inputLabel.text = placeholer
                bottomLineView.backgroundColor = color
            } else {
                let color = UIColor(rgba: "#726763")
                inputLabel.textColor = color
                inputLabel.text = data
                bottomLineView.backgroundColor = color
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func initializeFieldTitle(title: String, placeholder: String) {
        titleLabel.text = title
        self.placeholer = placeholder
    }
    
}
