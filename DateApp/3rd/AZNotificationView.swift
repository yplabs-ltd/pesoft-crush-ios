//
//  AZNotificationView.swift
//  AZNotificationDemo
//
//  Created by Mohammad Azam on 6/4/14.
//  Copyright (c) 2014 AzamSharp Consulting LLC. All rights reserved.
//

import Foundation
import UIKit

let notificationViewHeight :CGFloat = 64

enum AZNotificationType
{
    case Success,Error,Warning,Message
}

enum NotificationColors :String
{
    case Success = "#17BF30",
    Error = "#BF1525",
    Warning = "#BF3E12",
    Message = "#7F7978"
}

class AZNotificationView : UIView
{
    var title = ""
    var referenceView = UIView()
    var showNotificationUnderNavigationBar = false
    var animator = UIDynamicAnimator()
    var gravity = UIGravityBehavior()
    var collision = UICollisionBehavior()
    var itemBehavior = UIDynamicItemBehavior()
    var notificationType = AZNotificationType.Success
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(title :String, referenceView :UIView, notificationType :AZNotificationType)
    {
        self.title = title
        self.referenceView = referenceView
        self.notificationType = notificationType
        super.init(frame: CGRect(x: 0, y: 0, width: referenceView.bounds.size.width, height: notificationViewHeight))
        setup()
    }
    
    init(title :String, referenceView :UIView, notificationType :AZNotificationType, showNotificationUnderNavigationBar :Bool)
    {
        self.title = title
        self.referenceView = referenceView
        self.notificationType = notificationType
        self.showNotificationUnderNavigationBar = showNotificationUnderNavigationBar
        super.init(frame: CGRect(x: 0, y: 0, width: referenceView.bounds.size.width, height: notificationViewHeight))
        setup()
    }
    
    @objc func hideNotification()
    {
        animator.removeBehavior(gravity)
        gravity = UIGravityBehavior(items: [self])
        gravity.gravityDirection = CGVector(dx: 0, dy: -1)
        animator.addBehavior(gravity)
    }
    
    func applyDynamics()
    {
        let boundaryYAxis :CGFloat = showNotificationUnderNavigationBar == true ? 2 : 1
        animator = UIDynamicAnimator(referenceView: referenceView)
        gravity = UIGravityBehavior(items:[self])
        collision = UICollisionBehavior(items: [self])
        itemBehavior = UIDynamicItemBehavior(items: [self])
        
        itemBehavior.elasticity = 0.5

        collision.addBoundary(withIdentifier: "AZNotificationBoundary" as NSCopying, from: CGPoint(x: 0, y: self.bounds.size.height * boundaryYAxis), to: CGPoint(x: referenceView.bounds.size.width, y: self.bounds.size.height * boundaryYAxis))
        
        animator.addBehavior(gravity)
        animator.addBehavior(collision)
        animator.addBehavior(itemBehavior)
        
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.hideNotification), userInfo: nil, repeats: false)
    }
    
    func setup() {
        let screenBounds = UIScreen.main.bounds
        self.frame = CGRect(x: 0, y: showNotificationUnderNavigationBar == true ? 1 : -1 * notificationViewHeight, width: screenBounds.size.width, height: notificationViewHeight)
        
        setupNotificationType()
    
        let labelRect = CGRect(x: 10, y: 10, width: screenBounds.size.width, height: notificationViewHeight)
        
        let titleLabel = UILabel(frame: labelRect)
        titleLabel.text = title
        titleLabel.font = UIFont(name: "HelveticaNeue-Light", size: 17)
        titleLabel.textColor = UIColor.white
        
        addSubview(titleLabel)
    }
    
    func setupNotificationType()
    {
        switch notificationType
        {
        case .Success:
            backgroundColor = UIColor(rgba: NotificationColors.Success.rawValue)

        case .Error:
            backgroundColor = UIColor(rgba: NotificationColors.Error.rawValue)
            
        case .Warning:
            backgroundColor = UIColor(rgba: NotificationColors.Warning.rawValue)
            
        case .Message:
            backgroundColor = UIColor(rgba: NotificationColors.Message.rawValue)
            
        }

    }
}
