//
//  MyDetailRankViewController.swift
//  DateApp
//
//  Created by Daehyun Lim on 2018. 5. 20..
//  Copyright © 2018년 iflet.com. All rights reserved.
//

import UIKit

class MyDetailRankViewController: UIViewController {
    
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
    
    var selectedUserModel: CardModel?
    var myRankModel: VoiceRankModel!
    var headerImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = myRankModel.createdAt?.stringForDate()
        let bundle = Bundle(for: type(of: self))
        
        self.navigationController?.navigationBar.topItem?.title = "";
        
        if let headerView = UINib(nibName: "VoiceLikedHeaderView", bundle: bundle).instantiate(withOwner: self, options: nil)[0] as? UIView {
            headerImage = UIImage(view: headerView)
        }
        
        
        // section header 가 스크롤시에 float 되는게 실어서 UITableViewStyleGrouped 설정,
        // tableview 가 UITableViewStyleGrouped 일때 아래위로 여백이 35px 생기는 문제 해결 (height 가 0이면 안된다함 -> FLT_MIN)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: CGFloat(Float.leastNormalMagnitude)))
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0,y: 0.0, width: 0.0, height: CGFloat(Float.leastNormalMagnitude)))
        tableView.sectionFooterHeight = 0.0
        tableView.sectionHeaderHeight = 0.0
        
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0)
        // refresh controll
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(NewsListViewController.pulldown(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        // segue
        favorHiddenUserPopupSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
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
                popup.dismiss(animated:true, completion: { () -> Void in
                    let responseViewModel = ApiResponseViewModelBuilder<ServerDefaultResponseModel>(successHandlerWithDefaultError: { [weak self] (response) -> Void in
                        _app.voiceLikeViewModel.getMyVoiceLikedList(voiceId: self!.myRankModel.id!)
                        self?.moveToDetailView(cardModel: m)
                        
                        }).viewModel
                    
                    let _ = _app.api.requestOpenHeartUser(userId: m.id!, voiceId: self.myRankModel.id!, fromType: "V",apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
                })
            }
            return (destination, style)
        })
        
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
            destination.heartUserId = self.myRankModel.id!
            let style = DSegueStyle.Show(animated: true)
            destination.title = "당신의 이야기를 좋아해요"
            let cardModels = _app.voiceLikeViewModel.voiceLikedModel.map { $0.convertCardModel() }
            destination.setCardModels(datas: cardModels)
            destination.dataType = nil
            
            return (destination, style)
        })
        
        // viewmodel
        
        _app.historiesViewModel.bind (view: self) { [weak self] (model, oldModel) -> () in
            self?.tableView.reloadData()
            self?.refreshControl.endRefreshing()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _app.voiceLikeViewModel.onShouldUpdate = { [weak self] in
            guard let wself = self else { return }
            wself.tableView.reloadData()
            wself.refreshControl.endRefreshing()
            
        }
        _app.voiceLikeViewModel.getMyVoiceLikedList(voiceId: myRankModel.id!)
        self.title = myRankModel.createdAt?.stringForDate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.title = nil
    }
    
    deinit {
        print(#function, "\(self)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func moveToDetailView(cardModel: CardModel?) {
        guard let m = cardModel else { return }
        if let vc = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "CardDetailViewController") as? CardDetailViewController {
            vc.isLikeMe = m.isLikeMe
            vc.isFavoredUser = m.isHidden != nil ? true : nil
            vc.targetUserId = m.id
            vc.fromType = "H"
            
            navigationController?.pushViewController(vc, animated: true)
        }
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

extension MyDetailRankViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyRankDetailCell") as! MyRankDetailCell
        cell.onSelectedItem = { [weak self] index in
            guard let wself = self else { return }
            let rankInfo = _app.voiceLikeViewModel.voiceLikedModel[index].convertCardModel()
            if rankInfo.isHidden == true {
                wself.selectedUserModel = rankInfo
                wself.favorHiddenUserPopupSegue.perform()
            }else {
                wself.moveToDetailView(cardModel: rankInfo)
            }
        }
        cell.parentController = self
        var cardCount: Int = 0
        switch indexPath.section {
        case 0: // 서로 호감이 있어요
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyDetailRankCell") as! MyDetailRankCell
            cell.userVoiceOneModel = myRankModel.convertToVoiceOneModel()
            return cell
        case 1: // 당신을 좋아해요
            cell.fromType = "H"
            cardCount = _app.voiceLikeViewModel.voiceLikedModel.count
            cell.voiceLikeModels = _app.voiceLikeViewModel.voiceLikedModel
            cell.moreSegue = historyMoreSegue
        default:
            break
        }
        cell.enableMoreButton(isEnable: cardCount > 6)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 1: // 지나간 인연
            if 0 <= _app.voiceLikeViewModel.voiceLikedModel.count {
                if let image = headerImage {
                    let header = NewsHeaderView(titleImage: image, itemCount: _app.voiceLikeViewModel.voiceLikedModel.count)
                    header.moreSegue = historyMoreSegue
                    return header
                }
            }
        default:
            break
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let height: CGFloat = 56.0
        switch section {
        case 1: // 지나간 인연
            if 0 <= _app.voiceLikeViewModel.voiceLikedModel.count {
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
        case 0:
            return 355
        case 1:
            isMoreCard = _app.voiceLikeViewModel.voiceLikedModel.count > maxCount
            cardCount = min(_app.voiceLikeViewModel.voiceLikedModel.count, maxCount)
        default:
            break
        }
        var operand: CGFloat = 3
        if getScreenSize().width == 320 {
            operand = 2
        }
        let lineNum = ceil(CGFloat(cardCount) / operand)
        var height = 164 * lineNum + (isMoreCard ? 30 : 0)
        if lineNum == 0 {
            height = 100
        }
        return height
    }
}

extension MyDetailRankViewController {
    @objc func pulldown(_ sender: AnyObject?) {
        _app.historiesViewModel.reload()
    }
}
