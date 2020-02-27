//
//  InviteFriendsViewController.swift
//  DateApp
//
//  Created by ryan on 12/16/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit
import AddressBook

@available(iOS, deprecated: 9.0)
class InviteFriendsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inviteButton: UIButton!
    
    // 초대하고 버찌 받기
    @IBAction func invite(sender: AnyObject) {
        if addressesViewModel.requiredSelectedFriendsOk == true {
            let phoneNumbers = addressesViewModel.selectedFormattedPhoneNumbers
            let responseViewModel = ApiResponseViewModelBuilder<PointValueModel>(successHandlerWithDefaultError: { (pointValueModel) -> Void in
                // member 정보 갱신해서 point 변화 적용
                alert(message: "성공하였습니다. 버찌충전을 확인하세요") { (action) -> Void in
                    self.navigationController?.popViewController(animated: true)
                }
                _app.sessionViewModel.reloadMemberInfo()
            }).viewModel
            let _ = _app.api.pointSmsInvite(phoneNumberList: phoneNumbers, apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
        } else {
            alert(message: "\(addressesViewModel.requiredSelectedFriendsCount)명 이상의 친구를 선택해주세요.")
        }
    }
    
    private var addressesViewModel = SelectableAddressesViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: .zero)   // 내용없는 셀 표시 안함
        
        // navigation
        navigationItem.title = "버찌 무료받기"
        
        addressesViewModel.bind (view: self) { [weak self] (model, oldModel) -> () in
            self?.tableView.reloadData()
            
            // 10명이상 선택했으면 버튼 스타일 변경
            if self?.addressesViewModel.requiredSelectedFriendsOk == true {
                self?.inviteButton.backgroundColor = UIColor(rgba: "#f2503b")
                self?.inviteButton.setTitleColor(UIColor.white, for: UIControlState.normal)
            } else {
                self?.inviteButton.backgroundColor = UIColor(rgba: "#e3e1e0")
                self?.inviteButton.setTitleColor(UIColor(rgba: "#726763"), for: UIControlState.normal)
            }
        }
        
        reloadAddressBook()
        
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
        _app.ga.trackingViewName(viewName: .contact)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension InviteFriendsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 79.0
        case 1:
            return 50.0
        default:
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            if let selectedModel = addressesViewModel.model?[indexPath.row] {
                // model 갱신
                addressesViewModel.model?[indexPath.row].selected = !selectedModel.selected
            }
        default:
            break
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return addressesViewModel.model?.count ?? 0
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell")!
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InviteFriendCell") as! InviteFriendCell
            if let addresses = addressesViewModel.model {
                let address = addresses[indexPath.row]
                cell.model = address
            }
            return cell
        default:
            fatalError()
        }
    }
}

// address 관련
@available(iOS, deprecated: 9.0)
extension InviteFriendsViewController {
    
    private func reloadAddressBook() {
        
        switch ABAddressBookGetAuthorizationStatus() {
        case .denied, .restricted:
            alert(message: "환경설정으로 가서 주소록 허용을 해주세요.") { (UIAlertAction) -> Void in
                _app.delegate.openPrivacySetup()
            }
        case .notDetermined:
            
            var error: Unmanaged<CFError>?
            let addressBook = ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue()
            ABAddressBookRequestAccessWithCompletion(addressBook) { (granted, error) -> Void in
                if !granted {
                    alert(message: "권한이 없습니다. 환경설정으로 가서 주소록 허용을 해주세요.") { (UIAlertAction) -> Void in
                        _app.delegate.openPrivacySetup()
                    }
                } else {
                    self.fillAddress(addressBook: addressBook)
                }
            }
        case .authorized:
            
            var error: Unmanaged<CFError>?
            let addressBook = ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue()
            fillAddress(addressBook: addressBook)
            
        default:()
        }
        
    }
    
    private func fillAddress(addressBook: ABAddressBook) {
        
        var addresses = [SelectableAddressModel]()
        
        let people = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as [ABRecord]
        for person: ABRecord in people {
            
            guard let name = ABRecordCopyCompositeName(person)?.takeRetainedValue() as String? else {
                continue
            }
            
            guard let multiPhoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty)?.takeRetainedValue() else {
                continue
            }
            
            if 0 < ABMultiValueGetCount(multiPhoneNumbers) {
                let phoneNumber = ABMultiValueCopyValueAtIndex(multiPhoneNumbers, 0)?.takeRetainedValue() as? String ?? ""
                let addressModel = SelectableAddressModel(name: name, phoneNumber: phoneNumber)
                // valid 객체 있는것만 추가
                if addressModel.validAddressModel != nil {
                    addresses.append(addressModel)
                }
            }
        }
        addressesViewModel.model = addresses
    }
}


