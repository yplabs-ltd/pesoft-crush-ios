//
//  NoProfileViewController.swift
//  DateApp
//
//  Created by ryan on 1/24/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import UIKit

class NoProfileViewController: UITableViewController {

    @IBOutlet weak var profileButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileButton.makeBorderForWidth(borderWidth: 1.0, borderColor: UIColor(rgba: "#f2503b"))
        profileButton.makeHCircleStyle()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
