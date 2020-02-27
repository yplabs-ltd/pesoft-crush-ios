//
//  SelectableAddressesViewModel.swift
//  DateApp
//
//  Created by ryan on 1/17/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import Foundation

struct SelectableAddressModel {
    var addressModel: AddressModel?
    var validAddressModel: AddressModel?    // 11글자, 010 으로 시작
    var selected = false
    
    var globalFormattedPhoneNumber: String? {
        guard let number11 = validAddressModel?.phoneNumber , number11.validPhoneNumberStream() else {
            return nil
        }
        let str = number11 as NSString
    
        let first = str.substring(with: NSRange(location: 1, length: 2)) as String
        let middle = str.substring(with: NSRange(location: 3, length: 4)) as String
        let last = str.substring(with: NSRange(location: 4, length: 4)) as String
        
        return "+82-\(first)-\(middle)-\(last)"
        
    }
    
    init (name: String, phoneNumber: String) {
        addressModel = AddressModel(name: name, phoneNumber: phoneNumber)
        let numberStream = phoneNumber.trim().replacingOccurrences(of: "-", with: "")
        if numberStream.validPhoneNumberStream() {
            validAddressModel = AddressModel(name: name, phoneNumber: numberStream)
        }
    }
    
}
class SelectableAddressesViewModel: DViewModel<[SelectableAddressModel]> {
    
    var selectedAddresses: [AddressModel] {
        guard let model = model else {
            return []
        }
        let selectedAddresses: [AddressModel] = model.filter({ (selectableAddressModel) -> Bool in
            if selectableAddressModel.selected && selectableAddressModel.validAddressModel != nil {
                return true
            }
            return false
        }).map({ (selectableAddressModel) -> AddressModel in
            return selectableAddressModel.validAddressModel!
        })
        return selectedAddresses
    }
    
    let requiredSelectedFriendsCount = 10
    var requiredSelectedFriendsOk: Bool {
        if requiredSelectedFriendsCount <= selectedAddresses.count {
            return true
        }
        return false
    }
    
    var selectedFormattedPhoneNumbers: [String] {
        guard let selectableAddressesModel = model else {
            return []
        }
        let phoneNumbers = selectableAddressesModel.filter({ (selectableAddressModel) -> Bool in
            guard selectableAddressModel.selected else {
                return false
            }
            guard selectableAddressModel.globalFormattedPhoneNumber != nil else {
                return false
            }
            return true
        }).map({ (selectableAddressModel) -> String in
            return selectableAddressModel.globalFormattedPhoneNumber!
        })
        return phoneNumbers
    }
}
