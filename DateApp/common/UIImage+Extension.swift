//
//  UIImage+Extension.swift
//  DateApp
//
//  Created by ryan on 12/12/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit

extension UIImage {
    enum AssetIdentifier: String {
        case Menu = "menu"
        case Close = "close"
        case BlankImage = "blankimage"
        case Back = "icBackLeft"  //"back"
        case Checkmark = "checkmark"
        case ButtonAreaBgH40px = "button-area-bg-h40px"
        case Like = "like"
        case Dislike = "dislike"
        case PhotoOptional = "photo_optional"
        case PhotoRequired = "photo_required"
        case PopupSelectCloseButton = "popup_select_close_button"
        case PopupSelectOpenButton = "popup_select_open_button"
        case ILike = "ilike"
        case LikesMe = "likesme"
        case favorMatch = "favorMatch"
        case PastPopGirl = "pastpopgirl"    // 지나간 인기녀
        case FavorMe = "favorme"            // 나에게 호감이 있어요
        case IFavor = "ifavor"              // 내가 호감이 있어요
        case detailsBtnChatClose = "details_btn_chat_close"
        case detailsBtnChat = "details_btn_chat"
        case shopBird1 = "shop_bird1"
        case shopBird2 = "shop_bird2"
        case shopBird3 = "shop_bird3"
        case shopBird4 = "shop_bird4"
        case shopBirdN = "shop_birdn"
        case loginAniBird01 = "login_ani_bird01"
        case loginAniBird02 = "login_ani_bird02"
        case loginAniBird03 = "login_ani_bird03"
        case loginAniBird04 = "login_ani_bird04"
        case loginAniBird05 = "login_ani_bird05"
        case loginAniBird06 = "login_ani_bird06"
        case loginAniBird07 = "login_ani_bird07"
        case loginAniBird08 = "login_ani_bird08"
        case loginAniBird09 = "login_ani_bird09"
        case loginAniBird10 = "login_ani_bird10"
        case loginAniBird11 = "login_ani_bird11"
        case loginAniBird12 = "login_ani_bird12"
        case loadingAniBird01 = "loading_ani_01"
        case loadingAniBird02 = "loading_ani_02"
        case loadingAniBird03 = "loading_ani_03"
        case loadingAniBird04 = "loading_ani_04"
        case loadingAniBird05 = "loading_ani_05"
        case loadingAniBird06 = "loading_ani_06"
        case freeshopBtnCheckOn = "freeshop_btn_check_on"
        case freeshopBtnCheckOff = "freeshop_btn_check_off"
        case detailBtnReportNormal = "detail_btn_report_normal"
        case detailBtnReportPressed = "detail_btn_report_pressed"
        case homeBtnChatDisabled = "home_btn_chat_disabled"
        case homeBtnChatNewNormal = "home_btn_chat_new_normal"
        case homeBtnChatNewPressed = "home_btn_chat_new_pressed"
        case homeBtnChatNormal = "home_btn_chat_normal"
        case Profilelock = "profilelock"
        case HomeThumbnailDefault = "home_thumbnail_default"
        
    }
    
    
    convenience init!(assetIdentifier: AssetIdentifier) {
        self.init(named: assetIdentifier.rawValue)
    }
    
    func ResizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetSize.width  / self.size.width
        let heightRatio = targetSize.height / self.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    class func imageWithColor(color: UIColor) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func imageForSize(targetSize: CGSize) -> UIImage? {
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    static var birdFrames: [UIImage] {
        let birds = [
            UIImage(assetIdentifier: .loginAniBird01)!,
            UIImage(assetIdentifier: .loginAniBird02)!,
            UIImage(assetIdentifier: .loginAniBird03)!,
            UIImage(assetIdentifier: .loginAniBird04)!,
            UIImage(assetIdentifier: .loginAniBird05)!,
            UIImage(assetIdentifier: .loginAniBird06)!,
            UIImage(assetIdentifier: .loginAniBird07)!,
            UIImage(assetIdentifier: .loginAniBird08)!,
            UIImage(assetIdentifier: .loginAniBird09)!,
            UIImage(assetIdentifier: .loginAniBird10)!,
            UIImage(assetIdentifier: .loginAniBird11)!,
            UIImage(assetIdentifier: .loginAniBird12)!
        ]
        return birds
    }
    
    static var birdLoadingFrames: [UIImage] {
        let birds = [
            UIImage(assetIdentifier: .loadingAniBird01)!,
            UIImage(assetIdentifier: .loadingAniBird02)!,
            UIImage(assetIdentifier: .loadingAniBird03)!,
            UIImage(assetIdentifier: .loadingAniBird04)!,
            UIImage(assetIdentifier: .loadingAniBird05)!,
            UIImage(assetIdentifier: .loadingAniBird06)!,
        ]
        return birds
    }
}
