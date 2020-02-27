//
//  Functions.swift
//  DateApp
//
//  Created by ryan on 1/9/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import UIKit

func alert(message: String, handler: ((UIAlertAction) -> Void)? = nil) {
    if message.length > 0 {
        alert(title: "안내", message: message, handler: handler)
    }
}

func alert(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
    guard message.length > 1 else {
        return
    }
    let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alertController.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: handler))
    UIViewController.topViewController?.present(alertController, animated: true, completion: nil)
}

func confirm(title: String, handler: ((UIAlertAction) -> Void)? = nil) {
    if title.length > 0 {
        confirm(title: title, message: nil, handler: handler)
    }
}

func confirm(title: String, message: String?, handler: ((UIAlertAction) -> Void)? = nil) {
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alertController.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: handler))
    alertController.addAction(UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel, handler: nil))
    UIViewController.topViewController?.present(alertController, animated: true, completion: nil)
}
