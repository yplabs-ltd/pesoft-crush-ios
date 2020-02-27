//
//  ConfigTableViewController.swift
//  DateApp
//
//  Created by ryan on 1/16/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import UIKit

class ConfigTableViewController: UITableViewController {
    @IBOutlet weak var firstTableView: UITableView!
    @IBOutlet weak var enableCardSwitch: UISwitch!
    @IBOutlet weak var enableLikeSwitch: UISwitch!
    @IBOutlet weak var enableChatSwitch: UISwitch!
    @IBOutlet weak var facebookSwitch: UISwitch!
    @IBOutlet weak var labelSlider: NMRangeSlider!
    @IBOutlet weak var distanceSlider: NMRangeSlider!
    @IBOutlet weak var heightSlider: NMRangeSlider!
    
    @IBOutlet weak var ageValueLabel: UILabel!
    @IBOutlet weak var distanceValueLabel: UILabel!
    @IBOutlet weak var heightValueLabel: UILabel!
    
    @IBAction func toggle(sender: AnyObject) {
        guard let sender = sender as? UISwitch else {
            return
        }
        switch sender {
        case enableCardSwitch:
            _app.oneSignal.sendTagEnableCard(value: enableCardSwitch.isOn)
        case enableLikeSwitch:
            _app.oneSignal.sendTagEnableLike(value: enableLikeSwitch.isOn)
        case enableChatSwitch:
            _app.oneSignal.sendTagEnableChat(value: enableChatSwitch.isOn)
        case facebookSwitch:
            facebookSwitch.isOn = !facebookSwitch.isOn
            _app.sessionViewModel.settingInfoModel.facebookAvoid = facebookSwitch.isOn
            updateSettingInfo()
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "매칭 설정"
        
        configureLabelSlider()
        getSettingInfo()
        
        setMatchingTodayAge()
        _app.oneSignalTagsViewModel.bind (view: self) { [weak self] (model, oldModel) -> () in
            guard let tags = model else {
                self?.enableCardSwitch.isOn = false
                self?.enableChatSwitch.isOn = false
                self?.enableLikeSwitch.isOn = false
                return
            }
            self?.enableCardSwitch.isOn = tags.enableCard ?? false
            self?.enableChatSwitch.isOn = tags.enableChat ?? false
            self?.enableLikeSwitch.isOn = tags.enableLike ?? false
        }
        reloadApi()
    }
    
    deinit {
        print(#function, "\(self)")
    }
    
    func setMatchingTodayAge() {
        let matchTodayAgeModel = ApiResponseViewModelBuilder<MatchTodayAgeModel>(errorHandler: { [weak self] (statusCode, serverError) -> Void in
            
        }) { [weak self] (model) -> Void in
            _app.matchTodayAge = model
            if let wself = self {
                if let minAge = _app.matchTodayAge?.minAge, let maxAge = _app.matchTodayAge?.maxAge {
                    wself.labelSlider.minimumRange = 0
                    wself.labelSlider.upperValue = Float(maxAge) - 19.0
                    wself.labelSlider.lowerValue = Float(minAge) - 19.0
                    
                    _app.userDefault.minAge = "\(minAge)"
                    _app.userDefault.maxAge = "\(maxAge)"
                    wself.updateAgeLabel()
                }
            }
            }.viewModel
        let _ = _app.api.matchTodayAge(apiResponseViewModel: matchTodayAgeModel, loadingViewModel: _app.loadingViewModel)
    }

    
    func configureLabelSlider() {
        // Age
        self.labelSlider.minimumValue = 0;
        self.labelSlider.maximumValue = 21;
        
        self.labelSlider.lowerValue = 0;
        self.labelSlider.upperValue = 10;
        if let minAge = _app.userDefault.minAge, let maxAge = _app.userDefault.maxAge {
            self.labelSlider.lowerValue = Float(minAge)! - 19;
            self.labelSlider.upperValue = Float(maxAge)! - 19;
        }
        self.labelSlider.minimumRange = 6;
        updateAgeLabel()
        
        // Distance
        self.distanceSlider.minimumValue = 0;
        self.distanceSlider.maximumValue = 60;
        
        self.distanceSlider.lowerValue = 0;
        self.distanceSlider.upperValue = 10;
        self.distanceSlider.minimumRange = 10;
        updateDistanceLabel()
        
        // Height
        self.heightSlider.minimumValue = 0;
        self.heightSlider.maximumValue = 70;
        self.heightSlider.minimumRange = 5;
        
        
        self.heightSlider.upperValue = 35;
        self.heightSlider.lowerValue = 30;
        updateHeightLabel()
    }
    
    @IBAction func valueChanged() {
        updateAgeLabel()
        updateMatchAge()
    }
    
    @IBAction func distanceValueChanged() {
        updateDistanceLabel()
        updateSettingInfo()
    }
    
    @IBAction func heightValueChanged() {
        updateHeightLabel()
        updateSettingInfo()
    }
    
    func updateMatchAge() {
        UIViewController.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(self.excuteUpdateMatchTodayAge), with: nil, afterDelay: 0.3)
    }
    
    @objc func excuteUpdateMatchTodayAge() {
        let matchTodayAgeModel = ApiResponseViewModelBuilder<MatchTodayAgeModel>(errorHandler: { [weak self] (statusCode, serverError) -> Void in
            
        }) { [weak self] (model) -> Void in
            _app.matchTodayAge = model
            }.viewModel
        let _ = _app.api.updateMatchTodayAge(minAge: Int(self.labelSlider.lowerValue+19), maxAge: Int(self.labelSlider.upperValue+19), apiResponseViewModel: matchTodayAgeModel, loadingViewModel: nil)
        _app.userDefault.minAge = "\(Int(self.labelSlider.lowerValue+19))"
        _app.userDefault.maxAge = "\(Int(self.labelSlider.upperValue+19))"
    }
    
    func updateSettingInfo() {
        UIViewController.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(self.excuteUpdateSettingInfo), with: nil, afterDelay: 0.3)
    }
    
