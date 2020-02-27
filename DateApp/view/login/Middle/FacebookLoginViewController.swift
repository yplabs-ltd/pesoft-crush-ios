//
//  FacebookLoginViewController.swift
//  DateApp
//
//  Created by Lim Daehyun on 2018. 2. 10..
//  Copyright © 2018년 iflet.com. All rights reserved.
//
import UIKit
import Foundation
class FacebookLoginViewController: VerifyViewController {
    
    private var serviceRuleSegue: DSegue!
    private var privacySegue: DSegue!
    private var locationSegue: DSegue!
    
    override func loadView() {
        super.loadView()
        isUseHeaderView = false
        setViewModel()
    }
    
    override func viewDidLoad() {
        AdBrix.firstTimeExperience("페북] 추천인코드 입력")
        
        super.viewDidLoad()
        
        adjustUIViews()
        setBottomButtonInfo()
        addCustomSegue()
        testCode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setViewModel()
        tryFacebookLogin()
    }
    
    
    override func pressedBottomButton() {
        hideKeyboard()
        guard let g = verifyViewModel.getItem(item: .selectGender)?.content else {
            alert(message: "성별을 선택해 주세요.")
            return
        }
        
        guard let _ = (verifyViewModel as! FacebookLoginViewModel).fbToken else {
            tryFacebookLogin()
            return
        }
        
        var recommendId: String?
        if let r = (verifyViewModel as! FacebookLoginViewModel).getItem(item: .recommendId)?.content {
            recommendId = r
            verifyViewModel.requestCheckRecommendCode(r, complete: { [weak self] isSuccess in
                guard let wself = self else { return }
                if isSuccess {
                    wself.executeSignup(recommendId: recommendId, genderCode: g)
                }else {
                    print("")
                    let _ = wself.verifyViewModel.updateContentWithIndex(index: 1, content: "")
                    wself.colletionView.reloadData()
                }})
        }else {
            executeSignup(recommendId: recommendId, genderCode: g)
        }
    }
    
    fileprivate func executeSignup(recommendId: String?, genderCode: String) {
        let indi = ActivityIndicatorViewBuilder(centerAtView: view, style: UIActivityIndicatorViewStyle.gray).indicatorView
        let loadingViewModel = DViewModel<LoadingModel>(LoadingModel(), self, { (model, oldModel) -> () in
            if model?.loading == true {
                indi.startAnimating()
            } else {
                indi.stopAnimating()
            }
        })
        
        (verifyViewModel as! FacebookLoginViewModel).signupWithFacebook(recommendId: recommendId, genderCode: genderCode, onSuccess: { [weak self] in
            guard let wself = self else { return }
            }, onFailed: { [weak self] error in
                guard let wself = self else { return }
            }, loadingViewModel: loadingViewModel)
    }
    
    func tryFacebookLogin() {
        (verifyViewModel as! FacebookLoginViewModel).loginToFacebookWithSuccess(successBlock: { [weak self] in
            guard let _ = self else { return }
            
            
            }, andFailure: { [weak self] error in
                guard let _ = self else { return }
                alert(message: "페이스북 로그인에 실패하였습니다. 다시 시도해 주세요.")
            })
    }
    
    func setBottomButtonInfo() {
        let labelStyle = LabelStyle(font: UIFont.systemFont(ofSize: 15), normalColor: UIColor.white, highlightColor: nil)
        bottomButtonInfo = BottomButtonInfo(bgColor: UIColor(r:242, g:80, b:59), title: "지금 바로 만나기", titleStyle: labelStyle)
    }
    
    func adjustUIViews() {
        view.backgroundColor = UIColor.white
        headerView.isHidden = true
        
        collectionHeaderViewHeight = 155
        
        let screenHeight = UIScreen.main.bounds.size.height
        let headerAndItemTotalHeight = 44 + collectionHeaderViewHeight + CGFloat(verifyViewModel.verifyItems.count) * cellItemHeight
        collectionFooterViewHeight = max(collectionFooterViewHeight, screenHeight - headerAndItemTotalHeight)
    }
    
    func addCustomSegue() {
        serviceRuleSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Login", identifier: "ServiceRuleViewController")
            let style = DSegueStyle.Show(animated: false)
            return (destination, style)
        })
        
        privacySegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Login", identifier: "PrivacyRuleViewController")
            let style = DSegueStyle.Show(animated: false)
            return (destination, style)
        })
    }
    
    func testCode() {
        
    }
    
    func setViewModel() {
        verifyViewModel = FacebookLoginViewModel()
        
        let items = [VerifyItem(type: .normal, item: .selectGender, title: nil, placeHolderText: nil, content: nil, warnMessage: nil),
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

extension FacebookLoginViewController {
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
            
            
            
            let attrs = [
                NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14.0),
                NSAttributedStringKey.foregroundColor : UIColor(rgba: "#726763")]
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
            
            let descLabelFilter = (reuseableView as! VerifyViewFooter).subviews.filter { $0.tag == 3 }
            if let descLabel = descLabelFilter.first as? UILabel {
                descLabel.text = "SNS 계정 사용시 어떤 내용도 게시하거나 표시하지 않습니다."
            }else {
                let label = UILabel()
                label.tag = 3
                label.textColor = UIColor(r: 242, g: 80, b: 59)
                label.font = UIFont.systemFont(ofSize: 12)
                label.textAlignment = .center
                reuseableView.addSubview(label)
                label.snp.makeConstraints { (make) in
                    make.height.equalTo(20)
                    make.width.equalTo(300)
                    make.centerX.equalTo(reuseableView)
                    make.bottom.equalTo(-103)
                }
                label.text = "SNS 계정 사용시 어떤 내용도 게시하거나 표시하지 않습니다."
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
