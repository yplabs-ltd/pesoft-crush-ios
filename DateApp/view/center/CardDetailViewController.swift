//
//  CardDetailViewController.swift
//  DateApp
//
//  Created by ryan on 1/11/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import UIKit

final class CardDetailViewController: UIViewController, TargetUserIdRequired {
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var yesNoButtonContainerView: UIView!
    
    var likeCheckedAt: Date?
    var isLikeButtonPressed: Bool! = false
    var isLikeMe: Bool? = false
    var isFromChatView: Bool! = false
    
    // 좋아요 버튼 클릭
    @IBAction func like(sender: AnyObject) {
        switch detailType {
        case .Like:
            // 좋아요
            likeMessagePopupSegue.perform()
            _app.ga.trackingEventCategory(category:"user_detail", action: "like", label: "like")
        case .Waiting:
            break
        case .YesNo:
            break
        case .IAccepted, .AcceptedMe:
            // 채팅 리스트로 이동
            talkSegue.perform()
            _app.ga.trackingEventCategory(category:"user_detail", action: "like", label: "accept")
            break
        case .RejectedMe, .IRejected:
            // 다시 한번 좋아요
            likeMessagePopupSegue.perform()
            _app.ga.trackingEventCategory(category:"user_detail", action: "like", label: "reject")
            break
        case .Favored:
            isLikeButtonPressed = true
            //talkSegue.perform()
            likeMessagePopupSegue.perform()
            break
        case .YetFavored:
            isLikeButtonPressed = true
            //replyFavor()
            likeMessagePopupSegue.perform()
            break
        case .LikeCheck:
            print("LikeCheck Push")
            break;
        case .Unknown:
            break
        case .Nothing:
            break
        default:()
        }
    }
    
