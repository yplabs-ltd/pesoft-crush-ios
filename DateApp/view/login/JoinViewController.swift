//
//  JoinViewController.swift
//  DateApp
//
//  Created by ryan on 12/26/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit

class JoinViewController: UITableViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    @IBOutlet weak var manButton: UIButton!
    @IBOutlet weak var womanButton: UIButton!
    @IBOutlet weak var rule1Button: UIButton!
    @IBOutlet weak var rule2Button: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    
    @IBAction func textFieldEditingDidBegin(sender: AnyObject) {
        guard let textField = sender as? UITextField else {
            return
        }
        activeBorderColorForView(view: textField)
    }
    
    @IBAction func textFieldEditingDidEnd(sender: AnyObject) {
        guard let textField = sender as? UITextField else {
            return
        }
        makeColorForTextField(textField: textField)
    }
     
    @IBAction func buttonTouchUpInside(sender: AnyObject) {
        guard let button = sender as? UIButton else {
            return
        }
        
        view.endEditing(true)
        
        switch button {
        case manButton:
            chosenGender = .Man
            manButton.setTitleColor(activeColor, for: UIControlState.normal)
            womanButton.setTitleColor(inactiveColor, for: UIControlState.normal)
            activeBorderColorForView(view: manButton)
            inactiveBorderColorForView(view: womanButton)
        case womanButton:
            chosenGender = .Woman
            manButton.setTitleColor(inactiveColor, for: UIControlState.normal)
            womanButton.setTitleColor(activeColor, for: UIControlState.normal)
            inactiveBorderColorForView(view: manButton)
            activeBorderColorForView(view: womanButton)
        default:
            break
        }
    }
    
    @IBAction func joinButtonTouchUpInside(sender: UIButton) {
        
        view.endEditing(true)
        
        guard let email = emailTextField.text , 0 < email.length else {
            alert(message: "이메일 주소를 입력해주세요.") { (action) -> Void in
                self.emailTextField.becomeFirstResponder()
            }
            return
        }
        
        guard email.isEmail == true else {
            alert(message: "정상적인 이메일 주소가 아닙니다.") { (action) -> Void in
                self.emailTextField.becomeFirstResponder()
            }
            return
        }
        
        guard let password = passwordTextField.text , 0 < password.length else {
            alert(message: "비밀번호를 입력해주세요.") { (action) -> Void in
                self.passwordTextField.becomeFirstResponder()
            }
            return
        }
        
        guard 4 <= password.length else {
            alert(message: "비밀번호는 4자리 이상입니다.", handler: { (action) -> Void in
                self.passwordTextField.text = ""
                self.passwordTextField.becomeFirstResponder()
            })
            return
        }
        
        guard password == passwordConfirmTextField.text else {
            alert(message: "확인해주신 비밀번호가 일치하지 앖습니다.") { (action) -> Void in
                self.passwordConfirmTextField.text = ""
                self.passwordConfirmTextField.becomeFirstResponder()
            }
            return
        }
        
        guard let chosenGenderCode = chosenGenderCode else {
            alert(message: "성별을 선택해 주세요.")
            return
        }
        
        
        let message = "\(email) / \(chosenGender.rawValue)"
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
            
            
            let signupViewModel = DViewModel<ApiResponse>(self, { (model, oldModel) -> () in
                guard let apiResponse = model else {
                    return
                }
                
                if let member = apiResponse.model as? MemberModel , apiResponse.statusCode == 200 {
                    _app.sessionViewModel.makeSession(member: member, email: email, password: password)
                    _app.delegate.moveTopAfterLoginSuccess()
                } else {
                    _app.sessionViewModel.removeSession()
                    if let error = apiResponse.serverErrorModel, let description = error.description {
                        alert(message: "\(description)")
                    } else {
                        alert(title: "가입 실패", message: "\(apiResponse.statusCode)")
                    }
                }
            })
            let _ = _app.api.accountSignupForEmail(email: email, password: password, genderCode: chosenGenderCode, recommendId: "", phone: "", code: "", apiResponseViewModel: signupViewModel, loadingViewModel: loadingViewModel)
            
        }
    }
    
    private weak var emailTextFieldBorder: CALayer?
    private weak var passwordTextFieldBorder: CALayer?
    private weak var passwordConfirmTextFieldBorder: CALayer?
    private weak var manButtonBorder: CALayer?
    private weak var womanButtonBorder: CALayer?
    
    private let activeColor = UIColor(rgba: "#726763")
    private let inactiveColor = UIColor(rgba: "#e3e1e0")
    
    private let apiQueue = DOperationQueue(maxConcurrent: 1)
    
    enum Gender: String {
        case Unknown = "알수없음"
        case Man = "남자"
        case Woman = "여자"
    }
    private var chosenGender = Gender.Unknown
    private var chosenGenderCode: String? {
        switch chosenGender {
        case .Unknown:
            return nil
        case .Man:
            return "M"
        case .Woman:
            return "F"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextFieldBorder = emailTextField.makeBottomBorder(borderWidth: 1.0, borderColor: inactiveColor)
        passwordTextField.isSecureTextEntry = true
        passwordTextFieldBorder = passwordTextField.makeBottomBorder(borderWidth: 1.0, borderColor: inactiveColor)
        passwordConfirmTextField.isSecureTextEntry = true
        passwordConfirmTextFieldBorder = passwordConfirmTextField.makeBottomBorder(borderWidth: 1.0, borderColor: inactiveColor)
        
        manButtonBorder = manButton.makeBottomBorder(borderWidth: 1.0, borderColor: inactiveColor)
        womanButtonBorder = womanButton.makeBottomBorder(borderWidth: 1.0, borderColor: inactiveColor)
        
        
        // 회원약관 링크
        let attrs = [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14.0),
            NSAttributedStringKey.foregroundColor : UIColor(rgba: "#726763")]
        let str1 = "회원가입과 동시에 "
        let str2 = "서비스이용약관"
        let str3 = "과 "
        let str4 = "개인정보이용방침"
        let str5 = "에 동의 하시게 됩니다"
        let attributedString = NSMutableAttributedString(string:"\(str1)\(str2)\(str3)", attributes:attrs)
        attributedString.addAttribute(NSAttributedStringKey.underlineStyle, value: 1, range: NSMakeRange(str1.length, str2.length))
        rule1Button.setAttributedTitle(attributedString, for: UIControlState.normal)
        let attributedString2 = NSMutableAttributedString(string:"\(str4)\(str5)", attributes:attrs)
        attributedString2.addAttribute(NSAttributedStringKey.underlineStyle, value: 1, range: NSMakeRange(0, str4.length))
        rule2Button.setAttributedTitle(attributedString2, for: UIControlState.normal)
        
        joinButton.makeHCircleStyle()
    }
    
    deinit {
        print(#function, "\(self)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _app.ga.trackingViewName(viewName: .sign_up)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // cell을 터치해도 입력창으로 커서 이동을 해준다
        switch indexPath.row {
        case 1: // 이메일
            emailTextField.becomeFirstResponder()
        case 2: // 비번
            passwordTextField.becomeFirstResponder()
        case 3: // 비번 확인
            passwordConfirmTextField.becomeFirstResponder()
        default:
            break
        }
    }
}

