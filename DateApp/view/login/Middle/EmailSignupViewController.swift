//
//  EmailSignupViewController.swift
//  DateApp
//
//  Created by Lim Daehyun on 2018. 2. 11..
//  Copyright © 2018년 iflet.com. All rights reserved.
//

import UIKit
import Foundation
class EmailSignupViewController: VerifyViewController {
    
    private var serviceRuleSegue: DSegue!
    private var privacySegue: DSegue!
    private var locationSegue: DSegue!
    
    override func loadView() {
        super.loadView()
        isUseHeaderView = false
    }
    
    override func viewDidLoad() {
        AdBrix.firstTimeExperience("이멜] 추천인코드 입력")
        
        super.viewDidLoad()
        setViewModel()
        adjustUIViews()
        setBottomButtonInfo()
        addCustomSegue()
        testCode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func pressedBottomButton() {
        hideKeyboard()
        guard let email = verifyViewModel.getItem(item: .email)?.content else {
            alert(message: "이메일 주소를 입력해주세요.")
            return
        }
        
        guard email.isEmail else {
            alert(message: "정상적인 이메일 주소가 아닙니다.")
            return
        }
        
        guard let password = verifyViewModel.getItem(item: .password)?.content , password.length > 0 else {
            alert(message: "비밀번호를 입력해주세요.")
            return
        }
        
        guard password.length >= 4 else {
            alert(message: "비밀번호는 4자리 이상입니다.")
            return
        }
        
        guard password == verifyViewModel.getItem(item: .repassword)?.content else {
            alert(message: "확인해주신 비밀번호가 일치하지 앖습니다.")
            return
        }
        
        guard let chosenGender = verifyViewModel.getItem(item: .selectGender)?.content else {
            alert(message: "성별을 선택해 주세요.")
            return
        }
        
        var recommendId: String?
        if let r = (verifyViewModel as! EmailSignupViewModel).getItem(item: .recommendId)?.content {
            recommendId = r
            
            verifyViewModel.requestCheckRecommendCode(r, complete: { [weak self] isSuccess in
                guard let wself = self else { return }
                if isSuccess {
                    wself.executeSignup(email: email, chosenGender: chosenGender, password: password, recommendId: recommendId)
                }else {
                    let _ = wself.verifyViewModel.updateContentWithIndex(index: 4, content: "")
                    wself.colletionView.reloadData()
                }
                })
        }else {
            executeSignup(email: email, chosenGender: chosenGender, password: password, recommendId: recommendId)
        }
    }
    
    fileprivate func executeSignup(email: String, chosenGender: String, password: String, recommendId: String?) {
        let vc = VerifyCodeViewController()
        vc.onProcessSignup = {[weak self] (phone, code) in
            guard let wself = self else { return }
            
            let message = "\(email) / \(chosenGender)"
            confirm(title: "가입 하시겠습니까?", message: message) { [weak self] (action) -> Void in
                
                guard let weakSelf = self else {
                    return
                }
                
                let indi = ActivityIndicatorViewBuilder(centerAtView: weakSelf.view, style: UIActivityIndicatorViewStyle.gray).indicatorView
                let loadingViewModel = DViewModel<LoadingModel>(LoadingModel(), self, { (model, oldModel) -> () in
                    if model?.loading == true {
                        indi.startAnimating()
                    } else {
                        indi.stopAnimating()
                    }
                })
                
                (wself.verifyViewModel as! EmailSignupViewModel).signup(email: email, password: password, chosenGenderCode: chosenGender, recommend: recommendId, phone: phone, code: code, loadingViewModel: loadingViewModel)
            }
        }
        
        navigationController?.pushViewController(vc, animated: false)
    }

    func setBottomButtonInfo() {
        let labelStyle = LabelStyle(font: UIFont.systemFont(ofSize: 15), normalColor: UIColor.white, highlightColor: nil)
        bottomButtonInfo = BottomButtonInfo(bgColor: UIColor(r:242, g:80, b:59), title: "다음", titleStyle: labelStyle)
    }
    
    func adjustUIViews() {
        view.backgroundColor = UIColor.white
        headerView.isHidden = true
        
        collectionHeaderViewHeight = 155
        collectionFooterViewHeight = 95
        let screenHeight = UIScreen.main.bounds.size.height
        let headerAndItemTotalHeight = collectionHeaderViewHeight + CGFloat(verifyViewModel.verifyItems.count) * cellItemHeight
        if screenHeight - headerAndItemTotalHeight - 64 > collectionFooterViewHeight {
            collectionFooterViewHeight = screenHeight - headerAndItemTotalHeight - 64
        }
    }
    
    func addCustomSegue() {
        serviceRuleSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Login", identifier: "ServiceRuleViewController")
            (destination as! ServiceRuleViewController).titleString = "서비스 이용약관"
            (destination as! ServiceRuleViewController).linkUrl = _app.config.serviceRuleUrl
            let style = DSegueStyle.Show(animated: false)
            return (destination, style)
        })
        
        privacySegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Login", identifier: "PrivacyRuleViewController")
            let style = DSegueStyle.Show(animated: false)
            return (destination, style)
        })
        
        locationSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Login", identifier: "ServiceRuleViewController")
            (destination as! ServiceRuleViewController).titleString = "위치기반 서비스"
            (destination as! ServiceRuleViewController).linkUrl = _app.config.locationRuleUrl
            let style = DSegueStyle.Show(animated: false)
            return (destination, style)
            
        })
    }
    
    func testCode() {
        
    }
    
    func setViewModel() {
        verifyViewModel = EmailSignupViewModel()
        
        let items = [VerifyItem(type: .normal, item: .email, title: "이메일 주소 (비밀번호 분실시 이용)", placeHolderText: nil, content: nil, warnMessage: nil),
                     VerifyItem(type: .secure, item: .password, title: "비밀번호", placeHolderText: nil, content: nil, warnMessage: nil),
                     VerifyItem(type: .secure, item: .repassword, title: "비밀번호 확인", placeHolderText: nil, content: nil, warnMessage: nil),
                     VerifyItem(type: .normal, item: .selectGender, title: nil, placeHolderText: nil, content: nil, warnMessage: nil),
                     VerifyItem(type: .normal, item: .recommendId, title: "추천인 ID 코드", placeHolderText: "선택사항", content: nil, warnMessage: nil)]
        verifyViewModel.verifyItems = items
    }
    
    @objc func onPressedServiceRule() {
        serviceRuleSegue.perform()
    }
    
    @objc func onPressedPrivacyRule() {
        privacySegue.perform()
    }
    
    @objc func onPressedLocationRule() {
        locationSegue.perform()
    }
}

extension EmailSignupViewController {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionFooterViewHeight)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width - 140, height: 75)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let reuseableView = super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        switch reuseableView {
        case is VerifyViewHeader:
            (reuseableView as! VerifyViewHeader).image = UIImage(named: "login_ico_bird")
        case is VerifyViewFooter:
            let attrs = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14.0), NSAttributedStringKey.foregroundColor : UIColor(rgba: "#726763")]
            let str1 = "회원가입과 동시에 "
            let str2 = "서비스이용약관"
            let str3 = "과 "
            let str4 = "개인정보이용방침"
            let str5 = " 및"
            let str6 = "위치 기반 서비스"
            let str7 = " 에 동의하시게 됩니다."
            
            let attributedString = NSMutableAttributedString(string:"\(str1)\(str2)\(str3)", attributes:attrs)
            attributedString.addAttribute(NSAttributedStringKey.underlineStyle, value: 1, range: NSMakeRange(str1.length, str2.length))
            
            let attributedString2 = NSMutableAttributedString(string:"\(str4)\(str5)", attributes:attrs)
            attributedString2.addAttribute(NSAttributedStringKey.underlineStyle, value: 1, range: NSMakeRange(0, str4.length))
            
            let attributedString3 = NSMutableAttributedString(string:"\(str6)\(str7)", attributes:attrs)
            attributedString3.addAttribute(NSAttributedStringKey.underlineStyle, value: 1, range: NSMakeRange(0, str6.length))
            
            
            let rule1Filter = (reuseableView as! VerifyViewFooter).subviews.filter { $0.tag == 1 }
            if let rule1Button = rule1Filter.first as? UIButton {
                rule1Button.setAttributedTitle(attributedString, for: UIControlState.normal)
            }else {
                let button = UIButton()
                button.addTarget(self, action: #selector(self.onPressedServiceRule), for: UIControlEvents.touchUpInside)
                button.tag = 1
                button.titleLabel?.textAlignment = .center
                button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
                reuseableView.addSubview(button)
                button.snp.makeConstraints { (make) in
                    make.height.equalTo(20)
                    make.width.equalTo(300)
                    make.centerX.equalTo(reuseableView)
                    make.bottom.equalTo(-66)
                }
                button.setAttributedTitle(attributedString, for: UIControlState.normal)
            }
            
            let rule2Filter = (reuseableView as! VerifyViewFooter).subviews.filter { $0.tag == 2 }
            if let rule2Button = rule2Filter.first as? UIButton  {
                rule2Button.setAttributedTitle(attributedString2, for: UIControlState.normal)
            }else {
                let button = UIButton()
                button.addTarget(self, action: #selector(self.onPressedPrivacyRule), for: UIControlEvents.touchUpInside)
                button.tag = 2
                button.titleLabel?.textAlignment = .center
                button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
                reuseableView.addSubview(button)
                button.snp.makeConstraints { (make) in
                    make.height.equalTo(20)
                    make.width.equalTo(300)
                    make.centerX.equalTo(reuseableView)
                    make.bottom.equalTo(-46)
                }
                button.setAttributedTitle(attributedString2, for: UIControlState.normal)
            }
            
            let rule3Filter = (reuseableView as! VerifyViewFooter).subviews.filter { $0.tag == 3 }
            if let rule3Button = rule3Filter.first as? UIButton  {
                rule3Button.setAttributedTitle(attributedString3, for: UIControlState.normal)
            }else {
                let button = UIButton()
                button.addTarget(self, action: #selector(self.onPressedLocationRule), for: UIControlEvents.touchUpInside)
                button.tag = 3
                button.titleLabel?.textAlignment = .center
                button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
                reuseableView.addSubview(button)
                button.snp.makeConstraints { (make) in
                    make.height.equalTo(20)
                    make.width.equalTo(300)
                    make.centerX.equalTo(reuseableView)
                    make.bottom.equalTo(-26)
                }
                button.setAttributedTitle(attributedString3, for: UIControlState.normal)
            }
        default:()
        }
        return reuseableView
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
        if cell is VerifyCell {
            (cell as! VerifyCell).rightButtonImage(image: nil)
        }
        return cell
    }
}