    @objc func excuteUpdateSettingInfo() {
        _app.sessionViewModel.settingInfoModel.hopeKmMax = Int(distanceSlider.upperValue)
        _app.sessionViewModel.settingInfoModel.hopeKmMin = Int(distanceSlider.lowerValue)
        _app.sessionViewModel.settingInfoModel.hopeHeightMax = Int(heightSlider.upperValue) + 130
        _app.sessionViewModel.settingInfoModel.hopeHeightMin = Int(heightSlider.lowerValue) + 130

        
        let settingInfoModel = ApiResponseViewModelBuilder<SettingInfoModel>(errorHandler: { [weak self] (statusCode, serverError) -> Void in
            
        }) { [weak self] (model) -> Void in
            
            print("")
            }.viewModel
        let _ = _app.api.requestUpdateSetting(apiResponseViewModel: settingInfoModel, loadingViewModel: nil)
    }
    
    func getSettingInfo() {
        let settingInfoModel = ApiResponseViewModelBuilder<SettingInfoModel>(errorHandler: { [weak self] (statusCode, serverError) -> Void in
            
        }) { [weak self] (model) -> Void in
            guard let wself = self else { return }
            
            _app.sessionViewModel.settingInfoModel = model

            wself.facebookSwitch.isOn = model.facebookAvoid == nil ? false : (model.facebookAvoid!)
            wself.distanceSlider.upperValue = Float(model.hopeKmMax ?? 10)
            wself.distanceSlider.lowerValue = Float(model.hopeKmMin ?? 0)
            
            wself.heightSlider.upperValue = Float(model.hopeHeightMax ?? 165) - 130
            wself.heightSlider.lowerValue = Float(model.hopeHeightMin ?? 160) - 130
            
            wself.updateHeightLabel()
            wself.updateDistanceLabel()
            
            }.viewModel
        let _ = _app.api.requestGetSettingInfo(apiResponseViewModel: settingInfoModel, loadingViewModel: nil)
    }
    
    func updateAgeLabel() {
        ageValueLabel.text = "\(Int(self.labelSlider.lowerValue)+19)세 ~ \(Int(self.labelSlider.upperValue+19))세"
    }
    
    func updateHeightLabel() {
        heightValueLabel.text = "\(Int(self.heightSlider.lowerValue)+130)cm ~ \(Int(self.heightSlider.upperValue) + 130)cm"
    }
    
    func updateDistanceLabel() {
        distanceValueLabel.text = "\(Int(self.distanceSlider.lowerValue))km ~ \(Int(self.distanceSlider.upperValue))km"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _app.ga.trackingViewName(viewName: .setting)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 11: // 계정휴면
            confirm(title: "계정휴면을 하시겠습니까?", handler: { (action) -> Void in
                let responseViewModel = ApiResponseViewModelBuilder<ServerDefaultResponseModel>(successHandlerWithDefaultError: { (model) -> Void in
                    _app.delegate.logout()
                }).viewModel
                let _ = _app.api.accountSleepAccount(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
            })
        case 12: // 계정탈퇴
            confirm(title: "계정탈퇴를 하시겠습니까?", handler: { (action) -> Void in
                let responseViewModel = ApiResponseViewModelBuilder<ServerDefaultResponseModel>(successHandlerWithDefaultError: { (model) -> Void in
                    _app.delegate.logout()
                }).viewModel
                let _ = _app.api.accountSignout(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
            })
        case 13: // 로그아웃
            confirm(title: "로그아웃 하시겠습니까?", handler: { (action) -> Void in
                
                let responseViewModel = ApiResponseViewModelBuilder<ServerDefaultResponseModel>(successHandlerWithDefaultError: { (model) -> Void in
                    _app.delegate.logout()
                }).viewModel
                let _ = _app.api.accountLogout(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
            })
        default:
            break
        }
    }
}

extension ConfigTableViewController: ApiReloadable {
    func reloadApi() {
        _app.oneSignal.getTags()
        
    }
}
