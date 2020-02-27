//
//  ProfileViewController.swift
//  DateApp
//
//  Created by ryan on 1/4/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import UIKit
import CoreLocation

class ProfileViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    private var newRecordVoiceSegue: DSegue!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBAction func submit(sender: AnyObject) {
        
        guard let imageInfoList = _app.profileViewModel.model?.imageInfoList , 2 <= imageInfoList.validImageCount else {
            alert(title: "사진을 등록해주세요", message: "최소 2장의 사진이 필요합니다.")
            return
        }
        guard let idealTypeCode = _app.profileViewModel.model?.idealType?.code , idealTypeCode != "" else {
            alert(title: "필수 항목을 채워주세요", message: "이런 사람이 좋아요")
            return
        }
        guard let name = _app.profileViewModel.model?.name , name != "" else {
            alert(title: "필수 항목을 채워주세요", message: "닉네임")
            return
        }
        guard let birthDate = _app.profileViewModel.model?.birthDate , birthDate != "" else {
            alert(title: "필수 항목을 채워주세요", message: "나이")
            return
        }
        guard let hometownCode = _app.profileViewModel.model?.hometown?.code , hometownCode != "" else {
            alert(title: "필수 항목을 채워주세요", message: "지역")
            return
        }
        guard let jobCode = _app.profileViewModel.model?.job?.code , jobCode != "" else {
            alert(title: "필수 항목을 채워주세요", message: "직업")
            return
        }
        guard let bodyTypeCode = _app.profileViewModel.model?.bodyType?.code , bodyTypeCode != "" else {
            alert(title: "필수 항목을 채워주세요", message: "체형")
            return
        }
        guard let height = _app.profileViewModel.model?.height , 0 < height else {
            alert(title: "필수 항목을 채워주세요", message: "키")
            return
        }
        guard let bloodTypeCode = _app.profileViewModel.model?.bloodType?.code , bloodTypeCode != "" else {
            alert(title: "필수 항목을 채워주세요", message: "혈액형")
            return
        }
        guard let religionCode = _app.profileViewModel.model?.religion?.code , religionCode != "" else {
            alert(title: "필수 항목을 채워주세요", message: "종교")
            return
        }
        
