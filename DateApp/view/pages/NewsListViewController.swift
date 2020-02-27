//
//  NewsListViewController.swift
//  DateApp
//
//  Created by ryan on 12/12/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit

class NewsListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var refreshControl: UIRefreshControl!
    private var favorMatchMoreSegue: DSegue!
    private var likeMeMoreSegue: DSegue!
    private var ilikeMoreSegue: DSegue!
    private var favorMeMoreSegue: DSegue!
    private var iFavorMoreSegue: DSegue!
    private var historyMoreSegue: DSegue!
    private var favorHiddenUserPopupSegue: DSegue!
    private var hiddenFavoredUserId: Int!
    private var hiddenFavoredUserName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // section header 가 스크롤시에 float 되는게 실어서 UITableViewStyleGrouped 설정,
        // tableview 가 UITableViewStyleGrouped 일때 아래위로 여백이 35px 생기는 문제 해결 (height 가 0이면 안된다함 -> FLT_MIN)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: CGFloat(Float.leastNormalMagnitude)))
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: CGFloat(Float.leastNormalMagnitude)))
        tableView.sectionFooterHeight = 0.0
        tableView.sectionHeaderHeight = 0.0
        
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0)
        // refresh controll
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(NewsListViewController.pulldown(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        // segue
        favorMatchMoreSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "NewsFullListViewController") as! NewsFullListViewController
            let style = DSegueStyle.Show(animated: true)
            destination.title = "서로 호감이 있어요"
            destination.dataType = .FavorMatch
            return (destination, style)
        })
        
        likeMeMoreSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "NewsFullListViewController") as! NewsFullListViewController
            let style = DSegueStyle.Show(animated: true)
            destination.title = "당신을 좋아해요"
            destination.dataType = .LikeMe
            return (destination, style)
        })
        ilikeMoreSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "NewsFullListViewController") as! NewsFullListViewController
            let style = DSegueStyle.Show(animated: true)
            destination.title = "당신이 좋아해요"
            destination.dataType = .ILike
            return (destination, style)
        })
        favorMeMoreSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "NewsFullListViewController") as! NewsFullListViewController
            let style = DSegueStyle.Show(animated: true)
            destination.title = "당신에게 호감있어요"
            destination.dataType = .FavorMe
            return (destination, style)
        })
        iFavorMoreSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "NewsFullListViewController") as! NewsFullListViewController
            let style = DSegueStyle.Show(animated: true)
            destination.title = "당신이 호감이 있어요"
            destination.dataType = .IFavor
            return (destination, style)
        })
        historyMoreSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "NewsFullListViewController") as! NewsFullListViewController
            let style = DSegueStyle.Show(animated: true)
            destination.title = "지나간 인연"
            destination.dataType = .History
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
                popup.dismiss(animated:true, completion: { () -> Void in
                    let responseViewModel = ApiResponseViewModelBuilder<ServerDefaultResponseModel>(successHandlerWithDefaultError: { [weak self] (response) -> Void in
                        _app.historiesViewModel.reload()
                        self?.performSegue(withIdentifier: "TransitionToCardDetail", sender: nil)
                        _app.ga.trackingEventCategory(category:"news", action: "open_hidden_favor", label: "open_hidden_favor")
                        }).viewModel
                    
                    let _ = _app.api.openHiddenFavoredUser2(userId: self.hiddenFavoredUserId, reply: ReplyType.Accept, apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
                })
            }
            return (destination, style)
        })
        
        // viewmodel
        
        _app.historiesViewModel.bind (view: self) { [weak self] (model, oldModel) -> () in
            self?.tableView.reloadData()
            self?.refreshControl.endRefreshing()
        }
    }
    
    deinit {
        print(#function, "\(self)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _app.historiesViewModel.reload()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CardDetailViewController {
            
            // 선택한 셀의 id 전달 (target user id)
            if let collectionCell = sender as? NewsProfileCollectionCell, let targetUserId = collectionCell.cardModel?.id {
                vc.isLikeMe = collectionCell.cardModel?.isLikeMe
                vc.isFavoredUser = collectionCell.cardModel?.isHidden != nil ? true : nil
                vc.targetUserId = targetUserId
                vc.fromType = collectionCell.fromType
            }else {
                vc.isFavoredUser = true
                vc.targetUserId = hiddenFavoredUserId
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let collectionCell = sender as? NewsProfileCollectionCell, let isHidden = collectionCell.cardModel?.isHidden {
            if isHidden {
                if let userId = collectionCell.cardModel!.id {
                    hiddenFavoredUserId = userId
                    hiddenFavoredUserName = collectionCell.cardModel!.name
                    favorHiddenUserPopupSegue.perform()
                }

                return false
            }
        }
        
        return true
    }
}

extension NewsListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return _app.historiesViewModel.sectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: // 서로 호감이 있어요
            return 1
        case 1: // 당신을 좋아해요
            return 1
        case 2: // 당신이 좋아해요
            return 1
        case 3: // 당신에게 호감이 있어요
            return 1
        case 4: // 당신이 호감을 표현했어요
            return 1
        case 5: // 지나간 인연
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell") as! NewsTableCell
        cell.parentController = self
        var cardCount: Int = 0
        switch indexPath.section {
        case 0: // 서로 호감이 있어요
            if let cards = _app.historiesViewModel.model?.favorMatchCards {
                cardCount = cards.count
                cell.cardModels = cards
                cell.moreSegue = favorMatchMoreSegue
            }
        case 1: // 당신을 좋아해요
            if let cards = _app.historiesViewModel.model?.likeMeCards {
                cardCount = cards.count
                cell.cardModels = cards
                cell.moreSegue = likeMeMoreSegue
            }
        case 2: // 당신이 좋아해요
            if let cards = _app.historiesViewModel.model?.iLikeCards {
                cardCount = cards.count
                cell.cardModels = cards
                cell.moreSegue = ilikeMoreSegue
            }
        case 3: // 당신에게 호감이있어요
            /*
            if let cards = _app.historiesViewModel.model?.favorMeCards {
                cell.cardModels = cards
            }
            */
            if let cards = _app.historiesViewModel.model?.favorMeHiddenCards {
                cardCount = cards.count
                cell.cardModels = cards
                cell.moreSegue = favorMeMoreSegue
            }
        case 4: // 당신이 호감을 표현했어요
            if let cards = _app.historiesViewModel.model?.ifavorCards {
                cardCount = cards.count
                cell.cardModels = cards
                cell.moreSegue = iFavorMoreSegue
            }
        case 5: // 지나간 인연
            cell.fromType = "H"
            if let cards = _app.historiesViewModel.model?.historyCards {
                cardCount = cards.count
                cell.cardModels = cards
                cell.moreSegue = historyMoreSegue
            }
        default:
            break
        }
        cell.enableMoreButton(isEnable: cardCount > 6)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0: // 서로 호감이 있어요
            if 0 < _app.historiesViewModel.favorMatchCardsCount {
                let header = NewsHeaderView(titleImage: UIImage(assetIdentifier: UIImage.AssetIdentifier.favorMatch), itemCount: _app.historiesViewModel.favorMatchCardsCount)
                header.moreSegue = favorMatchMoreSegue
                return header
            }
        case 1: // 당신을 좋아해요
            if 0 < _app.historiesViewModel.likeMeCardsCount {
                let header = NewsHeaderView(titleImage: UIImage(assetIdentifier: UIImage.AssetIdentifier.LikesMe), itemCount: _app.historiesViewModel.likeMeCardsCount)
                header.moreSegue = likeMeMoreSegue
                return header
            }
        case 2: // 당신이 좋아해요
            if 0 < _app.historiesViewModel.iLikeCardsCount {
                let header = NewsHeaderView(titleImage: UIImage(assetIdentifier: UIImage.AssetIdentifier.ILike), itemCount: _app.historiesViewModel.iLikeCardsCount)
                header.moreSegue = ilikeMoreSegue
                return header
            }
        case 3: // 당신에게 호감이있어요
            /*
            if 0 < _app.historiesViewModel.favorMeCardsCount {
                let header = NewsHeaderView(titleImage: UIImage(assetIdentifier: UIImage.AssetIdentifier.FavorMe), itemCount: _app.historiesViewModel.favorMeCardsCount)
                header.moreSegue = favorMeMoreSegue
                return header
            }
            */
            if 0 < _app.historiesViewModel.favorMeHiddenCardsCount {
                let header = NewsHeaderView(titleImage: UIImage(assetIdentifier: UIImage.AssetIdentifier.FavorMe), itemCount: _app.historiesViewModel.favorMeHiddenCardsCount)
                header.moreSegue = favorMeMoreSegue
                return header
            }
        case 4: // 당신이 호감이있어요
            if 0 < _app.historiesViewModel.ifavorCardsCount {
                let header = NewsHeaderView(titleImage: UIImage(assetIdentifier: UIImage.AssetIdentifier.IFavor), itemCount: _app.historiesViewModel.ifavorCardsCount)
                header.moreSegue = iFavorMoreSegue
                return header
            }
        case 5: // 지나간 인연
            if 0 < _app.historiesViewModel.historyCardsCount {
                let header = NewsHeaderView(titleImage: UIImage(assetIdentifier: UIImage.AssetIdentifier.PastPopGirl), itemCount: _app.historiesViewModel.historyCardsCount)
                header.moreSegue = historyMoreSegue
                return header
            }
        default:
            break
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let height: CGFloat = 56.0
        switch section {
        case 0: // 서로 호감이 있어요
            if 0 < _app.historiesViewModel.favorMatchCardsCount {
                return height
            }
        case 1: // 당신을 좋아해요
            if 0 < _app.historiesViewModel.likeMeCardsCount {
                return height
            }
        case 2: // 당신이 좋아해요
            if 0 < _app.historiesViewModel.iLikeCardsCount {
                return height
            }
        case 3: // 당신에게 호감이 있어요
            if 0 < _app.historiesViewModel.favorMeHiddenCardsCount {
                return height
            }
        case 4: // 당신이 호감을 표현했어요
            if 0 < _app.historiesViewModel.ifavorCardsCount {
                return height
            }
        case 5: // 지나간 인연
            if 0 < _app.historiesViewModel.historyCardsCount {
                return height
            }
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let maxCount = 6    // 6개 이상은 더보기로 확인하자
        var cardCount = 0
        var isMoreCard: Bool = false
        switch indexPath.section {
        case 0: // 서로 호감이 있어요
            isMoreCard = _app.historiesViewModel.favorMatchCardsCount > maxCount
            cardCount = min(_app.historiesViewModel.favorMatchCardsCount, maxCount)
        case 1: // 당신을 좋아해요
            isMoreCard = _app.historiesViewModel.likeMeCardsCount > maxCount
            cardCount = min(_app.historiesViewModel.likeMeCardsCount, maxCount)
        case 2: // 당신이 좋아해요
            isMoreCard = _app.historiesViewModel.iLikeCardsCount > maxCount
            cardCount = min(_app.historiesViewModel.iLikeCardsCount, maxCount)
        case 3: // 당신에게 호감이 있어요
            isMoreCard = _app.historiesViewModel.favorMeHiddenCardsCount > maxCount
            cardCount = min(_app.historiesViewModel.favorMeHiddenCardsCount, maxCount)
        case 4: // 당신이 호감을 표현했어요
            isMoreCard = _app.historiesViewModel.ifavorCardsCount > maxCount
            cardCount = min(_app.historiesViewModel.ifavorCardsCount, maxCount)
        case 5: // 지나간 인연
            isMoreCard = _app.historiesViewModel.historyCardsCount > maxCount
            cardCount = min(_app.historiesViewModel.historyCardsCount, maxCount)
        default:
            break
        }
        var operand: CGFloat = 3
        if getScreenSize().width == 320 {
            operand = 2
        }
        let lineNum = ceil(CGFloat(cardCount) / operand)
        var height = 164 * lineNum + 30 + (isMoreCard ? 30 : 0)
        if lineNum == 0 {
            height = 0
        }
        return height
    }
}

extension NewsListViewController {
    @objc func pulldown(_ sender: AnyObject?) {
        _app.historiesViewModel.reload()
    }
}
