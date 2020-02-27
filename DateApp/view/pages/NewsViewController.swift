//
//  NewsContainerViewController.swift
//  DateApp
//
//  Created by ryan on 12/20/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit

final class NewsViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    
    private var newsListSegue: DSegue!
    private var newsEmptySegue: DSegue!
    private var profileRequireSegue: DSegue!
    private var confirmWaitingSegue: DSegue!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "소식"
        
        // segue
        
        newsEmptySegue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "NewsEmptyViewController")
            let style = DSegueStyle.Embed(containerView: self?.containerView)
            
            destination.becomeFirstResponder()
            
            return (destination, style)
        })
        
        newsListSegue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "NewsListViewController")
            let style = DSegueStyle.Embed(containerView: self?.containerView)
            return (destination, style)
        })
        
        profileRequireSegue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "FillProfileInformationViewController")
            let style = DSegueStyle.Embed(containerView: self?.containerView)
            return (destination, style)
        })
        
        confirmWaitingSegue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "ConfirmWaitingViewController")
            let style = DSegueStyle.Embed(containerView: self?.containerView)
            return (destination, style)
        })
        
        _app.sessionViewModel.bind (view: self) { [weak self] (model, oldModel) -> () in
            guard let model = model else {
                return
            }
            if model.status != oldModel?.status {
                self?.choiceEmbededSegue()
            }
        }
        
        choiceEmbededSegue()
    }
    
    deinit {
        print(#function, "\(self)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension NewsViewController {
    
    func choiceEmbededSegue() {
        if _app.sessionViewModel.model?.status == .Normal {
            if 0 < _app.historiesViewModel.totalCardsCount {
                newsListSegue.perform()
            } else {
                newsEmptySegue.perform()
            }
        } else if _app.sessionViewModel.model?.status == .Waiting {
            confirmWaitingSegue.perform()
        } else {
            profileRequireSegue.perform()
        }
    }
}
