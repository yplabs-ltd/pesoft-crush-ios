//
//  EvaluationViewController.swift
//  DateApp
//
//  Created by ryan on 12/20/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit

final class EvaluationViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!

    private var evaluationCardSegue: DSegue!
    private var evaluationWaitSegue: DSegue!    // 평가대기중입니다
    private var profileRequireSegue: DSegue!    // 프로필 입력해야 한다는 안내 페이지
    private var confirmWaitingSegue: DSegue!    // 회원가입 기다리는 중
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // segue
        
        evaluationCardSegue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "EvaluationCardsViewController")
            let style = DSegueStyle.Embed(containerView: self?.containerView)
            return (destination, style)
        })
        
        // 평가할 상대가 더이상 없음
        evaluationWaitSegue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "EvaluationWaitTableViewController")
            let style = DSegueStyle.Embed(containerView: self?.containerView)
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
    
    deinit {
        print(#function, "\(self)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension EvaluationViewController {
    
    func choiceEmbededSegue() {
        if _app.sessionViewModel.model?.status == .Normal {
            if _app.evaluationCardsViewModel.model != nil {
                evaluationCardSegue.perform()
                
                // waitEvaluate = false 로 세팅 필요 (삭제)
                if _app.oneSignalTagsViewModel.model?.waitEvaluate == true {
                    _app.oneSignal.offTagWaitEvaluate()
                    _app.oneSignalTagsViewModel.model?.waitEvaluate = nil
                }
            } else {
                evaluationWaitSegue.perform()
                
                // waitEvaluate = true 로 세팅 필요
                if _app.oneSignalTagsViewModel.model?.waitEvaluate != true {
                    _app.oneSignal.onTagWaitEvaluate()
                    _app.oneSignalTagsViewModel.model?.waitEvaluate = true
                }
            }
        } else if _app.sessionViewModel.model?.status == .Waiting {
            confirmWaitingSegue.perform()
        } else {
            profileRequireSegue.perform()
        }
    }
}

