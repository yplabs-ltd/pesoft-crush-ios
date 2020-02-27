//
//  NoticeViewController.swift
//  DateApp
//
//  Created by ryan on 1/16/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import UIKit

class NoticeViewController: UIViewController {

    let viewModel = FacebookLoginViewModel()
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.isTranslucent = false
        self.navigationController!.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.setBottomNomaringBorderColor(color: UIColor(rgba: "#e6e6e6"), height: 1)
        
        title = "공지"
        
        // webview
        guard let url = URL(string: _app.config.noticeUrl) else { return }
        let requestObj = URLRequest(url: url)
        webView.loadRequest(requestObj)
    }
    
    deinit {
        print(#function, "\(self)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _app.ga.trackingViewName(viewName: .notice)
    }
    
    @IBAction func onClickFacebookBanner() {
        requestPointBanner()
        openFacebookPage()
    }
    
    func openFacebookPage() {
        let scheme = "fb://profile/802382866563146"
        
        if let url = URL(string: scheme), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }else if let u = URL(string:"https://m.facebook.com/ablesuquare/?_rdr") {
            UIApplication.shared.open(u, options: [:], completionHandler: nil)
        }
    }
    
    func requestPointBanner() {
        let responseViewModel = ApiResponseViewModelBuilder<ServerDefaultResponseModel>(successHandlerWithDefaultError: { (responseModel) -> Void in
            
        }).viewModel
        let _ = _app.api.clickFacebookBanner(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
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
