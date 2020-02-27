//
//  HeaderView.swift
//  vegas-ios
//
//  Created by Lim Daehyun on 2018. 1. 23..
//  Copyright © 2018년 refactoring. All rights reserved.
//

import Foundation
import UIKit

enum ButtonType {
    case arrow
    case clamp
    case next
    case done
    
    func getImage() -> UIImage? {
        switch self {
        case .arrow:
            return nil
        case .clamp:
            return nil
        default:
            return nil
        }
    }
}

struct ButtonInfo {
    let type: ButtonType?
    let title: String?
    let font: UIFont?
    let normalColor: UIColor?
    let pressedColor: UIColor?
}

class HeaderView: XibView {
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var onClickLeftButton: (() -> Void)?
    var onClickRightButton: ((ButtonType?) -> Void)?

    override func awakeFromNib() {
    }
    
    var leftButtonInfo: ButtonInfo! {
        didSet {
            setButtonStyle(leftButton, style: leftButtonInfo)
        }
    }
    
    var rightButtonInfo: ButtonInfo! {
        didSet {
            setButtonStyle(rightButton, style: rightButtonInfo)
        }
    }
    
    var title: String? {
        didSet {
            if let t = title {
                titleLabel.text = t
            }
        }
    }
    
    private func setButtonStyle(button: UIButton!, style: ButtonInfo) {
        if let img = style.type?.getImage() {
            button.setImage(img, forState: .Normal)
        }
        
        if let title = style.title {
            button.setTitle(title, forState: .Normal)
            button.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0)
        }
        
        if let f = style.font {
            button.titleLabel?.font = f
        }
        
        if let nColor = style.normalColor {
            button.setTitleColor(nColor, forState: .Normal)
        }
        
        if let pColor = style.pressedColor {
            button.setTitleColor(pColor, forState: .Highlighted)
        }else {
            button.setTitleColor(UIColor(white: 1, alpha: 0.5) , forState: .Highlighted)
        }
    }
    
    
    override var nibName : String {
        get {
            return "HeaderView"
        }
    }
    
    @IBAction func onClickLeft() {
        onClickLeftButton?()
    }
    
    @IBAction func onClickRight() {
        onClickRightButton?(rightButtonInfo.type)
    }
}
