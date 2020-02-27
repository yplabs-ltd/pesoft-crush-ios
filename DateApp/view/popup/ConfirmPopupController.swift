//
//  ConfirmPopupController.swift
//  DateApp
//
//  Created by ryan on 1/15/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import UIKit

class ConfirmPopupController: UIViewController {

    @IBOutlet weak var line1Label: UILabel!
    @IBOutlet weak var line2Label: UILabel!
    @IBOutlet weak var line3Label: UILabel!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBAction func cancel(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submit(sender: AnyObject) {
        submitHandler?(self)
    }
    
    
    var line1: (text: String, type: LineType)?
    var line2: (text: String, type: LineType)?
    var line3: (text: String, type: LineType)?
    
    var cancel: String! = nil
    var submit: String! = nil
    
    var submitHandler: ((UIViewController) -> ())?
    
    enum LineType {
        case Title
        case Normal
        case Red
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let line1 = line1 {
            makeLabelStyle(label: line1Label, type: line1.type, text: line1.text)
        }
        if let line2 = line2 {
            makeLabelStyle(label: line2Label, type: line2.type, text: line2.text)
        }
        if let line3 = line3 {
            makeLabelStyle(label: line3Label, type: line3.type, text: line3.text)
        }
        
        if cancel != nil {
            cancelButton.setTitle(cancel, for: .normal)
        }
        
        if submit != nil {
            submitButton.setTitle(submit, for: .normal)
        }
    }
    
    deinit {
        print(#function, "\(self)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension ConfirmPopupController {
    private func makeLabelStyle(label: UILabel, type: LineType, text: String) {
        switch type {
        case .Title:
            label.textColor = UIColor(rgba: "#736763")
            label.font = UIFont.boldSystemFont(ofSize: 14.0)
            label.numberOfLines = 2
        case .Normal:
            label.textColor = UIColor(rgba: "#9c9491")
        case .Red:
            label.textColor = UIColor(rgba: "#f2503b")
            label.numberOfLines = 3
        }
        label.text = text
    }
}
