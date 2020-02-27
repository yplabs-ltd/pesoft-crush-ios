//
//  PopupListViewCell.swift
//  KakaoMap
//
//  Created by Lim Daehyun on 2016. 12. 14..
//  Copyright © 2016년 Kakao Corp. All rights reserved.
//

import Foundation
class PopupListViewCell: UICollectionViewCell {
    static let cellHeight: CGFloat = 50
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func setCellData(title: CodeValueModel, isSelected: Bool) {
        titleLabel.text = title.value       
        titleLabel.textColor = isSelected ? UIColor(red: 236/255, green: 82/255, blue: 72/255, alpha: 1.0) : UIColor(red: 138/255, green: 130/255, blue: 126/255, alpha: 1.0)
    }
}
