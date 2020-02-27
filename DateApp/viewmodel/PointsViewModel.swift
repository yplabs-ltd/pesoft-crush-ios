//
//  PointsViewModel.swift
//  DateApp
//
//  Created by ryan on 2/3/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import Foundation

class PointsViewModel: DViewModel<[PointModel]> {
    
    func getPointModelByProductIdentifier(identifier: String) -> PointModel? {
        guard let pointsModel = model else {
            return nil
        }
        let results = pointsModel.filter { (pointModel) -> Bool in
            if pointModel.identifier.rawValue == identifier {
                return true
            }
            return false
        }
        if 0 < results.count {
            return results[0]
        } else {
            return nil
        }
    }
}