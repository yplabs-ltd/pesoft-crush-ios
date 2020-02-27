//
//  TopRankListViewController.swift
//  DateApp
//
//  Created by Daehyun Lim on 2018. 5. 18..
//  Copyright © 2018년 iflet.com. All rights reserved.
//

import Foundation
//
//  VoiceChatRoomViewController.swift
//  DateApp
//
//  Created by Yang Hyeon Gyu on 2017. 3. 19..
//  Copyright © 2017년 iflet.com. All rights reserved.
//

import UIKit

class TopRankListViewController : UIViewController {
    private var profileRequireSegue: DSegue!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var refreshControl: UIRefreshControl!
    
    private var chatSegue: DSegue!
    
    private var myDetailRankSegue: DSegue!
    
    private var oldUserVoiceOneModel: UserVoiceOneModel!
    
    deinit {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //oldUserVoiceOneModel = _app.userVoiceOneViewModel.model
        navigationController?.makeNavigationBarDefaultStyle()
        
        self.title = "실시간 TOP10"
        
        profileRequireSegue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "FillProfileInformationViewController")
            let style = DSegueStyle.Show(animated: true)
            return (destination, style)
        })
        
        if _app.sessionViewModel.model?.status != .Normal {
            if _app.sessionViewModel.model?.status == .Waiting {
                alert(title: "프로필 승인 대기중입니다.", message: "서비스를 이용하기 위해선 프로필 승인이 완료되어야 합니다.")
                return
            }
            
            confirm(title: "프로필 입력화면으로 이동합니다.", message: "서비스를 이용하기 위해선 추가 회원정보를 입력해야 합니다", handler: { [weak self] (action) -> Void in
                self?.profileRequireSegue.perform()
            })
        }
        
        _app.voiceChatRoomViewModel.bind (view: self) { [weak self] (model, oldModel) -> () in
            self?.tableView.reloadData()
        }
        
        chatSegue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "voiceChatViewController") as! VoiceChatViewController
            let style = DSegueStyle.Show(animated: true)
            return (destination, style)
        })
        
        myDetailRankSegue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "MyDetailRankViewController") as! MyDetailRankViewController
            destination.myRankModel = _app.voiceChatRoomViewModel.myRank
            let style = DSegueStyle.Show(animated: true)
            return (destination, style)
        })
        
        _app.voiceChatRoomViewModel.onShouldUpdateMyChatList = { [weak self] in
            guard let wself = self else { return }
            wself.tableView.reloadData()
        }
        
        _app.voiceChatRoomViewModel.model = []

        _app.voiceChatRoomViewModel.getMyVoiceRank()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "실시간 TOP10"
        
        _app.voiceChatRoomViewModel.getVoiceRankList()
        if animated {
            _app.voiceChatRoomViewModel.model = []
            _app.voiceChatRoomViewModel.reload()
        }
        
        if _app.sessionViewModel.model?.status != .Normal {
            if _app.sessionViewModel.model?.status == .Waiting {
                alert(title: "프로필 승인 대기중입니다.", message: "서비스를 이용하기 위해선 프로필 승인이 완료되어야 합니다.")
                return
            }
            
            confirm(title: "프로필 입력화면으로 이동합니다.", message: "서비스를 이용하기 위해선 추가 회원정보를 입력해야 합니다", handler: { [weak self] (action) -> Void in
                self?.profileRequireSegue.perform()
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isBeingDismissed || self.isMovingFromParentViewController {
            //_app.userVoiceOneViewModel.model = oldUserVoiceOneModel
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue == chatSegue {
            if let vc = segue.destination as? VoiceChatViewController, let voiceChatRoomModel = (sender as? DViewModel<VoiceChatRoomModel>)?.model {
                _app.voiceChatRoomViewModel.check(voiceChatRoomModel: voiceChatRoomModel)
                vc.voiceChatRoomModel = voiceChatRoomModel
            }
        }
    }
}

extension TopRankListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 34.5
        case 1:
            return (_app.voiceChatRoomViewModel.myRank?.name?.length)! > 0 ? 34.5 : 0
        case 2:
            return (_app.voiceChatRoomViewModel.myRank?.name?.length)! > 0 ? 95 : 0
        case 3:
            if let list = _app.sessionViewModel.model?.gender == "M" ? _app.voiceChatRoomViewModel.topRankList?.femaleList : _app.voiceChatRoomViewModel.topRankList?.maleList , list.count > 0 {
                return 34.5
            }
        case 4: // cards
            if let list = _app.sessionViewModel.model?.gender == "M" ? _app.voiceChatRoomViewModel.topRankList?.femaleList : _app.voiceChatRoomViewModel.topRankList?.maleList , list.count > 0 {
                return 95
            }
        case 5:
            if let list = _app.sessionViewModel.model?.gender == "M" ? _app.voiceChatRoomViewModel.topRankList?.maleList : _app.voiceChatRoomViewModel.topRankList?.femaleList , list.count > 0 {
                return 34.5
            }
        case 6:
            if let list = _app.sessionViewModel.model?.gender == "M" ? _app.voiceChatRoomViewModel.topRankList?.maleList : _app.voiceChatRoomViewModel.topRankList?.femaleList , list.count > 0 {
                return 95
            }
        
        default:()
            
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 2:
            myDetailRankSegue.perform()
        case 4:
            if let destination = UIViewController.viewControllerFromStoryboard(name: "Pages", identifier: "TopVoiceRankViewController") as? TopVoiceRankViewController {
                if let list = _app.sessionViewModel.model?.gender == "M" ? _app.voiceChatRoomViewModel.topRankList?.femaleList : _app.voiceChatRoomViewModel.topRankList?.maleList {
                    let rankInfo = list[indexPath.row]
                    
                    destination.userVoiceOneModel = rankInfo.convertToVoiceOneModel()
                    destination.otherUserId = rankInfo.userId
                    destination.otherVoiceCloudId = rankInfo.id
                    let rank = indexPath.row + 1
                    destination.title = "\(rank)위 \(rankInfo.name ?? "")"
                    navigationController?.pushViewController(destination, animated: true)
                }
            }
        case 6:
            alert(message: "동성의 목소리는 들으실 수 없어요!")
        default:()
        }
    }
}

