//
//  MyHeartListCell.swift
//  DateApp
//
//  Created by Daehyun Lim on 2018. 5. 17..
//  Copyright © 2018년 iflet.com. All rights reserved.
//

import Foundation
class MyHeartListCell: UITableViewCell {
    @IBOutlet weak var createdDateLabel: UILabel!
    @IBOutlet weak var heartCountLabel: UILabel!
    
    var heartCount: Int? = nil {
        didSet {
            heartCountLabel.attributedText =  heartCount != nil ? heartCount!.heartCountLabelText : 0.heartCountLabelText
        }
    }
    
    var createdDate: String? = nil {
        didSet {
            createdDateLabel.text = createdDate
        }
    }
}
