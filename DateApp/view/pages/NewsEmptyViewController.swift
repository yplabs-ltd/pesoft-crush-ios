//
//  NewsEmptyTableViewController.swift
//  DateApp
//
//  Created by ryan on 2/9/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import UIKit

class NewsEmptyViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        _app.historiesViewModel.bind (view: self) { [weak self] (model, oldModel) -> () in
            guard let parent = self?.parent as? NewsViewController else {
                return
            }
            if 0 < _app.historiesViewModel.totalCardsCount {
                parent.choiceEmbededSegue()
            }
        }
    }
    
    deinit {
        print(#function, "\(self)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.height
    }
}
