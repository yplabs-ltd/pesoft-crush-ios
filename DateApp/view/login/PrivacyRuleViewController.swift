//
//  PrivacyRuleViewController.swift
//  DateApp
//
//  Created by ryan on 1/24/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import UIKit

class PrivacyRuleViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "개인정보이용방침"
        
        // webview
        guard let url = URL (string: _app.config.privacyRuleUrl) else { return }
        let requestObj = URLRequest(url: url)
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
