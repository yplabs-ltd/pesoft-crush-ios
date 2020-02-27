//
//  StroyViewController.swift
//  DateApp
//
//  Created by Yang Hyeon Gyu on 2017. 3. 5..
//  Copyright © 2017년 iflet.com. All rights reserved.
//

import UIKit

final class StoryViewController : UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    
    private var storyMainSegue: DSegue!
    private var profileRequireSegue: DSegue!
    private var confirmWaitingSegue: DSegue!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "STORY"
        
        storyMainSegue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "StoryViewMainController")
            let style = DSegueStyle.Embed(containerView: self?.containerView)
            
            destination.becomeFirstResponder()
            
            return (destination, style)
        })
        
        // 프로필 입력이 필요함
        profileRequireSegue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "FillProfileInformationViewController")
            let style = DSegueStyle.Embed(containerView: self?.containerView)
            return (destination, style)
        })
        
        // 인증 기다리는 중
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
}

extension StoryViewController {
    
    func choiceEmbededSegue() {
        if _app.sessionViewModel.model?.status == .Normal {
            storyMainSegue.perform()
        } else if _app.sessionViewModel.model?.status == .Waiting {
            confirmWaitingSegue.perform()
        } else {
            profileRequireSegue.perform()
        }
    }
}

