//
//  UINavigationController+Extension.swift
//  DateApp
//
//  Created by ryan on 12/26/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit

extension UINavigationController: UIGestureRecognizerDelegate {
    
    func makeNavigationBarTransparentStyle() {
        
        // navigation bar bottom line hide
        navigationBar.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        navigationBar.shadowImage = UIImage()
        
        // 아이콘 tint Color
        navigationBar.tintColor = UIColor(rgba: "#726763")
        navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor(rgba: "#726763")   // 제목 색
        ]
        
        // back button옆의 title 문구를 안보이게 합니다.
        navigationBar.topItem?.title = "";
        
        // for back swipe
        interactivePopGestureRecognizer?.delegate = self  // (UIGestureRecognizerDelegate)
        self.interactivePopGestureRecognizer?.isEnabled = false
        
    }
    
    func makeNavigationBarDefaultStyle() {
        var image = #imageLiteral(resourceName: "icBackLeft")
        
        // 아이콘 tint Color
        navigationBar.tintColor = UIColor(rgba: "#726763")
        navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor(rgba: "#726763")   // 제목 색
        ]
        
        // back button옆의 title 문구를 안보이게 합니다.
        navigationBar.topItem?.title = "";
        
        self.view.backgroundColor = UIColor.white

        // for back swipe
        interactivePopGestureRecognizer?.delegate = self  // (UIGestureRecognizerDelegate)
        self.interactivePopGestureRecognizer?.isEnabled = false
    }
}
