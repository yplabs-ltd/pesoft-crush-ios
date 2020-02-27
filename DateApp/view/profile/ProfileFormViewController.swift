//
//  ProfileFormViewController.swift
//  DateApp
//
//  Created by ryan on 12/15/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit

final class ProfileFormViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private var introducePopupSegue: DSegue!
    private var birthPopupSegue: DSegue! // 출생년도
    private var hometownPopupSegue: DSegue! // 지역
    private var jobPopupSegue: DSegue!      // 직장
    private var bodytypePopupSegue: DSegue! // 체형
    private var heightPopupSegue: DSegue!   // 키
    private var bloodPopupSegue: DSegue!    // 형액형
    private var religionPopSegue: DSegue!   // 종교
    let cellForCheckSize = NowNearKeywordTableViewCell()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)   // 내용없는 셀 표시 안함
        
        adjustTableViewHeight()
        
        // segue
        
        introducePopupSegue = DSegue(source: self) { () -> (destination: UIViewController, style: DSegueStyle)? in
            // 이상형을 남기기위한 입력 popup
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "Select1PopupController") as! Select1PopupController
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: parentSize.height * 0.7)
            })
            destination.selectType = SelectType.IdealType
            destination.title = "이런 사람이 좋아요"
            
            // 서버에서 준 코드들 확인 후 목록 추출
            if let profileCodeInfo = _app.profileCodeInfo {
                if _app.sessionViewModel.model?.gender == "M" {
                    destination.itemsViewModel.model = profileCodeInfo.idealMTypeCode.selectItemModels
                } else if _app.sessionViewModel.model?.gender == "F" {
                    destination.itemsViewModel.model = profileCodeInfo.idealFTypeCode.selectItemModels
                }
            }
            
            destination.submitHandler = { (popup) -> () in
                if let code = popup.selected?.name, let value = popup.selected?.value {
                    // viewmodel 갱신
                    _app.profileViewModel.model?.idealType = CodeValueModel(code: code, value: value)
                    _app.profileSubmitButtonShowViewModel.model = true
                }
                popup.dismiss(animated: true, completion: nil)
            }
            return (destination,style)
        }
        
        birthPopupSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "Select1PopupController") as! Select1PopupController
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: parentSize.height * 0.7)
            })
            destination.selectType = SelectType.Birthdate
            // 태어난 해 선택
            destination.title = "출생년도"
            
            // 올해 년도
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy"
            let year = Int(formatter.string(from: Date()))
            let startYear: Int = 1975
            let endYear: Int = 2001
            var yearItems:[SelectItemModel] = []
            for y in startYear ..< endYear {
                let item = SelectItemModel(name: "\(y)", value: "\(y)", children: nil)
                yearItems.append(item)
            }
            destination.itemsViewModel.model = yearItems
            destination.startRowIndex = 10
            destination.submitHandler = { (popup) -> () in
                if let selected = popup.selected?.value {
                    // viewmodel 갱신
                    _app.profileViewModel.model?.birthDate = "\(selected)-01-01"    // YYYY-MM-DD
                    _app.profileSubmitButtonShowViewModel.model = true
                }
                popup.dismiss(animated:true, completion: nil)
            }
            return (destination, style)
        })
        
        hometownPopupSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "Select1PopupController") as! Select1PopupController
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: parentSize.height * 0.7)
            })
            destination.selectType = SelectType.Location
            destination.title = "지역"
            // 서버에서 준 코드들 확인 후 목록 추출
            if let profileCodeInfo = _app.profileCodeInfo {
                destination.itemsViewModel.model = profileCodeInfo.hometownCode.selectItemModels
            }
            
            destination.submitHandler = { (popup) -> () in
                if let code = popup.selected?.name, let value = popup.selected?.value {
                    // viewmodel 갱신
                    _app.profileViewModel.model?.hometown = CodeValueModel(code: code, value: value)
                    _app.profileSubmitButtonShowViewModel.model = true
                }
                popup.dismiss(animated:true, completion: nil)
            }
            
            return (destination, style)
        })
        
        jobPopupSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "Select1PopupController") as! Select1PopupController
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: parentSize.height * 0.7)
            })
            
            destination.title = "직업"
            destination.selectType = SelectType.Job
            // 서버에서 준 코드들 확인 후 목록 추출
            if let profileCodeInfo = _app.profileCodeInfo {
                destination.itemsViewModel.model = profileCodeInfo.jobCode.selectItemModelsFor2Depth
            }
            destination.submitHandler = { (popup) -> () in
                if let selected = popup.selected, let jobTitle = selected.extra {
                    // viewmodel 갱신
                    _app.profileViewModel.model?.job = CodeValueModel(code: selected.name, value: "\(jobTitle) \(selected.value)")
                    _app.profileSubmitButtonShowViewModel.model = true
                }
                popup.dismiss(animated:true, completion: nil)
            }
            return (destination,style)
        })
        
        bodytypePopupSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "Select1PopupController") as! Select1PopupController
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: parentSize.height * 0.7)
            })
            
            destination.title = "체형"
            destination.selectType = SelectType.bodyShape
            // 서버에서 준 코드들 확인 후 목록 추출
            if let profileCodeInfo = _app.profileCodeInfo {
                if _app.sessionViewModel.model?.gender == "M" {
                    destination.itemsViewModel.model = profileCodeInfo.bodyMTypeCode.selectItemModels
                } else if _app.sessionViewModel.model?.gender == "F" {
                    destination.itemsViewModel.model = profileCodeInfo.bodyFTypeCode.selectItemModels
                }
            }
            
            destination.submitHandler = { (popup) -> () in
                if let code = popup.selected?.name, let value = popup.selected?.value {
                    // viewmodel 갱신
                    _app.profileViewModel.model?.bodyType = CodeValueModel(code: code, value: value)
                    _app.profileSubmitButtonShowViewModel.model = true
                }
                popup.dismiss(animated:true, completion: nil)
            }
            return (destination,style)
        })
        
        heightPopupSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "Select1PopupController") as! Select1PopupController
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: parentSize.height * 0.7)
            })
            
            destination.title = "키"
            destination.selectType = SelectType.Height
            var heightItems:[SelectItemModel] = []
            for height in 140 ..< 200 {
                let item = SelectItemModel(name: "\(height)", value: "\(height)", children: nil)
                heightItems.append(item)
            }
            destination.itemsViewModel.model = heightItems
            
            // 기본 키 스크롤
            if _app.sessionViewModel.model?.gender == "M" {
                destination.startRowIndex = 30      // 남자는 기본 173
            } else if _app.sessionViewModel.model?.gender == "F" {
                destination.startRowIndex = 20      // 여자는 기본 163
            }
            
            destination.submitHandler = { (popup) -> () in
                if let selected = popup.selected?.value {
                    // viewmodel 갱신
                    _app.profileViewModel.model?.height = (selected as NSString).floatValue
                    _app.profileSubmitButtonShowViewModel.model = true
                }
                popup.dismiss(animated:true, completion: nil)
            }
            return (destination, style)
        })
        
        
        bloodPopupSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "Select1PopupController") as! Select1PopupController
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: parentSize.height * 0.7)
            })
            
            destination.title = "혈액형"
            destination.selectType = SelectType.BloodType
            // 서버에서 준 코드들 확인 후 목록 추출
            if let profileCodeInfo = _app.profileCodeInfo {
                destination.itemsViewModel.model = profileCodeInfo.bloodTypeCode.selectItemModels
            }
            
            destination.submitHandler = { (popup) -> () in
                if let code = popup.selected?.name, let value = popup.selected?.value {
                    // viewmodel 갱신
                    _app.profileViewModel.model?.bloodType = CodeValueModel(code: code, value: value)
                    _app.profileSubmitButtonShowViewModel.model = true
                }
                popup.dismiss(animated:true, completion: nil)
            }
            
            return (destination, style)
        })
        
        religionPopSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "Select1PopupController") as! Select1PopupController
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: parentSize.height * 0.7)
            })
            
            destination.title = "종교"
            destination.selectType = SelectType.Religion
            // 서버에서 준 코드들 확인 후 목록 추출
            if let profileCodeInfo = _app.profileCodeInfo {
                destination.itemsViewModel.model = profileCodeInfo.religionCode.selectItemModels
            }
            
            destination.submitHandler = { (popup) -> () in
                if let code = popup.selected?.name, let value = popup.selected?.value {
                    // viewmodel 갱신
                    _app.profileViewModel.model?.religion = CodeValueModel(code: code, value: value)
                    _app.profileSubmitButtonShowViewModel.model = true
                }
                popup.dismiss(animated:true, completion: nil)
            }
            
            return (destination, style)
        })
        
        // viewmodel bind
        
        _app.profileViewModel.bind (view: self) { [weak self] (model, oldModel) -> () in
            self?.tableView.reloadData()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        adjustTableViewHeight()
    }

    func adjustTableViewHeight() {
        let tableViewContentSize = self.tableView.contentSize
        
        var tableViewFrame = self.tableView.frame
        tableViewFrame.size.height = tableViewContentSize.height
        
        self.tableView.frame = tableViewFrame
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

extension ProfileFormViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            introducePopupSegue.perform()
        case 1:
            KMPopupView().show(title: "닉네임 변경",
                               enableTextView: true,
                               message: _app.profileViewModel.model?.name?.trim(),
                               otherButtonTitle: "취소",
                               okButtonTitle: "확인",
                               otherButtonAction:{
                                let id = _app.userDefault.noticeID
                                _app.userDefault.checkedNoticeID = id},
                               confirmAction: { (text) -> () in
                                if 10 < text.length {
                                    Toast.showToast(message: "닉네임은 10자로 제한됩니다")
                                    let t = text as NSString
                                    _app.profileViewModel.model?.name = t.substring(with: NSRange(location: 0, length: 10)) as String
                                    _app.profileSubmitButtonShowViewModel.model = true
                                } else {
                                    _app.profileViewModel.model?.name = text
                                    _app.profileSubmitButtonShowViewModel.model = true
                                }
            })
            
            /*
            let alert = AlertControllerBuilder(title: "닉네임", message: nil, textFieldPlaceholder: nil, defaultText: _app.profileViewModel.model?.name){ (text) -> () in
                guard let text = text else {
                    return
                }
                if 10 < text.length {
                    _app.rootViewController?.view.makeToast(message: "닉네임은 10자로 제한됩니다")
                    let range = text.startIndex.advancedBy(0)..<text.startIndex.advancedBy(10)
                    _app.profileViewModel.model?.name = text.substringWithRange(range)
                    _app.profileSubmitButtonShowViewModel.model = true
                } else {
                    _app.profileViewModel.model?.name = text
                    _app.profileSubmitButtonShowViewModel.model = true
                }
            }.alertController
            presentViewController(alert, animated: true, completion: nil) */
        case 2:
            // 출생년도
            birthPopupSegue.perform()
            break
        case 3:
            // 지역
            hometownPopupSegue.perform()
        case 4:
            jobPopupSegue.perform()
        case 5:
            bodytypePopupSegue.perform()
        case 6:
            heightPopupSegue.perform()
        case 7:
            bloodPopupSegue.perform()
        case 8:
            religionPopSegue.perform()
        case 9:
            /*
            let alert = AlertControllerBuilder(title: "학교", message: nil, textFieldPlaceholder: "숭실대학교, 연세대학교, 고려대학교", defaultText: _app.profileViewModel.model?.school){ (text) -> () in
                _app.profileViewModel.model?.school = text
                _app.profileSubmitButtonShowViewModel.model = true
                }.alertController
            presentViewController(alert, animated: true, completion: nil)
            */
            
            
            KMPopupView().show(title: "학교 입력",
                               enableTextView: true,
                               message: _app.profileViewModel.model?.school?.trim(),
                               otherButtonTitle: "취소",
                               okButtonTitle: "확인",
                               otherButtonAction: {
                                let id = _app.userDefault.noticeID
                                _app.userDefault.checkedNoticeID = id},
                               confirmAction: { (text) -> () in
                                _app.profileViewModel.model?.school = text
                                _app.profileSubmitButtonShowViewModel.model = true})
            
        
        default:
            break
        }
    }
}

