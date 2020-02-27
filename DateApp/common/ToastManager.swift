//
//  ToastManager.swift
//  DateApp
//
//  Created by Daehyun Lim on 2017. 6. 16..
//  Copyright © 2017년 iflet.com. All rights reserved.
//

import Foundation
import Toast_Swift

class Toast {
    class func makeToastStyle() -> ToastStyle {
        var style = ToastStyle()
        style.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 0.85)
        style.cornerRadius = 5.0
        style.titleAlignment = .center
        style.messageAlignment = .center
        style.horizontalPadding = 25.0
        return style
    }
    
    class func showToast(message: String, duration: TimeInterval? = 1.5) {
        let time = DispatchTime.now() + Double(Int64((duration ?? 0) * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            UIApplication.topViewController().view.makeToast(message, duration: (duration ?? 0), position: .bottom, title: nil, image: nil, style: Toast.makeToastStyle(), completion: nil)
        }
    }
}
