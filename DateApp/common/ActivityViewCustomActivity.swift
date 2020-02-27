//
//  File.swift
//  DateApp
//
//  Created by Daehyun Lim on 2018. 6. 30..
//  Copyright © 2018년 iflet.com. All rights reserved.
//

import Foundation
class ActivityViewCustomActivity: UIActivity {
    
    // MARK: Properties
    
    var customActivityType: UIActivityType
    var activityName: String
    var activityImageName: String
    var customActionWhenTapped: () -> Void
    
    
    // MARK: Initializer
    
    init(title: String, imageName: String, performAction: @escaping () -> Void) {
        self.activityName = title
        self.activityImageName = imageName
        self.customActivityType = UIActivityType(rawValue: "Action \(title)")
        self.customActionWhenTapped = performAction
        super.init()
    }
    
    
    
    // MARK: Overrides
    
    override var activityType: UIActivityType? {
        return customActivityType
    }
    
    
    
    override var activityTitle: String? {
        return activityName
    }
    
    
    
    override class var activityCategory: UIActivityCategory {
        return .action
    }
    
    
    
    override var activityImage: UIImage? {
        return UIImage(named: activityImageName)
    }
    
    
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    
    
    override func prepare(withActivityItems activityItems: [Any]) {
        // Nothing to prepare
    }
    
    
    
    override func perform() {
        customActionWhenTapped()
    }
}