extension ProfileFormViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10 + 3 // 10 개 항목 받을거임
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 74
        if indexPath.row == 10 {
            height = cellForCheckSize.getViewHeight( _app.profileViewModel.getProfileKeywordList(type: .HobbyType), isFold: true) + 20
        }
        
        if indexPath.row == 11 {
            height = cellForCheckSize.getViewHeight( _app.profileViewModel.getProfileKeywordList(type: .CharmingType), isFold: true)
        }
        
        if indexPath.row == 12 {
            height = cellForCheckSize.getViewHeight( _app.profileViewModel.getProfileKeywordList(type: .FavoriteType), isFold: true)
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? ProfileInputFieldCell {
                cell.initializeFieldTitle(title: "이런 사람이 좋아요", placeholder: "입력해주세요")
                if let idealType = _app.profileViewModel.model?.idealType?.value {
                    
                    let lineRemoved = idealType.replacingOccurrences(of: "\n", with: "")
                    cell.data = lineRemoved
                } else {
                    cell.data = ""
                }
                return cell
            }
        case 1:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? ProfileInputFieldCell {
                cell.initializeFieldTitle(title: "닉네임", placeholder: "입력해주세요")
                cell.data = _app.profileViewModel.model?.name ?? ""
                return cell
            }
        case 2:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? ProfileInputFieldCell {
                cell.initializeFieldTitle(title: "나이", placeholder: "입력해주세요")
                cell.data = _app.profileViewModel.model?.birthDate?.ageFromBirthDate ?? ""
                return cell
            }
        case 3:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? ProfileInputFieldCell {
                cell.initializeFieldTitle(title: "지역", placeholder: "입력해주세요")
                cell.data = _app.profileViewModel.model?.hometown?.value ?? ""
                return cell
            }
        case 4:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? ProfileInputFieldCell {
                cell.initializeFieldTitle(title: "직업", placeholder: "입력해주세요")
                cell.data = _app.profileViewModel.model?.job?.value ?? ""
                return cell
            }
        case 5:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? ProfileInputFieldCell {
                cell.initializeFieldTitle(title: "체형", placeholder: "입력해주세요")
                cell.data = _app.profileViewModel.model?.bodyType?.value ?? ""
                return cell
            }
        case 6:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? ProfileInputFieldCell {
                cell.initializeFieldTitle(title: "키", placeholder: "입력해주세요")
                if let height = _app.profileViewModel.model?.height {
                    cell.data = "\(height)"
                } else {
                    cell.data = ""
                }
                return cell
            }
        case 7:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? ProfileInputFieldCell {
                cell.initializeFieldTitle(title: "혈액형", placeholder: "입력해주세요")
                cell.data = _app.profileViewModel.model?.bloodType?.value ?? ""
                return cell
            }
        case 8:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? ProfileInputFieldCell {
                cell.initializeFieldTitle(title: "종교", placeholder: "입력해주세요")
                cell.data = _app.profileViewModel.model?.religion?.value ?? ""
                return cell
            }
        case 9:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? ProfileInputFieldCell {
                cell.initializeFieldTitle(title: "학교", placeholder: "선택사항")
                cell.data = _app.profileViewModel.model?.school ?? ""
                return cell
            }
        case 10:
            if let cellData = _app.profileViewModel.getProfileKeywordList(type: .HobbyType) {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "keywordCell") as? NowNearKeywordTableViewCell {
                    cell.updateKeyword = {
                        [weak self] in
                        if let wself = self {
                            wself.tableView.reloadData()
                        }
                    }
                    cell.yCoord = 20
                    cell.configure(dataList: cellData, type: ProfileKeywordType.HobbyType)
                    return cell
                }
            }
        case 11:
            if let cellData = _app.profileViewModel.getProfileKeywordList(type: .CharmingType) {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "keywordCell") as? NowNearKeywordTableViewCell {
                    cell.updateKeyword = {
                        [weak self] in
                        if let wself = self {
                            wself.tableView.reloadData()
                        }
                    }
                    cell.yCoord = 0
                    cell.configure(dataList: cellData, type: ProfileKeywordType.CharmingType)
                    return cell
                }
            }
        case 12:
            if let cellData = _app.profileViewModel.getProfileKeywordList(type: .FavoriteType) {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "keywordCell") as? NowNearKeywordTableViewCell {
                    cell.updateKeyword = {
                        [weak self] in
                        if let wself = self {
                            wself.tableView.reloadData()
                        }
                    }
                    cell.yCoord = -10
                    cell.configure(dataList: cellData, type: ProfileKeywordType.FavoriteType)
                    return cell
                }
            }
        default:
            break
        }
        
        return UITableViewCell()
    }
}


