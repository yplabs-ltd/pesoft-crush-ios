//
//  NewsFullListViewController.swift
//  DateApp
//
//  Created by ryan on 1/19/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import UIKit

class NewsFullListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    enum DataType {
        case FavorMatch
        case LikeMe
        case ILike
        case FavorMe
        case IFavor
        case History
    }

    private var openHeartUserPopupSegue: DSegue!
    private var favorHiddenUserPopupSegue: DSegue!
    private var hiddenFavoredUserId: Int!
    private var hiddenFavoredUserName: String?
    private var isFavoredUser: Bool!
    private var fromTypeStr: String?
    var selectedUserModel: CardModel?
    private var cardsViewModel = DViewModel<[CardModel]>()
    var dataType: DataType?
    var heartUserId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /*
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 1.5
        let cellTotalUsableWidth = getScreenSize().width - 1.5 * 2.0
//        layout.itemSize = CGSize(cellTotalUsableWidth / 3, cellTotalUsableWidth / 3)
        layout.minimumLineSpacing = 2.0
        */
        
        _app.voiceLikeViewModel.onShouldUpdate = { [weak self] in
            guard let wself = self else { return }
            wself.cardsViewModel.model = _app.voiceLikeViewModel.voiceLikedModel.map { $0.convertCardModel() }
            wself.collectionView.reloadData()
        }
        
        cardsViewModel.bind (view: self) { [weak self] (model, oldModel) -> () in
            self?.collectionView.reloadData()
        }
        
        openHeartUserPopupSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "ConfirmPopupController") as! ConfirmPopupController
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: 172.0)
            })
            
            guard let m = self.selectedUserModel else {
                return (destination, style)
            }
            
            let userName = m.name ?? ""
            destination.line1 = (String(format: "%@님은 회원님의 목소리에\n하트를 보내셨어요!", userName), .Title)
            destination.line2 = ("지금 \(userName)님의 프로필을 보시겠어요?", .Title)
            destination.line3 = ("5버찌 필요", .Red)
            destination.submitHandler = { (popup: UIViewController) -> Void in
                popup.dismiss(animated: true, completion: { () -> Void in
                    let responseViewModel = ApiResponseViewModelBuilder<ServerDefaultResponseModel>(successHandlerWithDefaultError: { [weak self] (response) -> Void in
                        _app.voiceLikeViewModel.getMyVoiceLikedList(voiceId: self!.heartUserId)
                        self?.performSegue(withIdentifier: "TransitionToCardDetail", sender: nil)
                        
                        }).viewModel
                    
                    let _ = _app.api.requestOpenHeartUser(userId: m.id!, voiceId: self.heartUserId!, apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
                })
            }
            return (destination, style)
        })
        
        favorHiddenUserPopupSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "ConfirmPopupController") as! ConfirmPopupController
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: 172.0)
            })
            
            destination.line1 = (String(format: "%@님의 프로필을 보시겠어요?", self.hiddenFavoredUserName != nil ? self.hiddenFavoredUserName! : ""), .Title)
            destination.line2 = ("", .Title)
            destination.line3 = ("5버찌 필요", .Red)
            destination.submitHandler = { (popup: UIViewController) -> Void in
                popup.dismiss(animated: true, completion: { () -> Void in
                    let responseViewModel = ApiResponseViewModelBuilder<ServerDefaultResponseModel>(successHandlerWithDefaultError: { [weak self] (response) -> Void in
                        _app.historiesViewModel.reload()
                        self?.reloadApi()
                        self?.performSegue(withIdentifier: "TransitionToCardDetail", sender: nil)
                        _app.ga.trackingEventCategory(category:"news", action: "open_hidden_favor", label: "open_hidden_favor")
                        }).viewModel
                    
                    let _ = _app.api.openHiddenFavoredUser2(userId: self.hiddenFavoredUserId, reply: ReplyType.Accept, apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
                })
            }
            return (destination, style)
        })
        reloadApi()
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
        _app.ga.trackingViewName(viewName: .news_more)
    }
    
    func setCardModels(datas: [CardModel]) {
        cardsViewModel.model = datas
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CardDetailViewController {
            
            if dataType == .History {
                vc.fromType = "H" // (H)istory : 지나간 카드
            }
            
            // 선택한 셀의 id 전달 (target user id)
            if let collectionCell = sender as? NewsProfileCollectionCell, let targetUserId = collectionCell.cardModel?.id {
                vc.targetUserId = targetUserId
                vc.fromType = collectionCell.fromType
            }else {
                vc.targetUserId = hiddenFavoredUserId
            }
            
            vc.isFavoredUser = isFavoredUser
        }
    }
}


extension NewsFullListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let collectionCell = sender as? NewsProfileCollectionCell, let isHidden = collectionCell.cardModel?.isHidden {
            isFavoredUser = collectionCell.cardModel?.isHidden != nil ? true : nil
            
            if collectionCell.cardModel?.isFuture == false {
                Toast.showToast(message: "프로필 열람 기한이 지났습니다.", duration: 0.1)
                return false
            }
            
            if isHidden {
                if let userId = collectionCell.cardModel!.id {
                    hiddenFavoredUserId = userId
                    hiddenFavoredUserName = collectionCell.cardModel!.name
                    
                    if dataType == nil {
                        selectedUserModel = collectionCell.cardModel
                        openHeartUserPopupSegue.perform()
                    }else {
                        favorHiddenUserPopupSegue.perform()
                    }
                }
                
                return false
            }
        }
        
        return true
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardsViewModel.model?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAtIndex section: Int) -> UIEdgeInsets{
        let margin = (getScreenSize().width - 94 * 3.0) / 4
        let insetEdge = UIEdgeInsetsMake(30, margin, 0, margin)
        return insetEdge
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! NewsProfileCollectionCell
        cell.cardModel = cardsViewModel.model?[indexPath.item]
        cell.enableBlueProfileImageView(isEnable: false)
        if let isHiddenBlurImage = cell.cardModel?.isHidden {
            cell.enableBlueProfileImageView(isEnable: isHiddenBlurImage)
        }
        cell.dDayLabel.isHidden = !(cell.cardModel?.isFuture ?? false)
        return cell
    }
}

extension NewsFullListViewController: ApiReloadable {
    func reloadApi() {
        
        let responseViewModel = ApiResponseViewModelBuilder<[CardModel]>(successHandlerWithDefaultError: { [weak self] (cards) -> Void in
            self?.cardsViewModel.model = cards
        }).viewModel
        if let dataType = dataType {
            switch dataType {
            case .FavorMatch:
                _app.api.cardListFavorMatch(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
                case .LikeMe:
                    _app.api.cardListLikeMe(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
                case .ILike:
                    _app.api.cardListILike(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
                case .FavorMe:
                    _app.api.cardListFavorMe(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
                case .IFavor:
                    _app.api.cardListIFavor(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
                case .History:
                    _app.api.cardListHistory(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
            }
        }
    }
}

