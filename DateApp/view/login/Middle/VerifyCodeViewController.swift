//
//  VerifyCodeViewController.swift
//  DateApp
//
//  Created by Lim Daehyun on 2018. 2. 11..
//  Copyright © 2018년 iflet.com. All rights reserved.
//

import UIKit
import Foundation
class VerifyCodeViewController: VerifyViewController {
    
    private var serviceRuleSegue: DSegue!
    private var privacySegue: DSegue!
    
    var onProcessSignup: ((String, String) -> Void)?
    override func loadView() {
        super.loadView()
        isUseHeaderView = false
        setViewModel()
    }
    
    override func viewDidLoad() {
        AdBrix.firstTimeExperience("이멜] 휴대폰 인증")
        
        super.viewDidLoad()
        
        adjustUIViews()
        setBottomButtonInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setViewModel()
    }
    
    func setBottomButtonInfo() {
        bottomButtonInfo = nil
    }
    
    func adjustUIViews() {
        view.backgroundColor = UIColor.white
        headerView.isHidden = true
        
        collectionHeaderViewHeight = 155
        
        let screenHeight = UIScreen.main.bounds.size.height
        let headerAndItemTotalHeight = 44 + collectionHeaderViewHeight + CGFloat(verifyViewModel.verifyItems.count) * cellItemHeight
        collectionFooterViewHeight = max(collectionFooterViewHeight, screenHeight - headerAndItemTotalHeight)
    }
    
    func setViewModel() {
        verifyViewModel = VerifyCodeViewModel()
        
        let items = [VerifyItem(type: .normal, item: .mobile, title: "전화번호 입력 (중복 및 유령회원 방지)", placeHolderText: nil, content: nil, warnMessage: nil),
                     VerifyItem(type: .normal, item: .verifyCode, title: "인증번호 입력", placeHolderText: nil, content: nil, warnMessage: nil)]
        verifyViewModel.verifyItems = items
    }
    
    func onPressedServiceRule() {
        serviceRuleSegue.perform()
    }
    
    func onPressedPrivacyRule() {
        
    }
}

extension VerifyCodeViewController {
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 150)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width - 140, height: 75)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let reuseableView = super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        switch reuseableView {
        case is VerifyViewHeader:
            (reuseableView as! VerifyViewHeader).image = UIImage(named: "login_ico_bird")
        default:()
        }
        return reuseableView
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
        if cell is VerifyCell {
            (cell as! VerifyCell).onDidChangeText = { [weak self] text in
                guard let _ = self else { return }
                if text?.length == 10 && indexPath.row == 0 {
                    Toast.showToast(message: "우측의 화살표를 탭해주세요.", duration: 1.0)
                }
            }
            (cell as! VerifyCell).onPressedTextFieldRightButton = { [weak self] in
                guard let wself = self else { return }
                wself.hideKeyboard()
                guard wself.verifyViewModel.verifyItems.count > indexPath.row else {
                    return
                }
                guard let item = wself.verifyViewModel.verifyItems[indexPath.row].item else {
                    return
                }
                
                switch item {
                case .mobile:
                    guard let m = wself.verifyViewModel.getItem(item: item)?.content else {
                        alert(message: "핸드폰 번호를 입력해주세요.")
                        return
                    }
                    (wself.verifyViewModel as! VerifyCodeViewModel).requestSMSCode(phone: m, onSuccess: nil, onFailed: nil, loadingViewModel: nil)
                case .verifyCode:
                    guard let m = wself.verifyViewModel.getItem(item: .mobile)?.content else {
                        alert(message: "핸드폰 번호를 입력해주세요.")
                        return
                    }
                    
                    guard let c = wself.verifyViewModel.getItem(item: item)?.content else {
                        alert(message: "코드를 입력해주세요.")
                        return
                    }
                    (wself.verifyViewModel as! VerifyCodeViewModel).requestAuthCode(phone: m, code: c, onSuccess: { [weak self] in
                        guard let wself = self else { return }
                        wself.onProcessSignup?(m, c)
                        }, onFailed: nil, loadingViewModel: nil)
                default:()
                }
                
            }
            (cell as! VerifyCell).rightButtonImage(image: UIImage(named: "btnNextNormal"))
        }
        return cell
    }
}
