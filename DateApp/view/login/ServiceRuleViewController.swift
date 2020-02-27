//
//  ServiceRuleViewController.swift
//  DateApp
//
//  Created by ryan on 1/24/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import UIKit

class ServiceRuleViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    var titleString: String? {
        didSet {
            title = "서비스이용약관"
        }
    }
    
    var linkUrl: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // webview
        let url = URL (string: linkUrl)
        let requestObj = URLRequest(url: url!)
        webView.loadRequest(requestObj)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
