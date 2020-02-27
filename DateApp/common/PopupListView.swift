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

class PopupListView: XibView, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var bothButtonBGView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var titleViewHeight: NSLayoutConstraint!
    
    let resizeWidth: CGFloat = 262
    let maxHeight: CGFloat = 400
    var imagePopupView: UIImageView!
    var noticeType: NoticeType! = .Text

    var didTappedConfirmButton: (()->Void)?
    var didTappedOtherButton: (()->Void)?
    var webLink: String?
    var datas: [CodeValueModel]!
    var keywordType: ProfileKeywordType = .HobbyType
    var emptyMargin: CGFloat = 200
    var titleMargin: CGFloat = 57
    var bottomMargin: CGFloat = 50
    
    deinit {
        #if DEBUG
            print("file: \(#file), line: \(#line), function: \(#function)")
        #endif
    }
    
    override var nibName : String {
        get {
            return "PopupListView"
        }
    }
    
    class func annotationHeightSize(title: String?) -> CGFloat {
        var viewWidth: CGFloat = 0.0
        
        let titleStringSize = title?.boundingRect(with: CGSize(width: 235, height: 10000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: 15)], context: nil).size
        viewWidth = 47 + (titleStringSize?.width)!
        
        return viewWidth
    }
    
    private func addSubviewOnWindow(){
        let window = UIApplication.shared.keyWindow
        let viewFrame = CGRect(x: 0, y: 0, width: window!.bounds.size.width, height: window!.bounds.size.height)
        self.frame = viewFrame
        /*
        bgView.layer.cornerRadius = 10
        bgView.layer.masksToBounds = true
        */
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
    
    //MARK: - Show Text Alert View
    func show(keywordType: ProfileKeywordType, title: String?, data: [CodeValueModel], cancelButton: Bool, confirmAction:(()->Void)?){
        self.keywordType = keywordType
        self.datas = data
        if (title?.length)! < 1 {
            titleViewHeight.constant = 20
        }
    
        didTappedConfirmButton = confirmAction
        
        addSubviewOnWindow()
        setPopupTitle(title: title)
        setCollectionView()
    }
    
    func setCollectionView() {
        collectionView.register(UINib(nibName: "PopupListViewCell", bundle: nil), forCellWithReuseIdentifier: "PopupListViewCell")
        
        setCollectionViewHeight()
    }

    func setPopupTitle(title: String?){
        titleLabel.text = title
    }

    func setCollectionViewHeight() {
        var height = CGFloat(datas.count) * PopupListViewCell.cellHeight
        if height > getScreenSize().height - emptyMargin - titleMargin - bottomMargin {
            height = getScreenSize().height - emptyMargin - titleMargin - bottomMargin
        }
        titleViewHeight.constant = titleMargin
        viewHeight.constant = titleViewHeight.constant + height + 50
    }
    
    //MARK: - Resize Image
    func ResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
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
        removeCurrentView()
    }
    
    @IBAction func confirmAction(){
        _app.profileSubmitButtonShowViewModel.model = true
        _app.mergeForUpdateProfileCodes(type: keywordType)
        didTappedConfirmButton?()
        removeCurrentView()
    }
    
    @IBAction func cancelAction(){
        closeAction()
    }
    
    //MARK: - Hit test
    func reconizeTapGesture(gesture: UITapGestureRecognizer) {
        guard self.webLink != nil else {
            return
        }
    }
    
    func isSelected(keyword: CodeValueModel) -> Bool{
        var isSelected: Bool = false
        let selectedInfos = _app.getCopyProfileTypeCodes(type: keywordType)
        if let _ = selectedInfos![keyword.code!] {
            isSelected = true
        }
        return isSelected
    }
    
    //MARK: - UICollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopupListViewCell", for: indexPath) as? PopupListViewCell {
            cell.setCellData(title: datas[indexPath.row], isSelected: isSelected(keyword: datas[indexPath.row]))
            return cell
        }

        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = bgView.frame.size.width
        let height = PopupListViewCell.cellHeight
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedKeyword = datas[indexPath.row]
        
        if isSelected(keyword: datas[indexPath.row]) {
            _app.removeCopyItem(key: selectedKeyword.code!, type: keywordType)
        }else {
            _app.insertCopyItem(value: selectedKeyword, type: keywordType)
        }
        
        self.collectionView.reloadData()
    }
}
