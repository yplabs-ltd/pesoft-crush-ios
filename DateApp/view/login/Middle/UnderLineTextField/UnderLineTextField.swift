//
//  UnderLineTextField.swift
//  vegas-ios
//
//  Created by Daehyun Lim on 2018. 1. 24..
//  Copyright © 2018년 refactoring. All rights reserved.
//

import Foundation
import UIKit

struct LabelStyle {
    let font: UIFont!
    let normalColor: UIColor!
    let highlightColor: UIColor!
}

struct LineStyle {
    let normalColor: UIColor!
    let highlightColor: UIColor?
    let warningColor: UIColor?
}

enum TextFieldState {
    case normal
    case highlight
    case warning
    case editing
}

class UnderLineTextField: XibView {
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var underLine: UIView!
    @IBOutlet weak var rightBtnWidth: NSLayoutConstraint!
    @IBOutlet weak var rightBtnHeight: NSLayoutConstraint!
    
    //MARK: - Closure
    var onFinishEdit: ((String?) -> Void)?
    var onBeginEdit: (() -> Void)?
    var onEndEdit: ((String?) -> Void)?
    var onDidChange: ((String?) -> Void)?
    
    var onPressedRightButon: (() -> Void)?
    override var nibName : String {
        get {
            return "UnderLineTextField"
        }
    }
    
    var rightButtonImage: UIImage? = nil {
        didSet {
            rightButton.setImage(rightButtonImage, for: .normal)
            rightBtnWidth.constant = rightButtonImage == nil ? 0 : rightButtonImage!.size.width
            rightBtnHeight.constant = rightButtonImage == nil ? 0 : rightButtonImage!.size.width
            updaterightButtonState()
        }
    }
    
    var state: TextFieldState = .normal {
        didSet {
            updateWarnMessageLabel()
            updaterightButtonState()
            updateTopLabelState()
            updateBottomLabelState()
            updateUnderLineStyle()
        }
    }
    
    var topLabelStyle: LabelStyle = LabelStyle(font: UIFont.systemFont(ofSize: 12), normalColor: UIColor(r: 114, g: 103, b: 99, a: 0.5), highlightColor: UIColor(r: 114, g: 103, b: 99, a: 0.3)) {
        didSet {
            updateTopLabelState()
        }
    }
    
    var bottomLabelStyle: LabelStyle = LabelStyle(font: UIFont.systemFont(ofSize: 12), normalColor: UIColor(r: 255, g: 113, b: 113), highlightColor: nil) {
        didSet {
            updateBottomLabelState()
        }
    }
    
    var underLineStyle: LineStyle = LineStyle(normalColor: UIColor(r: 114, g: 103, b: 99, a: 0.3), highlightColor: UIColor(r: 114, g: 103, b: 99), warningColor: UIColor(r: 255, g: 113, b: 113)) {
        didSet {
            updateUnderLineStyle()
        }
    }
    
    var errorDescMessage: String? = nil {
        didSet {
            state = (errorDescMessage == nil) ? .normal : .warning
            bottomLabel.text = errorDescMessage ?? ""
        }
    }
    
    var textFieldStyle: LabelStyle = LabelStyle(font: UIFont.systemFont(ofSize: 15), normalColor: UIColor(r: 114, g: 103, b: 99), highlightColor: nil) {
        didSet {
            updateTextFieldStyle()
        }
    }
    
    var title: String? = nil {
        didSet {
            topLabel.text = title
        }
    }
    var placeHolderText: String? = nil {
        didSet {
            guard let p = placeHolderText  else {
                return
            }
            textField.attributedPlaceholder = NSAttributedString(string: p, attributes: [.foregroundColor: UIColor(r: 114, g: 103, b: 99, a: 0.3)])

        }
    }
    var isSecureType: Bool? {
        didSet {
            textField.isSecureTextEntry = isSecureType ?? false
        }
    }
    
    override func awakeFromNib() {
        initTextField()
    }
    func hideKeyboard() {
        textField.resignFirstResponder()
    }
    
    func initTextField() {
        state = .normal
        updateTextFieldStyle()
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @IBAction func onPressedRightButton() {
        onPressedRightButon?()
    }
    
    private func updaterightButtonState() {
        guard let t = textField.text , t.length > 0 else {
            rightButton.isHidden = true
            return
        }
        switch state {
        case .editing:
            rightButton.isHidden = false
        default:
            rightButton.isHidden = true
        }
    }
    
    private func updateWarnMessageLabel() {
        if state != .warning {
            bottomLabel.text = nil
        }
    }
    
    private func updateTopLabelState() {
        topLabel.font = topLabelStyle.font
        switch state {
        case .highlight:
            topLabel.textColor = topLabelStyle.highlightColor ?? topLabelStyle.normalColor
        default:
            topLabel.textColor = topLabelStyle.normalColor
        }
    }
    
    private func updateBottomLabelState() {
        bottomLabel.font = bottomLabelStyle.font
        switch state {
        case .highlight:
            bottomLabel.textColor = bottomLabelStyle.highlightColor ?? bottomLabelStyle.normalColor
        default:
            bottomLabel.textColor = bottomLabelStyle.normalColor
        }
    }
    
    private func updateUnderLineStyle() {
        switch state {
        case .normal:
            underLine.backgroundColor = underLineStyle.normalColor
        case .highlight, .editing:
            underLine.backgroundColor = underLineStyle.highlightColor ?? underLineStyle.normalColor
        case .warning:
            underLine.backgroundColor = underLineStyle.warningColor ?? underLineStyle.normalColor
        }
    }
    
    private func updateTextFieldStyle() {
        textField.textColor = textFieldStyle.normalColor
        textField.font = textFieldStyle.font
    }
}

extension UnderLineTextField: UITextFieldDelegate {
    @objc func textFieldDidChange(_ textField: UITextField) {
        onDidChange?(textField.text)
        updaterightButtonState()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        onBeginEdit?()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        onEndEdit?(textField.text)
        hideKeyboard()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        onFinishEdit?(textField.text)
        hideKeyboard()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        return true
    }
}
