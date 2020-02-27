//
//  KMPopupView.swift
//  KakaoMap
//
//  Created by Lim Daehyun on 2016. 9. 30..
//  Copyright © 2016년 Kakao Corp. All rights reserved.
//
import UIKit
import Foundation
import SDWebImage

enum NoticeType: Int {
    case Text = 0
    case Image
    case WebView
}

class KMPopupView: XibView {
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var imageContentView: UIView!
    @IBOutlet weak var imageCloseBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var bothButtonBGView: UIView!
    @IBOutlet weak var oneButtonBGView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var viewHeight: NSLayoutConstraint!
    @IBOutlet var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var titleViewHeight: NSLayoutConstraint!
    @IBOutlet var messageView: UITextView!
    let resizeWidth: CGFloat = 262
    let maxHeight: CGFloat = 400
    var imagePopupView: UIImageView!
    var noticeType: NoticeType! = .Text
    var otherButtonInfo:String? = nil
    var didTappedConfirmButton: ((String)->Void)?
    var didTappedOtherButton: (()->Void)?
    var webLink: String?
    
    @IBOutlet weak var webViewBGView: UIView!
    @IBOutlet weak var webView: UIWebView?
    @IBOutlet weak var webViewTopSpace: NSLayoutConstraint!
    
    deinit {
        #if DEBUG
            print("file: \(#file), line: \(#line), function: \(#function)")
        #endif
    }
    
    override var nibName : String {
        get {
            return "KMPopupView"
        }
    }
    
    class func annotationHeightSize(title: String?) -> CGFloat {
        var viewWidth: CGFloat = 0.0
        
        let titleStringSize = title?.boundingRect(with: CGSize(width: 235, height: 10000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: 17)], context: nil).size
        viewWidth = 47 + (titleStringSize?.width)!
        
