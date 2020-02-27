//
//  TopContainer.swift
//  DateApp
//
//  Created by ryan on 12/12/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit

class TopContainer: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        makeNavigationBarDefaultStyle()
        self.navigationBar.setBottomBorderColor(color: UIColor(rgba: "#e6e6e6"), height: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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

extension TopContainer {
    
    func presentNetworkFailInfo(sender: AnyObject) {
        let msg = "네트워크 상태가 좋지 않습니다. 잠시 후 다시 시도해 주세요."
        Toast.showToast(message: msg)
    }
}
