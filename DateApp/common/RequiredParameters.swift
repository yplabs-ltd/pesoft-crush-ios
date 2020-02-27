//
//  RequiredParameters.swift
//  DateApp
//
//  Created by ryan on 12/13/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit

// 부모 viewcontroller 를 가지고 있어야 한다
protocol CenterViewControllerRequired: GuardForRequiredParameter {
    var centerViewController: UIViewController! { get set }
}

protocol ProfileModelParameterRequired: GuardForRequiredParameter {
    var profileModel: ProfileModel! { get set }
}

protocol CardDetailModelRequired: GuardForRequiredParameter {
    var cardDetailModel: CardDetailModel! { get set }
}

protocol TargetUserIdRequired: GuardForRequiredParameter {
    var targetUserId: Int! { get set }
}

protocol NextDttmRequired: GuardForRequiredParameter {
    var nextDttm: Date! { get set }
}

protocol VoiceChatRoomModelRequeired: GuardForRequiredParameter {
    var voiceChatRoomModel : VoiceChatRoomModel! { get set }
}

protocol GuardForRequiredParameter {
    func guardForRequiredParameter()
}
extension GuardForRequiredParameter {
    // 필수 파라미터가 세팅되어있지 않으면 fatalError 발생해서 진행 막음
    func guardForRequiredParameter() {
        
        if let required = self as? CenterViewControllerRequired , required.centerViewController == nil {
            fatalError("required must be assigned. (CenterViewControllerRequired)")
        }
        if let required = self as? ProfileModelParameterRequired , required.profileModel == nil {
            fatalError("required must be assigned. (ProfileModelParameterRequired)")
        }
        if let required = self as? CardDetailModelRequired , required.cardDetailModel == nil {
            fatalError("required must be assigned. (CardDetailModelRequired)")
        }
        if let required = self as? TargetUserIdRequired , required.targetUserId == nil {
            fatalError("required must be assigned. (TargetUserIdRequired)")
        }
        if let required = self as? NextDttmRequired , required.nextDttm == nil {
            fatalError("required must be assigned. (NextDttmRequired)")
        }
        if let required = self as? VoiceChatRoomModelRequeired , required.voiceChatRoomModel == nil {
            fatalError("required must be assigned. (VoiceChatRoomModelRequeired)")
        }
    }
}
