//
//  MyHeartListViewController.swift
//  DateApp
//
//  Created by Daehyun Lim on 2018. 5. 17..
//  Copyright © 2018년 iflet.com. All rights reserved.
//

import UIKit

class MyHeartListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var refreshControl: UIRefreshControl!
    private var cardListNotificationModel = DViewModel<CardListNotificationModel>()
    private var chatSegue: DSegue!
    private var popupSegue: DSegue!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.makeNavigationBarDefaultStyle()
        self.navigationController?.navigationBar.setBottomBorderColor(color: UIColor(rgba: "#e6e6e6"), height: 1)
        // 좌측 닫기 버튼
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(image: UIImage(assetIdentifier: .Close), style: UIBarButtonItemStyle.plain, target: self, action: #selector(MyHeartListViewController.close(_:)))
        ]
        
        navigationItem.title = "내 이야기들"
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)   // 내용없는 셀 표시 안함
        
        // refresh controll
        /*
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MyHeartListViewController.pulldown(_:)), forControlEvents: .valueChanged)
        tableView.addSubview(refreshControl)
         */
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
        navigationItem.title = "내 이야기들"
        _app.ga.trackingViewName(viewName: .chat_list)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reloadApi()
    }
}

extension MyHeartListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = _app.voiceChatRoomViewModel.myChatList?[indexPath.row] {
            let destination = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "MyDetailRankViewController") as! MyDetailRankViewController
            destination.myRankModel = item.convertVoiceRankModel()
            navigationController?.pushViewController(destination, animated: true)
        }
    }
}

extension MyHeartListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _app.voiceChatRoomViewModel.myVoiceChatListCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyHeartListCell") as! MyHeartListCell
        if let item = _app.voiceChatRoomViewModel.myChatList?[indexPath.row] {
            cell.createdDate = item.createdAt?.stringForDate()
            cell.heartCount = item.heartCount
        }
        
        return cell
    }
}

extension MyHeartListViewController: ApiReloadable {
    func reloadApi() {
        _app.voiceChatRoomViewModel.onShouldUpdateMyChatList = { [weak self] in
            guard let wself = self else { return }
            wself.tableView.reloadData()
        }
       _app.voiceChatRoomViewModel.getMyVoiceChatList()
    }
}

extension MyHeartListViewController {
    
    @objc func close(_ sender: AnyObject?) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func pulldown(_ sender: AnyObject?) {
        reloadApi()
    }
    
    /*
     func updatedChannel(channel: ChannelModel?) {
     // channel 정보 바뀌었습니다. 가장 상단으로 이동 되어야 합니다.
     guard let channel = channel else {
     return
     }
     var channels = _app.talkChannelsViewModel.model?.filter { (channelElm) -> Bool in
     if channel.channel.getId() == channelElm.channel.getId() {
     return false
     }
     return true
     }
     channels?.insert(channel, atIndex: 0)
     _app.talkChannelsViewModel.model = channels
     }*/
}