        if _app.sessionViewModel.settingInfoModel.lat != nil &&
            _app.sessionViewModel.settingInfoModel.lng != nil {
            excuteUpdateSettingInfo()
        }
        // 이미지 업로드 성공 이후에는 profile update api 호출
        _app.profileViewModel.uploadImages(loadingViewModel: _app.loadingViewModel) { [weak self] (newProfileModel) -> () in
            
            // profile update 후에 새로운 응답받은 profilemode 로 model 갱신 까지 해줌
            _app.profileViewModel.updateProfile(profileModel: newProfileModel, loadingViewModel: _app.loadingViewModel) { (newProfileModel) -> () in
                //_app.profileViewModel.setModelWithImage(newProfileModel)
                alert(message: "회원가입 승인을 요청하였습니다")
                self?.reloadApi()
                _app.sessionViewModel.reloadMemberInfo()
                
                // submit 버튼 가리기
                _app.profileSubmitButtonShowViewModel.model = false
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if _app.sessionViewModel.model?.status == .Preview {
            AdBrix.firstTimeExperience( _app.userDefault.facebookAuthToken == nil ? "이멜] 프로필 등록" : "페북] 프로필 등록")
        }
        for childVC in self.childViewControllers {
            if let tableVC = childVC as? ProfileTableViewController{
                tableVC.onClickPlayVoice = { [weak self] in
                    guard let wself = self else { return }
                    wself.newRecordVoiceSegue.perform()
                }
                
                tableVC.onClickRecordVoice = { [weak self] in
                    guard let wself = self else { return }
                    wself.newRecordVoiceSegue.perform()
                }
                tableVC.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
            }
        }
        title = "내 프로필"
        submitButton.isHidden = true  // 일단 가림, 내역 변경이 있으면 submit 버튼 생김
        self.navigationController?.navigationBar.setBottomBorderColor(color: UIColor(rgba: "#e6e6e6"), height: 1)
        if _app.sessionViewModel.model?.status == .Normal {
            submitButton.setTitle("프로필 변경 요청하기", for: UIControlState.normal)
        } else {
            submitButton.setTitle("회원가입 승인 요청하기", for: UIControlState.normal)
        }
        
        _app.profileSubmitButtonShowViewModel.bind (view: self) { [weak self] (model, oldModel) -> () in
            guard let show = model else {
                return
            }
            if show {
                self?.submitButton.isHidden = false
                if let wself = self {
                    for childVC in wself.childViewControllers {
                        if let tableVC = childVC as? ProfileTableViewController{
                            //tableVC.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
                        }
                    }
                }
            } else {
                self?.submitButton.isHidden = true
            }
        }
        _app.profileViewModel.model = nil
        
        reloadApi()
        
        newRecordVoiceSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "MyProfileRecordVoiceViewController") as! MyProfileRecordVoiceViewController
            destination.submitHandler = { [weak self] voiceUrl in
                guard let wself = self else { return }
                _app.profileViewModel.model?.voiceUrl = voiceUrl
                wself.submitButton.isHidden = false
                
            }
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: 448.5)
            })
            destination.recordButtonStatus = _app.profileViewModel.model?.voiceUrl == nil ? .record : .play
            destination.popupType = .MyProfile
            return (destination, style)
        })
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(assetIdentifier: .Back), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ProfileViewController.actionBack(_:)))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.perform(#selector(self.updateCurrentLocation), with: nil, afterDelay: 0.5)
    }
    
    @objc func updateCurrentLocation() {
        if CLLocationManager.authorizationStatus() != .restricted &&
            CLLocationManager.authorizationStatus() != .denied  {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        getSettingInfo(lat: locValue.latitude, lng: locValue.longitude)
        locationManager.stopUpdatingLocation()
    }

    func getSettingInfo(lat: Double, lng: Double) {
        let settingInfoModel = ApiResponseViewModelBuilder<SettingInfoModel>(errorHandler: { [weak self] (statusCode, serverError) -> Void in
            
        }) { [weak self] (model) -> Void in
            guard let _ = self else { return }
            
            _app.sessionViewModel.settingInfoModel = model
            _app.sessionViewModel.settingInfoModel.lat = String(lat)
            _app.sessionViewModel.settingInfoModel.lng = String(lng)
            }.viewModel
        let _ = _app.api.requestGetSettingInfo(apiResponseViewModel: settingInfoModel, loadingViewModel: nil)
    }
    
    func excuteUpdateSettingInfo() {
        let settingInfoModel = ApiResponseViewModelBuilder<SettingInfoModel>(errorHandler: nil) {
            [weak self] (model) -> Void in
            }.viewModel
        let _ = _app.api.requestUpdateSetting(apiResponseViewModel: settingInfoModel, loadingViewModel: nil)
    }

    
    override func didMove(toParentViewController parent: UIViewController?) {
        if parent == nil {
            print("back pressed")
        }
    }

    @objc func actionBack(_ sender: UIBarButtonItem) {
        if submitButton.isHidden {
            self.navigationController?.popViewController(animated: true)
        }else {
//            KMPopupView().show("", message: "작성 중인 프로필 사항이 있습니다. 변경없이 나가시겠습니까?", otherButtonTitle: "취소", okButtonTitle: "확인", otherButtonAction: nil, confirmAction: {
//                self?.navigationController?.popViewControllerAnimated(true)
//            })
            
            KMPopupView().show(title: nil,
                               message: "변경사항이 저장되지 않았습니다.\n정말 나가시겠습니까?",
                               otherButtonTitle: "취소",
                               okButtonTitle: "확인",
                               otherButtonAction: nil,
                               confirmAction: {text in
                                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    deinit {
        print(#function, "\(self)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _app.ga.trackingViewName(viewName: .profile)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ProfileViewController: ApiReloadable {
    func reloadApi() {
        let responseViewModel = ApiResponseViewModelBuilder<ProfileModel>(successHandlerWithDefaultError: { (profileModel) -> Void in
            _app.profileViewModel.model = profileModel
            _app.setCopyProfileCodes()
            
            for childVC in self.childViewControllers {
                if let tableVC = childVC as? ProfileTableViewController{
                    tableVC.tableView.reloadData()
                }
            }

        }).viewModel
        let _ = _app.api.profileEdit(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
    }
}