        return viewWidth
    }
    
    private func addSubviewOnWindow(){
        let window = UIApplication.shared.keyWindow
        let viewFrame = CGRect(x: 0, y: 0, width: window!.bounds.size.width, height: window!.bounds.size.height)
        self.frame = viewFrame
        
        /*
        bgView.layer.cornerRadius = 10
        bgView.layer.masksToBounds = true*/
        self.alpha = 0
        window!.addSubview(self)

        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut,
                                   animations: {
                                    [weak self] in
                                    if let wself = self {
                                        wself.alpha = 1.0
                                    }
            }, completion: {
                [weak self] finished in
                if let _ = self {
                }
            })
    }
    
    func enableNoticeViewWithType(_noticeType: NoticeType?){
        webViewBGView?.alpha = 0
        bgView.isHidden = true
        imageScrollView.isHidden = true
        imageCloseBtn.isHidden = true
        
        guard let noticeType = _noticeType else {
            return
        }
        
        switch noticeType {
        case .Text:
            bgView.isHidden = false
            imageScrollView.isHidden = true
            imageCloseBtn.isHidden = true
        case .Image:
            bgView.isHidden = true
            imageScrollView.isHidden = false
            imageCloseBtn.isHidden = false
        case .WebView:
            bgView.isHidden = true
            imageScrollView.isHidden = true
            imageCloseBtn.isHidden = true
        }
    }
    
    //MARK: - Show Text Alert View
    func show(title: String?, titleStyle: LabelStyle? = nil, message: String?, messageStyle: LabelStyle? = nil, cancelButton: Bool, confirmAction:((String)->Void)?){
        if let c = title?.length, c < 1 {
            titleViewHeight.constant = 20
        }
        
        enableNoticeViewWithType(_noticeType: .Text)
        
        didTappedConfirmButton = confirmAction
        
        addSubviewOnWindow()
        setPopupTitle(title: title)
        
        
        if let t = titleStyle {
            titleLabel.textColor = t.normalColor
            titleLabel.font = t.font
        }
        
        if let m = messageStyle {
            messageView.textColor = m.normalColor
            messageView.font = m.font
        }
        setPopupMessage(message: message, fontSize: messageStyle?.font.pointSize)
        enableOnlyConfirmButton(isEnable: !cancelButton)
    }
    
    
    func show(title: String?, titleStyle: LabelStyle? = nil, message: String?, messageStyle: LabelStyle? = nil, otherButtonTitle: String?, okButtonTitle: String?, otherButtonAction:(()->Void)?, confirmAction:((String)->Void)?){
        show(title: title,
             titleStyle: titleStyle,
             enableTextView: false,
             message: message,
             messageStyle: messageStyle,
             otherButtonTitle: otherButtonTitle,
             okButtonTitle: okButtonTitle,
             otherButtonAction: otherButtonAction,
             confirmAction: confirmAction)
    }
    
    func show(title: String?, titleStyle: LabelStyle? = nil, enableTextView: Bool,  message: String?,  messageStyle: LabelStyle? = nil, otherButtonTitle: String?, okButtonTitle: String?, otherButtonAction:(()->Void)?, confirmAction:((String)->Void)?){
        if let c = title?.length, c < 1 {
            titleViewHeight.constant = 20
        }
        
        enableNoticeViewWithType(_noticeType: .Text)
        
        didTappedOtherButton = otherButtonAction
        didTappedConfirmButton = confirmAction
        
        otherButtonInfo = otherButtonTitle
        addSubviewOnWindow()
        setPopupTitle(title: title)
        
        
        if let t = titleStyle {
            titleLabel.textColor = t.normalColor
            titleLabel.font = t.font
        }
        
        if let m = messageStyle {
            messageView.textColor = m.normalColor
            messageView.font = m.font
        }
        setPopupMessage(message: message, fontSize: messageStyle?.font.pointSize)
        enableOnlyConfirmButton(isEnable: otherButtonTitle == nil ? true : false)
        if otherButtonTitle != nil {
            cancelBtn.setTitle(otherButtonTitle, for: UIControlState.normal)
        }
        
        if okButtonTitle != nil {
            okBtn.setTitle(okButtonTitle, for: UIControlState.normal)
        }
        
        if enableTextView {
            messageView.isEditable = true
            messageView.becomeFirstResponder()
        }
    }
    
    func showImagePopup(_imageURL: String?, webLink: String?, confirmAction:((String)->Void)?){
        didTappedConfirmButton = confirmAction
        
        self.webLink = webLink
        
        /// Test Url
        //
        /*
        _imageURL = "https://i.paigeeworld.com/user-media/1464393600000/55ee320910561259727251e9_5749a7107d5de44f2fb6b5fd_320.jpg"
        */
        
        enableNoticeViewWithType(_noticeType: nil)
        
        let t = UITapGestureRecognizer(target: self, action: #selector(self.reconizeTapGesture(_:)))
        self.imageScrollView.addGestureRecognizer(t)
        
        guard let imageURL = _imageURL else{
            return
        }
        
        imagePopupView = UIImageView()
        imagePopupView.contentMode = .scaleAspectFill
        imagePopupView.clipsToBounds = true
        imageContentView.addSubview(imagePopupView)
        imagePopupView.sd_setImage(with: URL(string: imageURL)) { (image , error , cachType , url ) in
            if let img = image {
                DispatchQueue.main.async {
                    self.addSubviewOnWindow()
                    
                    let resizeHeight = (img.size.height * self.resizeWidth) / img.size.width
                    self.imagePopupView.image = img.ResizeImage(targetSize: CGSize(width: self.resizeWidth, height: resizeHeight))
                    self.adjustImageScrollViewFrame(imageHeight: resizeHeight)
                    
                    self.enableNoticeViewWithType(_noticeType: .Image)
                }
            }
            
            if let err = error {
                #if DEBUG
                print("url::: \(imageURL), error::: \(err)")
                #endif
            }
        }
    }
    
    func showWebView(_webLink: String?, confirmAction:((String)->Void)?) {
        guard let webLink = _webLink else {
            return
        }
        didTappedConfirmButton = confirmAction
        self.addSubviewOnWindow()
        self.webLink = webLink
        enableNoticeViewWithType(_noticeType: .WebView)
        
        loadWebView()
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            () -> Void in
            self.webViewBGView.alpha = 1
        }) { (finished) -> Void in
        }
    }
    
    func adjustImageScrollViewFrame(imageHeight: CGFloat){
        self.layoutIfNeeded()
        
        if imageHeight < maxHeight {
            scrollViewHeight.constant = imageHeight
        }
        var imageViewFrame = imagePopupView.frame
        imageViewFrame.origin.x = 0
        imageViewFrame.origin.y = 0
        imageViewFrame.size.height = imageHeight
        imageViewFrame.size.width = resizeWidth
        imagePopupView.frame = imageViewFrame
        
        var imageContentViewFrame = imageContentView.frame
        imageContentViewFrame.size.width = resizeWidth
        imageContentViewFrame.size.height = imageHeight
        imageContentView.frame = imageContentViewFrame
        
        imageScrollView.contentSize = CGSize(width: resizeWidth, height: imageHeight)
    }
    
    func setPopupTitle(title: String?){
        titleLabel.text = title
    }
    
    func setPopupMessage(message: String?, fontSize: CGFloat? = nil) {
        let messageString = message != nil ? message! : "  "
        messageView.textContainer.lineFragmentPadding = 0
        messageView.textContainerInset = UIEdgeInsets.zero
        
        messageView.text = messageString.replacingOccurrences(of: "\\n", with: "\n")
        let messageStringSize = messageString.boundingRect(with: CGSize(width: 235, height: 10000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: fontSize ?? 17)], context: nil).size
        let messageHeight = messageStringSize.height + 20
        textViewHeight.constant = (messageHeight > 180 ? 180 : messageHeight)
        viewHeight.constant = titleViewHeight.constant + textViewHeight.constant + 50
        self.layoutIfNeeded()
    }
    
    func enableOnlyConfirmButton(isEnable: Bool){
        bothButtonBGView.isHidden = isEnable
        oneButtonBGView.isHidden = !isEnable
    }
    
    func enableBothButton(){
        enableOnlyConfirmButton(isEnable: false)
    }
    
    //MARK: - Resize Image
    
    //MARK: - Attributed Text
