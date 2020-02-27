//
//  UIViewContoller+Extension.swift
//  DateApp
//
//  Created by ryan on 12/19/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit

extension UIViewController {
    
    static func viewControllerFromStoryboard(name storyboardName: String, identifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
    
    static weak var topViewController: UIViewController? {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
    
    func requireInfoAlert(handler: ((UIAlertAction) -> Void)?) {
        let title = "추가 정보를 입력하시겠어요?"
        let message = "상대방에게 호감을 표현하기 위해선 추가 회원정보를 입력해야 합니다."
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: handler))
        alertController.addAction(UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
}

extension UIApplication {
    static func topViewController() -> UIViewController {
        var topController: UIViewController = UIApplication.shared.windows[0].rootViewController!
        
        while (topController.presentedViewController != nil) {
            topController = topController.presentedViewController!
        }
        
        return topController
    }
}