extension TopRankListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1, 2:
            guard let name = _app.voiceChatRoomViewModel.myRank?.name else { return 0 }
            return name.length > 0 ? 1 : 0
        case 3:
            if let list = _app.sessionViewModel.model?.gender == "M" ? _app.voiceChatRoomViewModel.topRankList?.femaleList : _app.voiceChatRoomViewModel.topRankList?.maleList , list.count > 0 {
                return 1
            }
        case 4: // cards
            if let list = _app.sessionViewModel.model?.gender == "M" ? _app.voiceChatRoomViewModel.topRankList?.femaleList : _app.voiceChatRoomViewModel.topRankList?.maleList {
                return list.count
            }
        case 5:
            if let list = _app.sessionViewModel.model?.gender == "M" ? _app.voiceChatRoomViewModel.topRankList?.maleList : _app.voiceChatRoomViewModel.topRankList?.femaleList , list.count > 0 {
                return 1
            }
        case 6:
            if let list = _app.sessionViewModel.model?.gender == "M" ? _app.voiceChatRoomViewModel.topRankList?.maleList : _app.voiceChatRoomViewModel.topRankList?.femaleList {
                return list.count
            }
            
        default:()
            
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            return tableView.dequeueReusableCell(withIdentifier: "TopRankInfoCell")!
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopRankSectionCell") as! TopRankSectionCell
            cell.title = "오늘 나의 최고 랭킹"
            cell.isBold = true
            cell.titleColor = UIColor.black
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopRankListCell") as! TopRankListCell
            if let myRank = _app.voiceChatRoomViewModel.myRank {
                cell.isEnableBlurImage = false
                cell.enableRankImageView(isEnable: false)
                cell.setRankInfo(rank: myRank)
            }
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopRankSectionCell") as! TopRankSectionCell
            cell.isBold = false
            cell.titleColor = UIColor(r: 114, g: 103, b:99, a: 0.5)
            cell.title = _app.sessionViewModel.model?.gender == "M" ? "여자" : "남자"
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopRankListCell") as! TopRankListCell
            if let list = _app.sessionViewModel.model?.gender == "M" ? _app.voiceChatRoomViewModel.topRankList?.femaleList : _app.voiceChatRoomViewModel.topRankList?.maleList {
                let rankInfo = list[indexPath.row]
                cell.isEnableBlurImage = true
                cell.setRankInfo(rank: rankInfo)
                cell.rank = indexPath.row + 1
                cell.enableRankImageView(isEnable: cell.rank == 1 || cell.rank == 2 || cell.rank == 3)
            }
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopRankSectionCell") as! TopRankSectionCell
            cell.isBold = false
            cell.titleColor = UIColor(r: 114, g: 103, b:99, a: 0.5)
            cell.title = _app.sessionViewModel.model?.gender == "M" ? "남자" : "여자"
            return cell
        case 6  :
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopRankListCell") as! TopRankListCell
            if let list = _app.sessionViewModel.model?.gender == "M" ? _app.voiceChatRoomViewModel.topRankList?.maleList : _app.voiceChatRoomViewModel.topRankList?.femaleList {
                cell.isEnableBlurImage = true
                cell.setRankInfo(rank: list[indexPath.row])
                cell.rank = indexPath.row + 1
                cell.enableRankImageView(isEnable: cell.rank == 1 || cell.rank == 2 || cell.rank == 3)
            }
            return cell
        default:()
        }
        
        return UITableViewCell()
    }
}
