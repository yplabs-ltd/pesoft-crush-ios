//
//  XibView.swift
//  KakaoMap
//
//  Created by Lim Daehyun on 2016. 9. 27..
//  Copyright © 2016년 Kakao Corp. All rights reserved.
//

import UIKit

class XibView: UIView {
    var view : UIView!
    var nibName : String {
        get {
            return ""
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        xibSetup()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        return UINib(nibName: nibName, bundle: bundle).instantiate(withOwner: self, options: nil)[0] as! UIView
    }
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
}
