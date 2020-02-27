//
//  Utility.swift
//  DateApp
//
//  Created by ryan on 12/23/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import Foundation

struct Utility {
}

func getScreenSize() -> CGSize{
    return UIScreen.main.bounds.size
}

func getKeyWindow() -> UIView {
    return UIWindow(frame: UIScreen.main.bounds)
}

func getTopViewController() -> UIViewController?{
    var topController: UIViewController? = nil
    topController = UIApplication.shared.keyWindow?.rootViewController
    while ((topController?.parent) != nil){
        topController = topController!.presentedViewController;
    }
    
    if let topNavigation = topController as? UINavigationController{
        let viewControllers = topNavigation.viewControllers
        topController = viewControllers.last
    }
    return topController
}