    // 호감에 대한 응답
    func replyFavor() {
        guard let targetUserId = _app.cardDetailViewModel.model?.profileModel?.id else {
            return
        }
        let responseViewModel = ApiResponseViewModelBuilder<ServerDefaultResponseModel>(successHandlerWithDefaultError: { [weak self] (response) -> Void in
            self?.reloadApi()
            _app.ga.trackingEventCategory(category: "user_detail", action: "favor_in_detail", label: "favor_in_detail")
            }).viewModel
        
        let _ = _app.api.favorReply(userId: targetUserId, reply: ReplyType.Accept, apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
    }
    
    // 별로
    @IBAction func no(sender: AnyObject) {
        
        guard let targetUserId = _app.cardDetailViewModel.model?.profileModel?.id else {
            return
        }
        let responseViewModel = ApiResponseViewModelBuilder<ServerDefaultResponseModel>(successHandlerWithDefaultError: { [weak self] (response) -> Void in
            self?.reloadApi()
        }).viewModel
        
        confirm(title: "별로", message: "상대방의 좋아요를 거절합니다") { (action) -> Void in
            let _ = _app.api.cardReply(userId: targetUserId, reply: ReplyType.Reject, apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
        }
    }
    
    // 좋아요 응답하기
    @IBAction func yes(sender: AnyObject) {
        
        guard let targetUserId = _app.cardDetailViewModel.model?.profileModel?.id else {
            return
        }
        let responseViewModel = ApiResponseViewModelBuilder<ServerDefaultResponseModel>(successHandlerWithDefaultError: { [weak self] (response) -> Void in
                self?.reloadApi()
        }).viewModel
    
        confirm(title: "좋아요 응답하기", message: "상대방의 좋아요에 응답합니다") { (action) -> Void in
            let _ = _app.api.cardReply(userId: targetUserId, reply: ReplyType.Accept, apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
        }
    }
    
    private enum DetailType {
        case LikeCheck
        case Like
        case Waiting
        case YesNo
        case IRejected
        case IAccepted
        case RejectedMe
        case AcceptedMe
        case Unknown
        case Favored
        case YetFavored
        case Nothing
        case LikeChecked
    }
    
    private var detailType = DetailType.Unknown {
        didSet {
            
            likeButton.setImage(nil, for: UIControlState.normal)
            switch detailType {
            case .Like:
                yesNoButtonContainerView.isHidden = true
                likeButton.isHidden = false
                likeButton.isEnabled = true
                likeButton.backgroundColor = UIColor(rgba: "#f2503b")
                if _app.sessionViewModel.model?.gender == "F" {
                    likeButton.setTitle("좋아요 (무료)", for: UIControlState.normal)
                }else {
                    likeButton.setTitle("좋아요", for: UIControlState.normal)
                }
                
                likeButton.setImage(UIImage(named: "detail_ico_bird"), for: UIControlState.normal)
            case .Waiting:
                yesNoButtonContainerView.isHidden = true
                likeButton.isHidden = false
                likeButton.isEnabled = false
                likeButton.backgroundColor = UIColor(rgba: "#726763")
                likeButton.setTitle("상대방의 응답을 기다리고 있습니다", for: UIControlState.normal)
            case .LikeCheck:
                yesNoButtonContainerView.isHidden = true
                likeButton.isHidden = false
                likeButton.isEnabled = false
                likeButton.backgroundColor = UIColor(rgba: "#f2503b")
                likeButton.setTitle("좋아요 메시지를 확인했습니다.", for: UIControlState.normal)
            case .AcceptedMe:
                yesNoButtonContainerView.isHidden = true
                likeButton.isHidden = false
                likeButton.isEnabled = true
                likeButton.backgroundColor = UIColor(rgba: "#f2503b")
                likeButton.setTitle("상대방이 응답을 하였습니다. 대화신청을 해보세요.", for: UIControlState.normal)
            case .RejectedMe:
                yesNoButtonContainerView.isHidden = true
                likeButton.isHidden = false
                likeButton.isEnabled = true
                likeButton.backgroundColor = UIColor(rgba: "#f2503b")
                likeButton.setTitle("이전 좋아요를 거절하였습니다. 다시 좋아요", for: UIControlState.normal)
            case .IAccepted:
                yesNoButtonContainerView.isHidden = true
                likeButton.isHidden = false
                likeButton.isEnabled = true
                likeButton.backgroundColor = UIColor(rgba: "#f2503b")
                likeButton.setTitle("상대방에게 응답을 하였습니다. 대화신청을 해보세요.", for: UIControlState.normal)
                break
            case .IRejected:
                yesNoButtonContainerView.isHidden = true
                likeButton.isHidden = false
                likeButton.isEnabled = true
                likeButton.backgroundColor = UIColor(rgba: "#f2503b")
                likeButton.setTitle("좋아요", for: UIControlState.normal)
                break
            case .YesNo:
                yesNoButtonContainerView.isHidden = false
                likeButton.isHidden = true
                break
            case .Favored:
                yesNoButtonContainerView.isHidden = true
                likeButton.isHidden = false
                likeButton.isEnabled = true
                likeButton.backgroundColor = UIColor(rgba: "#f2503b")
                likeButton.setTitle("좋아요", for: UIControlState.normal)
                break
            case .YetFavored:
                yesNoButtonContainerView.isHidden = true
                likeButton.isHidden = false
                likeButton.isEnabled = true
                likeButton.backgroundColor = UIColor(rgba: "#f2503b")
                likeButton.setTitle("좋아요", for: UIControlState.normal)
                likeButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -10, bottom: 0, right: 0)
                likeButton.setImage(UIImage(named: "detail_ico_like"), for: UIControlState.normal)
                break
            case .Unknown:
                yesNoButtonContainerView.isHidden = true
                likeButton.isHidden = false
                likeButton.isEnabled = false
                likeButton.backgroundColor = UIColor(rgba: "#726763")
                likeButton.setTitle("...", for: UIControlState.normal)
            case .Nothing:
                yesNoButtonContainerView.isHidden = true
                likeButton.isHidden = true
            case .LikeChecked:
                yesNoButtonContainerView.isHidden = true
                likeButton.isHidden = false
                likeButton.isEnabled = false
                likeButton.backgroundColor = UIColor(rgba: "#726763")
                if let s = likeCheckedAt {
                    likeButton.setTitle("상대방이 \(s.timeAgoForComment())에 확인하였습니다.", for: UIControlState.normal)
                }
            }
        }
    }

    var fromType: String? // 어디서 열었는가? ((H)istory : 지나간 카드, (T)oday : 오늘의 카드 (default))
    var targetUserId: Int!
    
    var likeMessagePopupSegue: DSegue!
    var talkSegue: DSegue!
    var isFavoredUser: Bool! = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.topItem?.title = "";
        
        _app.initViewDict()
        guardForRequiredParameter()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(assetIdentifier: UIImage.AssetIdentifier.detailBtnReportNormal), style: UIBarButtonItemStyle.plain, target: self, action: #selector(CardDetailViewController.report(_:)))
        
        self.navigationController?.navigationBar.setBottomNomaringBorderColor(color: UIColor(rgba: "#e6e6e6"), height: 1)
        
        // segue
        likeMessagePopupSegue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "MultilineMessagePopupController") as! MultilineMessagePopupController
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: 372.0)
            })
            destination.useAddVoice = true
            var requiredBuzzie: Int = 0
            destination.titleMessage = "상대방에게 좋아요를 보낼까요?"
            if self?.detailType == .RejectedMe {
                if _app.sessionViewModel.model?.gender == "F" {
                    destination.subtitleMessage = "무료로 보낼 수 있어요"
                }else {
                    destination.subtitleMessage = "15버찌 필요"
                    requiredBuzzie = 15
                }
            } else if self?.fromType == "H" {
                if _app.sessionViewModel.model?.gender == "F" {
                    destination.subtitleMessage = "무료로 보낼 수 있어요"
                }else {
                    destination.subtitleMessage = "15버찌 필요"
                    requiredBuzzie = 15
                }
            }else if self?.fromType == "T" {
                if _app.sessionViewModel.model?.gender == "F" {
                    destination.subtitleMessage = "무료로 보낼 수 있어요"
                }else {
                    destination.subtitleMessage = "5버찌 필요"
                    requiredBuzzie = 5
                }
            } else {
                if _app.sessionViewModel.model?.gender == "F" {
                    destination.subtitleMessage = "무료로 보낼 수 있어요"
                }else {
                    destination.subtitleMessage = "15버찌 필요"
                    requiredBuzzie = 15
                } 
            }
            destination.placeholder = "어떤 부분이 마음에 들었는지 메시지를 이 곳에 적어 함께 보내 보세요"
            destination.submitHandler = { (popup) -> () in
                guard let userId = _app.cardDetailViewModel.model?.profileModel?.id else {
                    return
                }
                
                // 좋아요 api 호출
                let responseViewModel = DViewModel<ApiResponse>(self, { [weak self] (model, oldModel) -> () in
                    guard let apiResponse = model else {
                        return
                    }
                    if apiResponse.statusCode == 200 {
                        // viewmodel 갱신과 창닫기
                        self?.reloadApi()
                        // 소식 갱신
                        _app.historiesViewModel.dirtyFlag = true
                        popup.dismiss(animated:true, completion: nil)
                    } else {
                        guard let serverErrorModel = apiResponse.serverErrorModel else {
                            Toast.showToast(message: "\(apiResponse.statusCode)")
                            return
                        }
                        Toast.showToast(message: "\(serverErrorModel.description ?? "")")
                    }
                    })
                //
                if _app.sessionViewModel.model?.gender == "M" {
                    
                    if let voiceUrl =  popup.voiceUrl , voiceUrl.length > 0 {
                        requiredBuzzie += 5
                    }
                    if let p = _app.sessionViewModel.model?.point,  requiredBuzzie > p {
                        popup.dismiss(animated:true, completion: { () -> Void in
                            alert(title: "포인트 부족", message: "버찌가 부족합니다.")
                        })
                        
                        return
                    }
                }
                
                let _ = _app.api.cardLike(userId: userId, comment: popup.message, fromType: self?.fromType, voice: popup.voiceUrl, apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
                
                
                _app.ga.trackingEventCategory(category:"user_detail", action: "like", label: "like_confirm")
            }
            return (destination, style)
        })
        
        talkSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            
            let destination = UIViewController.viewControllerFromStoryboard(name: "Chat", identifier: "ChatNavigationViewController")
            let style = DSegueStyle.PresentModally
            return (destination, style)
        })
        
        // viewmodel
        
        _app.cardDetailViewModel.bind (view: self) { [weak self] (model, oldModel) -> () in
            guard let cardDetailModel = model else {
                return
            }
            self?.title = cardDetailModel.profileModel?.name
            
            // detailType 정하기
            if self?.isFromChatView == true {
                self?.detailType = .Nothing
            } else if cardDetailModel.isILike == true {
                if cardDetailModel.reply == .Accept {
                    self?.detailType = .AcceptedMe
                } else if cardDetailModel.reply == .Reject {
                    self?.detailType = .RejectedMe
                } else if cardDetailModel.likeCheckedAt != nil {
                    self?.likeCheckedAt = cardDetailModel.likeCheckedAt
                    self?.detailType = .LikeChecked
                } else {
                    self?.detailType = .Waiting
                }
            } else if cardDetailModel.isLikeMe == true {
                if cardDetailModel.reply == .Accept {
                    self?.detailType = .IAccepted
                } else if cardDetailModel.reply == .Reject {
                    self?.detailType = .IRejected
                } else {
                    self?.detailType = (cardDetailModel.isLikeCheck == true) ? .LikeCheck : .YesNo
                }
            } else if self?.isFavoredUser == true {
                self?.detailType = .YetFavored
                if let isFavored = _app.cardDetailViewModel.model?.profileModel?.favorMatch {
                    if isFavored == true {
                        self?.detailType = .Favored
                        if self?.isLikeButtonPressed == true {
                            /*
                            confirm("대화리스트로 이동하시겠습니까?") { (action) -> Void in
                                self?.talkSegue.perform()
                            }*/
                        }
                    }
                }
                self?.isLikeButtonPressed = false
            } else {
                // 기본은 좋아요 버튼
                if _app.cardDetailViewModel.model?.profileModel?.favorMatch == true {
                    self?.detailType = .Favored
                }else {
                    self?.detailType = .Like
                }
            }
        }
        
        reloadApi()
    }
    
    deinit {
        print(#function, "\(self)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = "";
        _app.ga.trackingViewName(viewName: .user_detail)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension CardDetailViewController: ApiReloadable {
    func reloadApi() {
        let responseViewModel = ApiResponseViewModelBuilder<CardDetailModel>(successHandlerWithDefaultError: { (cardDetailModel) -> Void in
            _app.cardDetailViewModel.model = cardDetailModel
            for childVC in self.childViewControllers {
                if let tableVC = childVC as? CardDetailTableViewController{
                    tableVC.tableView.reloadData()
                }
            }
        }).viewModel
        //_app.api.cardDetail(targetUserId, apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
        let _ = _app.api.cardDetail(userId: targetUserId, likeCheck: isLikeMe, apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
    }
}

extension CardDetailViewController {
    @objc func report(_ sender: AnyObject?) {
        
        guard let userId = _app.sessionViewModel.model?.id else {
            return
        }
        
        let title = "그당반 신고사항이 있습니다."
        let body =
            "\n\n\n\n" +
            "--------------------------------\n" +
            "ios,\(userId),\(targetUserId)\n\n" +
            "*주의: 위의 문자는 문제를 해결하기위해 필요한 정보입니다. 지우지 마세요.\n" +
            "--------------------------------\n"
        
        confirm(title: "불량회원 신고를 위하여 이메일앱으로 연결합니다.") { (action) -> Void in
            _app.delegate.openEmailAppToMasterWithSubject(subject: title, body: body)
        }
    }
}
