//
//  LoginPointView.swift
//  DateApp
//
//  Created by Daehyun Lim on 2018. 2. 14..
//  Copyright © 2018년 iflet.com. All rights reserved.
//

import Foundation
class LoginPointView: XibView {
    @IBOutlet var pointButtons: Array<UIButton>!
    @IBOutlet var pointLabels: Array<UILabel>!
    @IBOutlet weak var pointTitle: UILabel!

    override var nibName : String {
        get {
            return "LoginPointView"
        }
    }
    
    func setLoginPointDay(_loggedDay: Int) {
        let loggedDay = _loggedDay % 6
        for btn in pointButtons {
            btn.isSelected = false
            btn.isEnabled = true
            
            if btn.tag == loggedDay {
                btn.isSelected = true
            } else if btn.tag < loggedDay {
                btn.isEnabled = false
            }
        }
        
        for (i,label) in pointLabels.enumerated() {
            if _app.sessionViewModel.model?.gender == "M" {
                label.text = i == 5 ? "3" : "1"
            }else{
                label.text = i == 5 ? "5" : "2"
            }
            
            label.isHidden = false
            if label.tag < loggedDay {
                label.isHidden = true
            }
        }
        
        pointTitle.text = "\(pointLabels[loggedDay].text!)버찌가 지급 되었습니다."
    }
    
    func show(loggedPoint: Int){
        addSubviewOnWindow()
        setLoginPointDay(_loggedDay: loggedPoint)
    }
    
    @IBAction func close() {
        self.removeFromSuperview()
    }
    
    @IBAction func openReview() {
        if let url = URL(string: _app.config.appstoreUrl) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func addSubviewOnWindow(){
        let window = UIApplication.shared.keyWindow
        let viewFrame = CGRect(x: 0, y: 0, width: window!.bounds.size.width, height: window!.bounds.size.height)
        self.frame = viewFrame
        
        /*
         bgView.layer.cornerRadius = 10
         bgView.layer.masksToBounds = true*/
        self.alpha = 0
        window!.addSubview(self)
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut,
                                   animations: {
                                    [weak self] in
                                    if let wself = self {
                                        wself.alpha = 1.0
                                    }
            }, completion: {
                [weak self] finished in
                if let _ = self {
                }
            })
    }
}
