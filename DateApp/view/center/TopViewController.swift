//
//  TopViewController.swift
//  DateApp
//
//  Created by ryan on 12/12/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit

final class TopViewController: UIViewController {

    @IBOutlet weak var pageScrollView: UIScrollView!
    
    var buttonContainerView: UIView!
    var todayPageButton: UIButton!      // today
    var estimatePageButton: UIButton!   // 평가
    var storyPageButton: UIButton!      // Story
    var newsPageButton: UIButton!       // 소식
    
    var estimateCountLabel: UILabel!    // 평가 남은 수 badge
    var newsCountLabel: UILabel!        // 나를 좋아하는 수 badge
    
    private let pageCount = 4
    private var todayViewController: TodayViewController!
    private var evaluationViewController: EvaluationViewController!
    private var storyViewMainController: StoryViewMainController!
    private var newsViewController: NewsViewController!
    
    private var menuSegue: DSegue!
    private var talkSegue: DSegue!
    private var profileSegue: DSegue!
    
    private var currentPageIndex: Int? {
        // current page 변경
        didSet {
            guard let index = currentPageIndex else {
                return
            }
            
            guard currentPageIndex != oldValue else {
                return
            }
            
            if oldValue == 3 || currentPageIndex == 3 {
                _app.historiesViewModel.reload()
            }
            
            // 페이지 위치 이동과 버튼 모양 변경
            
            var rect = pageScrollView.frame
            rect.origin.y = 0
            switch index {
            case 0:
                rect.origin.x = 0
                activePageButton(estimatePageButton)
                inactivePageButton(todayPageButton)
                inactivePageButton(storyPageButton)
                inactivePageButton(newsPageButton)
                
                _app.evaluationCardsViewModel.requestUpdate()
                
                _app.ga.trackingViewName(viewName: .evaluate)
                
            case 1:
                rect.origin.x = rect.size.width
                inactivePageButton(estimatePageButton)
                activePageButton(todayPageButton)
                inactivePageButton(storyPageButton)
                inactivePageButton(newsPageButton)
                
                _app.ga.trackingViewName(viewName: .today)
                todayViewController.checkShowPromotionAlert()
            case 2:
                rect.origin.x = rect.size.width * 2
                inactivePageButton(estimatePageButton)
                inactivePageButton(todayPageButton)
                activePageButton(storyPageButton)
                inactivePageButton(newsPageButton)
                
                _app.userVoiceOneViewModel.reloadIfDirty()
                
                _app.ga.trackingViewName(viewName: .story)
            case 3:
                rect.origin.x = rect.size.width * 3
                inactivePageButton(estimatePageButton)
                inactivePageButton(todayPageButton)
                inactivePageButton(storyPageButton)
                activePageButton(newsPageButton)
                
                _app.historiesViewModel.reloadIfDirty()
                
                _app.ga.trackingViewName(viewName: .news)
                
            default:
                rect.origin.x = 0
            }
            if oldValue == nil {
                // 이전 값이 nil인 경우는 첫 페이지 오픈으로 간주(no animation)
                pageScrollView.setContentOffset(rect.origin, animated: false)
            } else {
                pageScrollView.setContentOffset(rect.origin, animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageScrollView.alwaysBounceHorizontal = true
        pageScrollView.bounces = true
        
        // 페이지 전환을 위한 메인 상단 버튼
        buttonContainerView = UIView()
        todayPageButton = UIButton()
        todayPageButton.setTitle("TODAY", for: UIControlState.normal)
        todayPageButton.addTarget(self, action: #selector(TopViewController.page(_:)), for: UIControlEvents.touchUpInside)
        
        estimatePageButton = UIButton()
        estimatePageButton.setTitle("평가", for: UIControlState.normal)
        estimatePageButton.addTarget(self, action: #selector(TopViewController.page(_:)), for: UIControlEvents.touchUpInside)
        
        storyPageButton = UIButton()
        storyPageButton.setTitle("STORY", for: UIControlState.normal)
        storyPageButton.addTarget(self, action: #selector(TopViewController.page(_:)), for: UIControlEvents.touchUpInside)
        
        newsPageButton = UIButton()
        newsPageButton.setTitle("소식", for: UIControlState.normal)
        newsPageButton.addTarget(self, action: #selector(TopViewController.page(_:)), for: UIControlEvents.touchUpInside)
        
        buttonContainerView.addSubview(todayPageButton)
        buttonContainerView.addSubview(estimatePageButton)
        buttonContainerView.addSubview(storyPageButton)
        buttonContainerView.addSubview(newsPageButton)

        navigationItem.titleView = buttonContainerView
        
        /*
        let navigationBar = self.navigationController!.navigationBar
        let navBorder: UIView = UIView(frame: CGRect(x: 16, navigationBar.frame.size.height - 1, navigationBar.frame.size.width - 32, 1))
        // Set the color you want here
        navBorder.backgroundColor = UIColor(rgba: "#ecebea")
        navBorder.opaque = true
        self.navigationController?.navigationBar.addSubview(navBorder)
        */
        
        let margin: CGFloat = UIScreen.main.bounds.width > 375 ? 5 : 0
        let btnWidth: CGFloat = (UIScreen.main.bounds.width - (100 + 111)) / 2
        
        buttonContainerView.addConstraints(
            DConstraintsBuilder()
                .addView(view: todayPageButton, name: "todayPageButton")
                .addView(view: estimatePageButton, name: "estimatePageButton")
                .addView(view: storyPageButton, name: "storyPageButton")
                .addView(view: newsPageButton, name: "newsPageButton")
                .addVFS(
                    vfsArray: "H:|[estimatePageButton(50)][todayPageButton(\(btnWidth-margin))][storyPageButton(\(btnWidth-margin))][newsPageButton(50)]|",
//                    "H:|-0-[estimatePageButton(40)]-0-|",
//                    "H:|-0-[todayPageButton(170)]-0-|",
//                    "H:|-0-[storyPageButton(300)]-0-|",
//                    "H:|-0-[newsPageButton(40)]-0-|",
                    "V:|[estimatePageButton]|",
                    "V:|[todayPageButton]|",
                    "V:|[storyPageButton]|",
                    "V:|[newsPageButton]|"
                ).constraints)
        
        // 평가버튼 오른쪽 상단 옆의 count badge
        estimateCountLabel = LabelBuilder(badgeFrame: CGRect(x: 0, y: 0, width: 14, height: 14), text: "0").label
        estimateCountLabel.isHidden = true
        buttonContainerView.addSubview(estimateCountLabel)
        estimateCountLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonContainerView.addConstraints(DConstraintsBuilder.constraintsForView(view: estimateCountLabel, size: CGSize(width: 14, height: 14)))
        buttonContainerView.addConstraints([
            NSLayoutConstraint(item: estimateCountLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: estimatePageButton, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 23.0),
            NSLayoutConstraint(item: estimateCountLabel, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: estimatePageButton, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: -5.0)])
        
        // 소식버튼 오른쪽 상단 옆의 count badge
        newsCountLabel = LabelBuilder(badgeFrame: CGRect(x: 0, y: 0, width: 14, height: 14), text: "0").label
        newsCountLabel.isHidden = true
        buttonContainerView.addSubview(newsCountLabel)
        newsCountLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonContainerView.addConstraints(DConstraintsBuilder.constraintsForView(view: newsCountLabel, size: CGSize(width: 14, height: 14)))
        buttonContainerView.addConstraints([
            NSLayoutConstraint(item: newsCountLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: newsPageButton, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 23.0),
            NSLayoutConstraint(item: newsCountLabel, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: newsPageButton, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: -5.0)])
        
        pageScrollView.delegate = self
        
        // pages setup
        todayViewController = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "TodayViewController") as? TodayViewController
        evaluationViewController = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "EvaluationViewController") as? EvaluationViewController
        storyViewMainController = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "StoryViewMainController") as? StoryViewMainController
        newsViewController = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "NewsViewController") as? NewsViewController
        addChildViewController(todayViewController)
        addChildViewController(evaluationViewController)
        addChildViewController(storyViewMainController)
        addChildViewController(newsViewController)
        
        pageScrollView.addSubview(todayViewController.view)
        pageScrollView.addSubview(evaluationViewController.view)
        pageScrollView.addSubview(storyViewMainController.view)
        pageScrollView.addSubview(newsViewController.view)
        
        // 좌측 메뉴
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(image: UIImage(assetIdentifier: .Menu), style: UIBarButtonItemStyle.plain, target: self, action: #selector(TopViewController.menu(_:)))
        ]
        
        // 우측 메뉴
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(assetIdentifier: UIImage.AssetIdentifier.homeBtnChatNormal), style: UIBarButtonItemStyle.plain, target: self, action: #selector(TopViewController.talk(_:)))
        ]
        
        // segue
        
        menuSegue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Main", identifier: "MenuViewController")
            if var destination = destination as? CenterViewControllerRequired {
                destination.centerViewController = self
            }
            let style = DSegueStyle.PresentModallyWithDirection(.LeftToRight, sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 219.0, height: parentSize.height)
            })
            return (destination, style)
        })
        
        talkSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            
            let destination = UIViewController.viewControllerFromStoryboard(name: "Chat", identifier: "ChatNavigationViewController")
            let style = DSegueStyle.PresentModally
            return (destination, style)
        })
        
        
        profileSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Profile", identifier: "ProfileViewController")
            let style = DSegueStyle.Show(animated: true)
            return (destination, style)
        })
        
        // viewmodel
        
        // 평가 카운트
        estimateCountLabel.isHidden = true
        // 소식 카운트
        _app.historiesViewModel.bind (view: self) { [weak self] (model, oldModel) -> () in
            guard let histories = model else {
                return
            }
            let count = histories.likeMeCards.count
            if 0 < count {
                self?.newsCountLabel.isHidden = false
                self?.newsCountLabel.text = "\(count)"
            } else {
                self?.newsCountLabel.isHidden = true
                self?.newsCountLabel.text = "0"
            }
        }
        
        // 대화 N badge
        _app.talkChannelsViewModel.bind (view: self) { [weak self] (model, oldModel) -> () in
            
            if let rightBarButtonItem = self?.navigationItem.rightBarButtonItem {
                // 대화알림 바버튼
                
                if _app.talkChannelsViewModel.hasNewMessage || _app.talkChannelsViewModel.hasNewChannel {
                    rightBarButtonItem.image = UIImage(assetIdentifier: .homeBtnChatNewNormal).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
                } else {
                    rightBarButtonItem.image = UIImage(assetIdentifier: .homeBtnChatNormal).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
                }
            }
        }
        
        // 처음에 새소식 확인
        _app.historiesViewModel.reload()
        
        // 평가 reload
        if _app.evaluationCardsViewModel.model == nil {
            _app.evaluationCardsViewModel.reload()
        }
        
        // 채팅 확인
        _app.talkChannelsViewModel.reload()
        
        _app.userVoiceOneViewModel.reload()
    }
    
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    deinit {
        print(#function, "\(self)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //[[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
        
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: ""), forBarMetrics: UIBarMetrics.Default)
//        self.navigationController?.navigationBar.shadowImage = UIImage(named: "")
//        
//        [self.navigationController.navigationBar.layer setBorderWidth:2.0];// Just to make sure its working
//        [self.navigationController.navigationBar.layer setBorderColor:[[UIColor redColor] CGColor]];
//
//        self.navigationController?.navigationBar.layer.borderColor = UIColor.clear
//        self.navigationController?.navigationBar.layer.borderWidth = 0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 상단 페이지 버튼들의 컨테이너 위치 조정
        if let superView = buttonContainerView.superview {
            buttonContainerView.frame.size = CGSize(width: 300.0, height: superView.frame.height)
        }
        
        // pageScrollView contentSize 조정
        pageScrollView.contentSize.width = view.frame.width * CGFloat(pageCount)
        pageScrollView.contentSize.height = pageScrollView.frame.height
        
        // 각 page 위치 조정
        evaluationViewController.view.frame = CGRect(x: 0, y: 0, width: pageScrollView.frame.width, height: pageScrollView.frame.height)
        todayViewController.view.frame = CGRect(x: view.frame.width, y: 0, width: pageScrollView.frame.width, height: pageScrollView.frame.height)
        storyViewMainController.view.frame = CGRect(x: view.frame.width * 2, y: 0, width: pageScrollView.frame.width, height: pageScrollView.frame.height)
        newsViewController.view.frame = CGRect(x: view.frame.width * 3, y: 0, width: pageScrollView.frame.width, height: pageScrollView.frame.height)
        
        // pageScrollView 원점 조정
        if let index = currentPageIndex {
            currentPageIndex = index
        } else {
            currentPageIndex = 1
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ReplyEventViewController,
            let param = sender as? [String:AnyObject],
            let nextDttm = param["nextDttm"] as? Date {
                vc.nextDttm = nextDttm
        }
    }
    
    func moveToEvaluate() {
        currentPageIndex = 0
    }
    
    func moveToToday() {
        currentPageIndex = 1
    }
    
    func moveToStory() {
        currentPageIndex = 2
    }
    
    func moveToNotice() {
        currentPageIndex = 3
    }
}