extension JoinViewController {
    
    func makeColorForTextField(textField: UITextField) {
        if let l = textField.text?.length, l > 0 {
            activeBorderColorForView(view: textField)
        } else {
            inactiveBorderColorForView(view: textField)
        }
    }
    
    func activeBorderColorForView(view: UIView) {
        switch view {
        case emailTextField:
            emailTextFieldBorder?.backgroundColor = activeColor.cgColor
        case passwordTextField:
            passwordTextFieldBorder?.backgroundColor = activeColor.cgColor
        case passwordConfirmTextField:
            passwordConfirmTextFieldBorder?.backgroundColor = activeColor.cgColor
        case manButton:
            manButtonBorder?.backgroundColor = activeColor.cgColor
        case womanButton:
            womanButtonBorder?.backgroundColor = activeColor.cgColor
        default:
            break
        }
    }
    
    func inactiveBorderColorForView(view: UIView) {
        switch view {
        case emailTextField:
            emailTextFieldBorder?.backgroundColor = inactiveColor.cgColor
        case passwordTextField:
            passwordTextFieldBorder?.backgroundColor = inactiveColor.cgColor
        case passwordConfirmTextField:
            passwordConfirmTextFieldBorder?.backgroundColor = inactiveColor.cgColor
        case manButton:
            manButtonBorder?.backgroundColor = inactiveColor.cgColor
        case womanButton:
            womanButtonBorder?.backgroundColor = inactiveColor.cgColor
        default:
            break
        }
    }
}
