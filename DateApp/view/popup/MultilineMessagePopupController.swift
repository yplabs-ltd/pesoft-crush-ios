//
//  MultilineMessagePopupController.swift
//  DateApp
//
//  Created by ryan on 1/7/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import UIKit

class MultilineMessagePopupController: UIViewController {
    
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var addVoiceButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var textContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var textContainerBottom: NSLayoutConstraint!
    private var newRecordVoiceSegue: DSegue!
    
    @IBAction func cancel(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func submit(sender: AnyObject) {
        if textView.text == placeholder {
            textView.text = nil
        }
        submitHandler?(self)
    }
    
    var titleMessage: String? {
        didSet {
            if let titleLable = titleLable {
                titleLable.text = titleMessage
            }
        }
    }
    var subtitleMessage: String? {
        didSet {
            if let subtitleLabel = subtitleLabel {
                subtitleLabel.text = titleMessage
            }
        }
    }
    
    var useAddVoice: Bool = false
    var containerHeight: CGFloat = 163
    var rightButtonTitle: String?
    var leftButtonTitle: String?
    var voiceUrl: String?
    
    var placeholder: String?
    var message: String? {
        return textView.text
    }
    var submitHandler: ((MultilineMessagePopupController) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textContainerHeight.constant = containerHeight
        titleLable.text = titleMessage
        subtitleLabel.text = subtitleMessage
        if let rightBtnTitle = rightButtonTitle {
            rightButton.setTitle(rightBtnTitle, for: UIControlState.normal)
        }
        if let leftBtnTitle = leftButtonTitle {
            leftButton.setTitle(leftBtnTitle, for: UIControlState.normal)
        }
        
        textView.textColor = UIColor.lightGray
        textView.text = placeholder
        textView.returnKeyType = .done   // 키보드 사라지는 키가 필요함
        
        addVoiceButton.isHidden = !useAddVoice
        textContainerBottom.constant = useAddVoice ? 64 : 30
        
        newRecordVoiceSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "NewVoiceRecordPopupController") as! NewVoiceRecordPopupController
            destination.submitHandler = { [weak self] vc in
                guard let wself = self else { return }
                wself.voiceUrl = vc.voiceUrl
                wself.addVoiceButton.isSelected = true
            }
            destination.isPromotion = true
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: 470.5)
            })
            destination.popupType = .AddVoice
            return (destination, style)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickAddVoice() {
        newRecordVoiceSegue.perform()
    }
    
    deinit {
        print(#function, "\(self)")
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

extension MultilineMessagePopupController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == placeholder {
            textView.text = ""
        }
        textView.textColor = UIColor.black
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.length == 0 {
            textView.textColor = UIColor.lightGray
            textView.text = placeholder
            textView.resignFirstResponder()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let count = text.rangeOfCharacter(from: CharacterSet.newlines)
        if count != nil {
            textView.resignFirstResponder()
        }
        return true
    }
}
