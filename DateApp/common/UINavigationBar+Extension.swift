//
//  UINavigationBar+Extension.swift
//  DateApp
//
//  Created by Lim Daehyun on 2016. 12. 20..
//  Copyright © 2016년 iflet.com. All rights reserved.
//

import Foundation


extension UINavigationBar {
    
    func setBottomBorderColor(color: UIColor, height: CGFloat) {
        let bottomBorderRect1 = CGRect(x: 0, y: frame.height, width: frame.width, height: height)
        let bottomBorderView1 = UIView(frame: bottomBorderRect1)
        bottomBorderView1.backgroundColor = UIColor.white
        addSubview(bottomBorderView1)
        
        let bottomBorderRect = CGRect(x: 16, y: frame.height, width: frame.width - 32, height: height)
        let bottomBorderView = UIView(frame: bottomBorderRect)
        bottomBorderView.backgroundColor = color
        addSubview(bottomBorderView)
    }
    
    func setBottomNomaringBorderColor(color: UIColor, height: CGFloat) {
        let bottomBorderRect1 = CGRect(x: 0, y: frame.height, width: frame.width, height: height)
        let bottomBorderView1 = UIView(frame: bottomBorderRect1)
        bottomBorderView1.backgroundColor = UIColor.white
        addSubview(bottomBorderView1)
        
        let bottomBorderRect = CGRect(x: 0, y: frame.height, width: frame.width, height: height)
        let bottomBorderView = UIView(frame: bottomBorderRect)
        bottomBorderView.backgroundColor = color
        addSubview(bottomBorderView)
    }
}

extension NSLayoutConstraint {
    
    @IBInspectable var preciseConstant: Int {
        get {
            return Int(constant * UIScreen.main.scale)
        }
        set {
            constant = CGFloat(newValue) / UIScreen.main.scale
        }
    }
}
