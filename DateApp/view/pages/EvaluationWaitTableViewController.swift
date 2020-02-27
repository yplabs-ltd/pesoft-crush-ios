//
//  EvaluationWaitTableViewController.swift
//  DateApp
//
//  Created by ryan on 12/21/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit

class EvaluationWaitTableViewController: UITableViewController {
    var rippleLayer: RippleLayer? = nil
    var checkTimer: Timer? = nil
    @IBOutlet var containerView: UIView!
    
    deinit {
        rippleLayer?.stopAnimation()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setRippleLayer()
        checkTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.checkRippleAnimationPlay), userInfo: nil, repeats: true)
        _app.secondViewModel.bindThenFire (view: self) { [weak self] (model, oldModel) -> () in
            guard let _ = _app.evaluationCardsViewModel.model else {
                return
            }
            if let parent = self?.parent as? EvaluationViewController {
                parent.choiceEmbededSegue()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setRippleLayer() {
        if rippleLayer == nil {
            rippleLayer = RippleLayer()
            let screenSize = CGSize(width: UIScreen.main.bounds.width, height: 333)
            rippleLayer?.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
            self.containerView.layer.insertSublayer(rippleLayer!, at: 0)
        } else {
            rippleLayer?.stopAnimation()
        }
        
        let time = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) { [weak self] in
            guard let wself = self else { return }
            wself.rippleLayer?.startAnimation()
        }
    }
    
    @objc func checkRippleAnimationPlay() {
        if rippleLayer?.isAnimationRunning == false {
            rippleLayer?.startAnimation()
        }
    }
}
