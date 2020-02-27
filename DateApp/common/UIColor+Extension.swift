//
//  UIColor+Extension.swift
//  Hogwarts
//
//  Created by ryan on 5/4/15.
//  Copyright (c) 2015 kakao. All rights reserved.
//

import UIKit

// MARK: - UIColor RGB Hexa 값으로 생성 할수 있게 하는 생성자 (git@github.com:yeahdongcn/UIColor-Hex-Swift.git)
extension UIColor {
    convenience init(rgba: String) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        if rgba.hasPrefix("#") {
            let index   = rgba.index(rgba.startIndex, offsetBy: 1)
            let hex     = String(rgba[index...])
            let scanner = Scanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexInt64(&hexValue) {
                if hex.count == 6 {
                    red   = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)  / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF) / 255.0
                } else if hex.count == 8 {
                    red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
                } else {
                    print("invalid rgb string, length should be 7 or 9")
                }
            } else {
                print("scan hex error")
            }
        } else {
            print("invalid rgb string, missing '#' as prefix")
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    convenience init(r: Int, g: Int, b: Int) {
        self.init(red:CGFloat(r)/255, green:CGFloat(g)/255, blue:CGFloat(b)/255, alpha:1.0)
    }
    
    convenience init(r: Int, g: Int, b: Int, a: CGFloat) {
        self.init(red:CGFloat(r)/255, green:CGFloat(g)/255, blue:CGFloat(b)/255, alpha:a)
    }
}

// MARK: - app point color
extension UIColor {
    public class func appBackgroundGray() -> UIColor {
        return UIColor(rgba: "#eeecee")
    }
}
