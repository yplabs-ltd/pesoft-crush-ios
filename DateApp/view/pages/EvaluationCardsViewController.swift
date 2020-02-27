//
//  EvaluationCardsViewController.swift
//  DateApp
//
//  Created by ryan on 12/12/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit

final class EvaluationCardsViewController: UITableViewController {

    @IBOutlet weak var profileImageButtonContainer: UIView!
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var dotdotdotButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    @IBAction func like(sender: AnyObject) {
        let responseViewModel = ApiResponseViewModelBuilder<ServerDefaultResponseModel>(successHandlerWithDefaultError: { (responseModel) -> Void in
            if responseModel.code == "CashAdded" {
                if let t = responseModel.title, let d = responseModel.description {
                    alert(title: "", message: "매력 카드 평가를 통해 1버찌를 얻었습니다.")
                }
            }
            _app.evaluationCardsViewModel.pass()
            _app.historiesViewModel.dirtyFlag = true
        }).viewModel
        if let targetUserId = cardModel?.id {
            _app.api.cardEvaluate(targetUserId: targetUserId, value: .Good, apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
        }
        
        _app.ga.trackingEventCategory(category:"evaluate", action: "evaluate", label: "good")
    }
    
    @IBAction func notBad(sender: AnyObject) {
        let responseViewModel = ApiResponseViewModelBuilder<ServerDefaultResponseModel>(successHandlerWithDefaultError: { (responseModel) -> Void in
            if responseModel.code == "CashAdded" {
                if let t = responseModel.title, let d = responseModel.description {
                    alert(title: "", message: "매력 카드 평가를 통해 1버찌를 얻었습니다.")
                }
            }
            _app.evaluationCardsViewModel.pass()
            _app.historiesViewModel.dirtyFlag = true
        }).viewModel
        if let targetUserId = cardModel?.id {
            _app.api.cardEvaluate(targetUserId: targetUserId, value: .NotBad, apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
        }
        
        _app.ga.trackingEventCategory(category:"evaluate", action: "evaluate", label: "good")
    }
    
    @IBAction func dislike(sender: AnyObject) {
        let responseViewModel = ApiResponseViewModelBuilder<ServerDefaultResponseModel>(successHandlerWithDefaultError: {  (responseModel) -> Void in
            if responseModel.code == "CashAdded" {
                if let t = responseModel.title, let d = responseModel.description {
                    alert(title: "", message: "매력 카드 평가를 통해 1버찌를 얻었습니다.")
                }
            }
            _app.evaluationCardsViewModel.pass()
        }).viewModel
        if let targetUserId = cardModel?.id {
            let _ = _app.api.cardEvaluate(targetUserId: targetUserId, value: .Bad, apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
        }
        
        _app.ga.trackingEventCategory(category:"evaluate", action: "evaluate", label: "bad")
    }
    
    let profileDefaultImage = UIImage(assetIdentifier: UIImage.AssetIdentifier.BlankImage)
    var cardModel: ProfileModel? {
        didSet {
            guard let cardModel = cardModel else {
                return
            }
            
            // 이미지 동적 다운로드
            profileImageButton.setImage(profileDefaultImage, for: UIControlState.normal)
            if let url = cardModel.mainImageUrl, let profileImageButton = profileImageButton {
                let loadingVM = LoadingViewModelBuilder(superview: profileImageButton).viewModel
                let downloadViewModel = ApiResponseViewModelBuilder<Data>(successHandler: { (data) -> Void in
                    profileImageButton.setImage(UIImage(data: data), for: UIControlState.normal)
                }).viewModel
                let _ = _app.api.download(url: url, apiResponseViewModel: downloadViewModel, loadingViewModel: loadingVM)
            }
            
            if let targetUserId = cardModel.id {
                profileImageButton.tag = targetUserId
                dotdotdotButton.tag = targetUserId
            }
            titleLabel.text = cardModel.name
            subTitleLabel.text = cardModel.summary
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 프로필 사진 원형으로 조정, border 추가
        profileImageButtonContainer.layer.cornerRadius = 260 / 2
        profileImageButtonContainer.layer.masksToBounds = true
        profileImageButtonContainer.layer.borderColor = UIColor(rgba: "#e3e1e0").cgColor
        profileImageButtonContainer.layer.borderWidth = 1
        
        profileImageButton.layer.cornerRadius = 246 / 2
        profileImageButton.layer.masksToBounds = true
        profileImageButton.setImage(profileDefaultImage, for: UIControlState.normal)
        
        // ... 버튼 라운드 처리와 외곽선
        dotdotdotButton.layer.cornerRadius = 50 / 2
        dotdotdotButton.layer.masksToBounds = true
        dotdotdotButton.layer.borderColor = UIColor(rgba: "#e3e1e0").cgColor
        dotdotdotButton.layer.borderWidth = 1
        
        // viewmodel
        
        _app.evaluationCardsViewModel.bindThenFire (view: self) { [weak self] (model, oldModel) -> () in
            guard let evaluationCardModel = model else {
                self?.cardModel = nil
                
                // wait 페이지 표시해야함
                if let parent = self?.parent as? EvaluationViewController {
                    parent.choiceEmbededSegue()
                }
                return
            }
            self?.cardModel = evaluationCardModel
        }
    }
    
    deinit {
        print(#function, "\(self)")
    }
    
    private func reloadCardModel(evaluationCardModel: EvaluationCardsModel) {
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if tableView.tableHeaderView == nil {
            let header: UIView = UIView()
            header.setNeedsUpdateConstraints()
            header.updateConstraintsIfNeeded()
            header.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: (self.tableView.frame.size.height - self.tableView.contentSize.height ) / 2)
            var newFrame = header.frame
            header.setNeedsLayout()
            header.layoutIfNeeded()
            _ = header.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
            newFrame.size.height = (self.tableView.frame.size.height - self.tableView.contentSize.height ) / 2 - 15
            header.frame = newFrame
            self.tableView.tableHeaderView = header
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CardDetailViewController {
            
            // 선택한 셀의 id 전달 (target user id)
            if let sender = sender as? UIView , 0 <= sender.tag {
                vc.targetUserId = sender.tag
            }
        }
    }

}

