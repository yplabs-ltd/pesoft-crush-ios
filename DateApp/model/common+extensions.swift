//
//  common+extensions.swift
//  DateApp
//
//  Created by Lim Daehyun on 2018. 2. 10..
//  Copyright © 2018년 iflet.com. All rights reserved.
//

import Foundation
import UIKit

extension CGRect {
    init(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) {
        self.init(x:x, y:y, width:w, height:h)
    }
}

extension UILabel {
    func setLabelStyle(style: LabelStyle) {
        self.font = style.font
        self.textColor = style.normalColor
    }
}

extension Array {
    mutating func modifyForEach(body: (_ index: Index, _ element: inout Element) -> ()) {
        for index in indices {
            modifyElement(atIndex: index) { body(index, &$0) }
        }
    }
    
    mutating func modifyElement(atIndex index: Index, modifyElement: (_ element: inout Element) -> ()) {
        var element = self[index]
        modifyElement(&element)
        self[index] = element
    }
}

extension String {
    func trimWhiteSpace() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    func allRanges(of aString: String) -> [NSRange] {
        var result: [NSRange] = []
        
        var range = NSString(string: self).range(of: aString)
        var append = range
        while range.location != NSNotFound {
            result.append(append)
            
            let str = NSString(string: self).substring(from: append.location + 1)
            range = NSString(string: str).range(of: aString)
            
            if range.location != NSNotFound {
                append.location += (range.location + 1)
            }
        }
        
        return result
    }
}

extension IndexPath {
    func getProfileImageIndex() -> Int {
        if row < 2 {
            return row
        }else if row > 2 {
            return row - 1
        }
        
        return row
    }
}

extension Int {
    var heartCountLabelText: NSAttributedString {
        get {
            let attributedString = NSMutableAttributedString()
            
            let imageAttachment =  NSTextAttachment()
            imageAttachment.image = UIImage(named:"icoHeartSmall")
            imageAttachment.bounds = CGRect(x: 0, y: 0, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
            
            let attatchmentImage = NSAttributedString(attachment: imageAttachment)
            attributedString.append(attatchmentImage)
            
            let countAttributedString = NSMutableAttributedString(string:" \(self)", attributes:[.font : UIFont.systemFont(ofSize: 15), .foregroundColor : UIColor(r: 114, g: 103, b: 99) ])
            attributedString.append(countAttributedString)
            
            return attributedString
        }
    }
}
