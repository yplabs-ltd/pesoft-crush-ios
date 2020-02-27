//
//  SampleViewController.swift
//  DateApp
//
//  Created by ryan on 12/25/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit

class SampleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let close = UIBarButtonItem(title: "close", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SampleViewController.close(_:)))
        self.navigationItem.rightBarButtonItems = [close]
    }
    
    deinit {
        print(#function)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @objc func close(_ sender: AnyObject?) {
        dismiss(animated: true, completion: nil)
    }
}
