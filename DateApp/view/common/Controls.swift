//
//  Controls.swift
//  DateApp
//
//  Created by ryan on 12/27/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit

class MainLoadingIndicatorView: UIView {
    private let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    private var birdImageView: UIImageView!
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: getScreenSize().width, height: getScreenSize().height))
        
        isHidden = true
        isUserInteractionEnabled = false
        layer.cornerRadius = 10
        layer.masksToBounds = true
        backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        indicatorView.isUserInteractionEnabled = false
        addSubview(indicatorView)
        
        setBirdAnimationView()
        
        addConstraints([
            DConstraintsBuilder.centerH(view: indicatorView, superview: self),
            DConstraintsBuilder.centerV(view: indicatorView, superview: self)])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setBirdAnimationView(){
        birdImageView = UIImageView(frame: CGRect(x: (getScreenSize().width - 70)/2, y: (getScreenSize().height - 70)/2, width: 70, height: 70))
        birdImageView.image = UIImage.birdLoadingFrames.last
        birdImageView.animationDuration = 0.5
        birdImageView.animationImages = UIImage.birdLoadingFrames
        birdImageView.animationRepeatCount = 0
        birdImageView.isHidden = true
        addSubview(birdImageView)
    }
    
    func startAnimating() {
        isHidden = false
        /*
        indicatorView.startAnimating()
        */
        
        birdImageView.isHidden = false
        birdImageView.startAnimating()
    }
    func stopAnimating() {
        isHidden = true
        
        /*
        indicatorView.stopAnimating()
        */
        
        birdImageView.isHidden = true
        birdImageView.stopAnimating()
    }
}
