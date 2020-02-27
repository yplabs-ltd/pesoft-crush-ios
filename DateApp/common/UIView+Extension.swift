//
//  UIView+Extension.swift
//  DateApp
//
//  Created by ryan on 12/20/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit

extension UIView {
    
    // MAKR: - 원형 view 를 만들기 위한 methods
    
    func makeCircleStyle() {
        layer.cornerRadius = frame.size.width / 2
        layer.masksToBounds = true
    }
    
    func makeHCircleStyle() {
        layer.cornerRadius = frame.size.height / 2
        layer.masksToBounds = true
    }
    
    func makeBorderForWidth(borderWidth: CGFloat, borderColor: UIColor) {
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
    }
    
    func makeCircleStyleWithBorder(borderWidth: CGFloat, borderColor: UIColor) {
        makeCircleStyle()
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
    }
    
    // view 안에 imageview 를 가지고 있습니다. 태두리(border) 있는 이미지 컨테이너에 대한 세팅을 합니다.
    func makeCircleImageContainerWithBorder(borderWidth: CGFloat, borderColor: UIColor) {
        makeCircleStyleWithBorder(borderWidth: borderWidth, borderColor: borderColor)
        if let imageView = subviews.first {
            imageView.makeCircleStyle()
        }
    }
    
    func makeBottomBorder(borderWidth: CGFloat, borderColor: UIColor) -> CALayer {
        let bottomBorder = CALayer()
        bottomBorder.backgroundColor = borderColor.cgColor
        bottomBorder.frame = CGRect(x: 16, y: frame.size.height - borderWidth, width: frame.size.width - 32, height: borderWidth)
        layer.addSublayer(bottomBorder)
        return bottomBorder
    }
}

