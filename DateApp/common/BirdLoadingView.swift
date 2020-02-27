//
//  BirdLoadingView.swift
//  DateApp
//
//  Created by daehyun on 2016. 6. 30..
//  Copyright © 2016년 iflet.com. All rights reserved.
//

import Foundation

let BirdLoadingView = _BirdLoadingView.sharedInstance

class _BirdLoadingView : NSObject {
    private var birdImageView: UIImageView!
    
    class var sharedInstance : _BirdLoadingView {
        struct Static {
            static let instance : _BirdLoadingView = _BirdLoadingView()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        
        birdImageView = UIImageView(frame: CGRect(x: (getScreenSize().width - 45)/2, y: (getScreenSize().height - 38)/2, width: 45, height: 38))
        birdImageView.animationDuration = 0.5
        birdImageView.animationImages = UIImage.birdFrames
        birdImageView.animationRepeatCount = 0
        birdImageView.isHidden = true
        getKeyWindow().addSubview(birdImageView)
    }
    
    func startLoading() {
        birdImageView.isHidden = false
        birdImageView.startAnimating()
    }
    
    func stopLoading(){
        birdImageView.isHidden = true
        birdImageView.stopAnimating()
    }
}
