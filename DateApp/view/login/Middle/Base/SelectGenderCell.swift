//
//  SelectGenderCell.swift
//  DateApp
//
//  Created by Lim Daehyun on 2018. 2. 10..
//  Copyright © 2018년 iflet.com. All rights reserved.
//

import Foundation
import UIKit

enum SelectedGender: String {
    case male = "남자"
    case female = "여자"
}

let selectedColor: UIColor = UIColor(r: 114, g: 103, b: 99)
let normalColor: UIColor = UIColor(r: 114, g: 103, b: 99, a: 0.3)

class SelectGenderCell: UICollectionViewCell {
    @IBOutlet weak var maleBGView: UIView!
    @IBOutlet weak var femaleBGView: UIView!
    
    @IBOutlet weak var maleLabel: UILabel!
    @IBOutlet weak var femaleLabel: UILabel!
    
    @IBOutlet weak var maleBottomBorder: UIView!
    @IBOutlet weak var femaleBottomBorder: UIView!
    
    var onSelectGender: ((String?) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let t1 = UITapGestureRecognizer(target: self, action: #selector(self.tapMale(_:)))
        maleBGView.addGestureRecognizer(t1)
        
        let t2 = UITapGestureRecognizer(target: self, action: #selector(self.tapFemale(_:)))
        femaleBGView.addGestureRecognizer(t2)
        
        initUIComponents()
    }
    
    @objc func tapMale(_ gesture: UITapGestureRecognizer) {
        selectedGender = .male
        onSelectGender?(selectedGender?.rawValue)
    }
    
    @objc func tapFemale(_ gesture: UITapGestureRecognizer) {
        selectedGender = .female
        onSelectGender?(selectedGender?.rawValue)
    }
    
    var selectedGender: SelectedGender? {
        didSet {
            guard let g = selectedGender else {
                initUIComponents()
                return
            }
            
            enableGender(gender: g)
        }
    }
    
    func initUIComponents() {
        maleLabel.textColor = normalColor
        femaleLabel.textColor = normalColor
        
        maleBottomBorder.backgroundColor = normalColor
        femaleBottomBorder.backgroundColor = normalColor
        
    }
    
    func enableGender(gender: SelectedGender){
        maleLabel.textColor = gender == .male ? selectedColor : normalColor
        maleBottomBorder.backgroundColor = gender == .male ? selectedColor : normalColor
        
        femaleLabel.textColor = gender == .female ? selectedColor : normalColor
        femaleBottomBorder.backgroundColor = gender == .female ? selectedColor : normalColor
    }
}