extension TopViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let fractionalPage = scrollView.contentOffset.x / pageWidth
        let page = Int(round(fractionalPage))
        
        currentPageIndex = page
        
        if currentPageIndex == 2 {
            storyViewMainController.animateBottomBGView(direction: ScrollDirection.Down)
        }else {
            storyViewMainController.animateBottomBGView(direction: ScrollDirection.Up)
        }
    }
}

extension TopViewController {
    
    @objc func page(_ sender: AnyObject) {
        
        if sender === estimatePageButton {
            currentPageIndex = 0
        } else if sender === todayPageButton {
            currentPageIndex = 1
        } else if sender === storyPageButton {
            currentPageIndex = 2
        } else if sender === newsPageButton {
            currentPageIndex = 3
        }
    }
    
    @objc func menu(_ sender: AnyObject?) {
        menuSegue.perform()
    }
    
    @objc func talk(_ sender: AnyObject?) {
        
        if _app.sessionViewModel.model?.status != .Normal {
            if _app.sessionViewModel.model?.status == .Waiting {
                alert(title: "프로필 승인 대기중입니다.", message: "대화방 이용을 위해서는 프로필 승인이 완료되어야 합니다.")
                return
            }
            
            confirm(title: "프로필 입력화면으로 이동합니다.", message: "대화방 이용을 위해서는 프로필 입력이 필요합니다", handler: { [weak self] (action) -> Void in
                self?.profileSegue.perform()
            })
            return
        }
        talkSegue.perform()
    }
    
    private func activePageButton(_ button: UIButton) {
        var fontSize: CGFloat = 17
        if UIScreen.main.bounds.width == 320 {
            fontSize = 13
        }
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: fontSize)
        button.setTitleColor(UIColor(rgba: "#726763"), for: UIControlState.normal)
    }
    
    private func inactivePageButton(_ button: UIButton) {
        var fontSize: CGFloat = 17
        if UIScreen.main.bounds.width == 320 {
            fontSize = 13
        }
        button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        button.setTitleColor(UIColor(rgba: "#c0bcbb"), for: UIControlState.normal)
    }
}
