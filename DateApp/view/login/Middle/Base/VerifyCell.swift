//
//  VerifyCell.swift
//  vegas-ios
//
//  Created by Lim Daehyun on 2018. 1. 24..
//  Copyright © 2018년 refactoring. All rights reserved.
//

import Foundation
import UIKit

class VerifyCell: UICollectionViewCell {
    var underlineTextField: UnderLineTextField!
    var button: UIButton!
    var onProcessVerify: ((String?) -> Void)?
    var onPressedButton: (() -> Void)?
    var onDidChangeText: ((String?) -> Void)?
    
    var onPressedTextFieldRightButton: (() -> Void)?
    func setItem(info: VerifyItem) {
        button?.isHidden = true
        underlineTextField?.isHidden = true
        
        if let itemType = info.item , itemType == .button {
            setButton(info)
        }else {
            setTextField(info: info)
        }
    }
    
    func rightButtonImage(image: UIImage?){
        underlineTextField.rightButtonImage = image
    }
    
    func setTextField(info: VerifyItem) {
        if underlineTextField == nil {
            underlineTextField = UnderLineTextField()
            underlineTextField.initTextField()
            self.addSubview(underlineTextField)
            
            underlineTextField.onPressedRightButon = {
                [weak self] in
                guard let wself = self else { return }
                wself.onPressedTextFieldRightButton?()
            }
            
            underlineTextField.snp.makeConstraints { (make) in
                make.top.equalTo(self.snp.top)
                make.leading.equalTo(0)
                make.trailing.equalTo(0)
                make.bottom.equalTo(self.snp.bottom)
            }
            
            underlineTextField.onFinishEdit = { [weak self] text in
                guard let wself = self else { return }
                wself.onProcessVerify?(text)
                wself.underlineTextField.state = .normal
            }
            
            underlineTextField.onBeginEdit = { [weak self] in
                guard let wself = self else { return }
                wself.underlineTextField.state = .editing
            }
            
            underlineTextField.onEndEdit = { [weak self] text in
                guard let wself = self else { return }
                wself.onProcessVerify?(text)
                wself.underlineTextField.state = .normal
            }
            
            underlineTextField.onDidChange = { [weak self] text in
                guard let wself = self else { return }
                wself.onDidChangeText?(text)
            }
        }
        
        underlineTextField.title = info.title
        underlineTextField.placeHolderText = info.placeHolderText
        underlineTextField.isSecureType = (info.type == VerifyItem.TypingType.secure)
        underlineTextField.textField.text = info.content
        underlineTextField.errorDescMessage = info.warnMessage
        underlineTextField.state = info.warnMessage != nil ? .warning : .normal
        underlineTextField.isHidden = false
    }
    
    private func setButton(_ info: VerifyItem) {
        if button == nil {
            let buttonStyle = LabelStyle(font: UIFont.systemFont(ofSize: 0), normalColor: UIColor(r: 155, g: 155, b: 155), highlightColor: UIColor(r: 155, g: 155, b: 155, a: 0.5))
            button = UIButton()
            button.titleLabel?.font = buttonStyle.font
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
            button.setTitleColor(buttonStyle.normalColor, for: .normal)
            button.setTitleColor(buttonStyle.highlightColor, for: .highlighted)
            button.addTarget(self, action: #selector(VerifyCell.onPressedButtonOption), for: UIControlEvents.touchUpInside)
            addSubview(button)
            button.snp.makeConstraints { (make) in
                make.top.equalTo(self.snp.top)
                make.leading.equalTo(0)
                make.trailing.equalTo(0)
                make.height.equalTo(18)
            }
        }
        button.setTitle(info.title, for: .normal)
        button.isHidden = false
    }
    
    func hideKeyboard() {
        underlineTextField?.hideKeyboard()
    }
    
    @objc func onPressedButtonOption() {
        onPressedButton?()
    }
}
