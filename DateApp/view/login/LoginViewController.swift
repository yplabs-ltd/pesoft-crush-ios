//
//  LoginViewController.swift
//  DateApp
//
//  Created by ryan on 12/27/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit

class LoginViewController: UITableViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordForgetButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    func textFieldEditingDidBegin(sender: UITextField) {
        activeBorderColorForView(view: sender)
    }
    
    func textFieldEditingDidEnd(sender: UITextField) {
        makeColorForTextField(textField: sender)
    }
    
    @IBAction func loginButtonTouchUpInside(sender: AnyObject) {
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
        
        
        let indi = ActivityIndicatorViewBuilder(centerAtView: view, style: UIActivityIndicatorViewStyle.gray).indicatorView
        let loadingViewModel = DViewModel<LoadingModel>(LoadingModel(), self, { (model, oldModel) -> () in
            if model?.loading == true {
                indi.startAnimating()
            } else {
                indi.stopAnimating()
            }
        })
        
        let accountViewModel = DViewModel<ApiResponse>(self, { (model, oldModel) -> () in
            guard let apiResponse = model else {
                return
            }
            
            if let member = apiResponse.model as? MemberModel , apiResponse.statusCode == 200 {
                _app.sessionViewModel.makeSession(member: member, email: email, password: password)
                _app.delegate.moveTopAfterLoginSuccess()
            } else {
                _app.sessionViewModel.removeSession()
            }
        })
        let _ = _app.api.accountSigninForEmail(email: email, password: password, apiResponseViewModel: accountViewModel, loadingViewModel: loadingViewModel)
        
    }
    
    @IBAction func passwordForgetButtonTouchUpInside(sender: AnyObject) {
        alert(message: "비번분실!")
    }
    
    private weak var emailTextFieldBorder: CALayer?
    private weak var passwordTextFieldBorder: CALayer?
    
    private let activeColor = UIColor(rgba: "#726763")
    private let inactiveColor = UIColor(rgba: "#e3e1e0")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.returnKeyType = .done
        emailTextFieldBorder = emailTextField.makeBottomBorder(borderWidth: 1.0, borderColor: inactiveColor)
        passwordTextField.isSecureTextEntry = true
        passwordTextField.returnKeyType = .done
        passwordTextFieldBorder = passwordTextField.makeBottomBorder(borderWidth: 1.0, borderColor: inactiveColor)
        
        loginButton.makeHCircleStyle()
    }
    
    deinit {
        print(#function, "\(self)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _app.ga.trackingViewName(viewName: .sign_in)
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
        default:
            break
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        textFieldEditingDidBegin(sender: textField)
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        loginButtonTouchUpInside(sender: textField)
        return true
    }
}

extension LoginViewController {
    
    func makeColorForTextField(textField: UITextField) {
        if 0 < (textField.text?.length)! {
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
        default:
            break
        }
    }
}