//    func setHilightMessage(baseMessage: String, hilightKeyword: String?) -> NSAttributedString{
//        
//        let attributedString = NSMutableAttributedString(string: baseMessage, attributes: [.foregroundColor: UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0), .font:UIFont.systemFont(ofSize: 15)])
//        
//        if let keyword = hilightKeyword {
//            let uppderCaseText = baseMessage.uppercaseString
//            let upperCaseKeyword = keyword.uppercaseString
//            
//            let mystring:String = "indeep";
//            let findCharacter:Character = "d";
//            
//            if (uppderCaseText.characters.contains(upperCaseKeyword.characters))
//            {
//                let position = uppderCaseText.characters.indexOf(upperCaseKeyword);
//                NSLog("Position of c is \(uppderCaseText.startIndex.distanceTo(position!))")
//                
//            }
//            else
//            {
//                NSLog("Position of c is not found");
//            }
//            
//            
////            let matchRange: Range? = uppderCaseText.rangeOfString(upperCaseKeyword)
////            if matchRange != nil{
////                let keywordRange = NSRange(location: 0, length: hilightKeyword.length)
////                if keywordRange.length > 0 {
////                    attributedString.addAttribute(NSBackgroundColorAttributeName, value: UIColor(red: 187/255, green: 187/255, blue: 187/255, alpha: 1.0), range: keywordRange)
////                }
////            }
//        }
//        
//        return attributedString
//    }
    
    //MARK: - Button Action
    func removeCurrentView() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut,
                                   animations: {
                                    [weak self] in
                                    if let wself = self {
                                        wself.alpha = 0
                                    }
            }, completion: {
                [weak self] finished in
                if let wself = self {
                    wself.removeFromSuperview()
                }
            })
    }
    
    @IBAction func closeAction(){
        
        if otherButtonInfo != nil || (self.webLink?.length)!  > 0 {
            didTappedConfirmButton?(messageView.text)
        }

        removeCurrentView()
    }
    
    @IBAction func confirmAction(){
        
        if otherButtonInfo != nil || (self.webLink?.length)! > 0 {
            didTappedConfirmButton?(messageView.text)
        }
        removeCurrentView()
    }
    
    @IBAction func cancelAction(){
        if otherButtonInfo != nil {
            didTappedOtherButton?()
        }else{
            closeAction()
        }
        
        removeCurrentView()
    }
    
    func loadWebView(){
        guard let _webLink = self.webLink else {
            return
        }
        let request = NSMutableURLRequest(url: URL(string: _webLink)!)
        webView?.loadRequest(request as URLRequest)
    }
    
    func showWebView() {
        showWebView(_webLink: self.webLink, confirmAction: nil)
    }
    
    //MARK: - Hit test
    @objc func reconizeTapGesture(_ gesture: UITapGestureRecognizer) {
        guard self.webLink != nil else {
            return
        }
    }
}
