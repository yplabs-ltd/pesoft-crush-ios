//
//  PointModel.swift
//  DateApp
//
//  Created by ryan on 2/3/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import Foundation
import StoreKit


struct PointModel {
    
    var product: SKProduct
    
    var identifier: Identifier
    var pointCount: Int
    var bonusCount: Int
    var promotionCount: Int
    var priceString: String?
    
    init(product: SKProduct) {
        self.product = product
        guard let identifier = Identifier(rawValue: product.productIdentifier) else {
            fatalError()
        }
        self.identifier = identifier
        
        let priceFormatter = NumberFormatter()
        priceFormatter.numberStyle = .currency
        priceFormatter.locale = product.priceLocale
        priceString = priceFormatter.string(from: product.price)
        
        switch identifier {
        case .Point30, .Point30Event:
            pointCount = 30
            bonusCount = 0
            promotionCount = 15
        case .Point80:
            pointCount = 80
            bonusCount = 5
            promotionCount = 5
        case .Point150, .Point150Event:
            pointCount = 150
            bonusCount = 15
            promotionCount = 75
        case .Point300:
            pointCount = 300
            bonusCount = 40
            promotionCount = 40
        case .Point600, .Point600Event:
            pointCount = 600
            bonusCount = 100
            promotionCount = 300

        }
    }
    
    enum Identifier: String {
        case Point30 = "point030"
        case Point80 = "point080"
        case Point150 = "point150"
        case Point300 = "point300"
        case Point600 = "point600"
        case Point30Event = "point030_event"
        case Point150Event = "point150_event"
        case Point600Event = "point600_event"
        
        func pointValue() -> Int {
            switch self {
            case .Point30:
                return 0
            case .Point30Event:
                return 1
            case .Point80:
                return 2
            case .Point150:
                return 3
            case .Point150Event:
                return 4
            case .Point300:
                return 5
            case .Point600:
                return 6
            case .Point600Event:
                return 7
            }
        }
    }
}
