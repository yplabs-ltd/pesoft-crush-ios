//
//  LoveButton.swift
//  LoveButton
//
//  Created by abedalkareem omreyh on 11/18/17.
//  Copyright © 2017 abedalkareem omreyh. All rights reserved.
//  github: https://github.com/Abedalkareem/LoveButton
//

import UIKit

@IBDesignable
class LoveButton: UIButton {
    
    /// Selected love button color.
    @IBInspectable var loveColor: UIColor! = UIColor.red
    /// unSelected love button color.
    @IBInspectable var unLoveColor: UIColor! = UIColor.gray
    /// The image that will show when the status of the button selected.
    @IBInspectable var loveImage: UIImage!
    /// The image that will show when the status of the button unselected.
    @IBInspectable var unLoveImage: UIImage!
    /// The number of views will show when the button pressed.
    @IBInspectable var numberOfHearts: Int = 100
    
    @IBInspectable var normalLoveImage: UIImage!
    
    @IBInspectable var selectedLoveImage: UIImage!
    
    /// When the value is true the color will be `loveColor` and the animation will start.
    var isLoved: Bool? = nil {
        didSet {
            changeStatus()
            guard let isLoved = isLoved,let oldValue = oldValue else {
                return
            }
            // check that the isLoved is equal to true and the old value for the isLoved was false
            if isLoved && !oldValue { addHearts() }
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard loveImage != nil && unLoveImage != nil else{
            fatalError("Please add loveImage and unLoveImage from the interface builder")
        }
        

        loveImage = loveImage.withRenderingMode(.alwaysOriginal)
        unLoveImage = unLoveImage.withRenderingMode(.alwaysOriginal)
        
        #if TARGET_INTERFACE_BUILDER
            isLoved = true
        #endif
        
        self.changeStatus()
    }
    
    
    private func animateLove() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut,
                                   animations: {
                                    [weak self] in
                                    if let wself = self {
                                        wself.changeStatus()
                                    }
            }, completion: {
                [weak self] finished in
                if let _ = self {
                }
            })
    }
    
    private func changeStatus() {
        let isLoved = self.isLoved ?? false
        self.setImage(isLoved ? self.selectedLoveImage : self.normalLoveImage, for: UIControlState.normal)
        self.tintColor = isLoved ? self.loveColor : self.unLoveColor
    }
    
    private func addHearts(){
        
        let window = UIApplication.shared.keyWindow!
        let viewFrame = window.convert(self.frame, from: self.superview)
        for _ in 0...numberOfHearts {
            let size = viewFrame.width*0.2 // size of the small images
            // the y and the x is on the mid of the button
            let x = viewFrame.origin.x+(viewFrame.size.width/2)
            let y = viewFrame.origin.y+(viewFrame.size.height/2)
            let frame = CGRect(x: x, y: y, width: size, height: size)
            
            let heart = UIImageView(frame: frame)
            heart.image = loveImage
            heart.tintColor = loveColor
            window.addSubview(heart)
            
            // a random number between half button width before the button, and half button width after the button
            let addedX = CGFloat(arc4random_uniform(UInt32(viewFrame.size.width*2)))-(viewFrame.size.width)
            // a random number between the mid of the button and the half of button height above the button
            let addedY = -CGFloat(arc4random_uniform(UInt32(viewFrame.height*1.5)))
            
            heart.moveTo(addToX: addedX, andToY: addedY, withDuration: Double(drand48()*2), completion: {
                // remove the image when finish animating
                heart.removeFromSuperview()
            })
        }
    }
    
}


// MARK: Animation
extension UIView{
    func moveTo(addToX x:CGFloat,andToY y:CGFloat,withDuration duration: TimeInterval, completion: @escaping () -> Void){
        
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut,
                                   animations: {
                                    [weak self] in
                                    if let wself = self {
                                        var frame = wself.frame
                                        frame.origin.y = frame.origin.y + y
                                        frame.origin.x = frame.origin.x + x
                                        wself.frame = frame
                                        
                                        wself.alpha = 0
                                        
                                    }
            }, completion: {
                [weak self] finished in
                if let _ = self {
                    completion()
                }
            })
    }
}


