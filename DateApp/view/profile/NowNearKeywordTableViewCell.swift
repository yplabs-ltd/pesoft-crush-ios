//
//  NowNearKeywordTableViewCell.swift
//  KakaoMap
//
//  Created by Lim Daehyun on 2016. 10. 21..
//  Copyright © 2016년 Kakao Corp. All rights reserved.
//

import UIKit

protocol NowNearKeywordTableViewCellDelegate: NSObjectProtocol {
    func onClickMoreButton()
    func onClickKeywordButton(title: String)
}

enum ProfileKeywordType: String {
    case HobbyType = "String"
    case CharmingType = "Charming"
    case FavoriteType = "Favorite"
}


class NowNearKeywordTableViewCell: UITableViewCell {
    @IBOutlet weak var cardIconImageView: UIImageView!
    @IBOutlet weak var cardTitleLabel: UILabel!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var keywordBGView: UIView!
    @IBOutlet weak var titleLabelTop: NSLayoutConstraint!
    
    var contentBGView: UIView!
    var keywordType: ProfileKeywordType = .HobbyType
    var isFold: Bool = true
    var isMe: Bool = true
    let maxDisplayCount: Int = 1000
    let limitLengthOneline: CGFloat = getScreenSize().width - 30
    var sumKeywordsLength: CGFloat = 0
    var keywordSpacing: CGFloat = 5
    var buttonInsetMargin: CGFloat = 26
    var collectionViewCellSize: CGSize = CGSize.zero
    var keywords: [CodeValueModel]? = nil
    var yCoord: CGFloat = 0
    weak var delegate: NowNearKeywordTableViewCellDelegate?
    
    let normalImg = UIImage(named: "myProfileBox")
    let selectedImg = UIImage(named: "myProfileBoxRed")
    let keywordBGViewTag: Int = 1000
    var isAddedMoreBtn: Bool = false
    
    var updateKeyword: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        contentBGView = UIView()
        self.addSubview(contentBGView)
        if let keywordView = contentBGView {
            keywordView.tag = keywordBGViewTag
        }
    }

    func getViewHeight(_ dataList: [CodeValueModel]?, isFold: Bool) -> CGFloat {
        guard let datas = dataList else {
            return 0
        }
        
        if datas.count == 0 {
            return 0
        }
        
        var lineNum: Int = 0
        let showingCount = (datas.count > maxDisplayCount ? maxDisplayCount : datas.count) - 1
        var keywordBGView = makeKeywordBGView(lineNum: lineNum)
        self.isFold = isFold
        sumKeywordsLength = 0
        if datas.count == 0 {
            return 0
        }
        isAddedMoreBtn = false
        for (i,keyword) in datas.enumerated() {
            let keywordStringSize = keyword.value!.boundingRect(with: CGSize(width: limitLengthOneline, height: 10000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: 14)], context: nil).size
            var keywordWidth = keywordStringSize.width
            if i == showingCount {
                keywordWidth = 46.0
            }
            if isOverLineMaxLength(keywordBGView: keywordBGView, keywordSize: keywordWidth, lineNum: lineNum, curIndex: i, totalCount: showingCount) {
                /*
                if isFold && lineNum == 1{
                    break
                }
                
                if isFold == false && lineNum == 3 {
                    break
                }*/
                
                lineNum += 1
                keywordBGView = makeKeywordBGView(lineNum: lineNum)
            }
            sumKeywordsLength += (keywordStringSize.width + keywordSpacing + buttonInsetMargin)
        }

        return CGFloat(lineNum + 1) * 35 + 9 + 50
    }
    
    func configure(dataList: [CodeValueModel]?, type: ProfileKeywordType) {
        guard let datas = dataList else{
            return
        }
        self.keywordType = type
        
        updateTitleLabel()
        self.keywords = datas
        
        if (datas.count > 0) {
            displayNearKeywords(datas: datas)
        }else{
            cardTitleLabel.isHidden = true
        }
    }
    
    func updateTitleLabel() {
        cardTitleLabel.isHidden = false
        cardTitleLabel.font = UIFont.systemFont(ofSize: 14)
        switch keywordType {
        case .HobbyType:
            cardTitleLabel.text = isMe ? "제가 관심있는 것들은요" : "\"제가 관심있는 것들은요\""
        case .CharmingType:
            cardTitleLabel.text = isMe ? "저는 이런 매력이 있어요" : "\"저는 이런 매력이 있어요\""
        case .FavoriteType:
            cardTitleLabel.text = isMe ? "저는 이런 분이 좋아요" : "\"저는 이런 분이 좋아요\""
        }
    }

    func displayNearKeywords(datas: [CodeValueModel]) {
        if let keywordView = _app.viewDict[keywordType.rawValue] {
            if self.contentBGView.subviews.count >= 2 {
                return
            }
            
            for subView in self.contentView.subviews {
                if subView.tag == keywordBGViewTag {
                    subView.removeFromSuperview()
                }
            }
            var viewFrame = keywordView.frame
            viewFrame.origin.y = 50
            keywordView.frame = viewFrame
        
            if let t = titleLabelTop {
                t.constant = 15 + yCoord
            }
            self.contentView.addSubview(keywordView)
        }
        
        sumKeywordsLength = 0
        for subView in self.contentBGView.subviews {
            subView.removeFromSuperview()
        }
        
        var lineNum: Int = 0
        let showingCount = (datas.count > maxDisplayCount ? maxDisplayCount : datas.count) - 1
        var keywordBGView = makeKeywordBGView(lineNum: lineNum)
        for (i,keyword) in datas.enumerated() {
            
            let keywordStringSize = keyword.value!.boundingRect(with: CGSize(width: limitLengthOneline, height: 10000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: 14)], context: nil).size
            var keywordWidth = keywordStringSize.width
            if i == showingCount {
                keywordWidth = 46.0
            }
            if isOverLineMaxLength(keywordBGView: keywordBGView, keywordSize: keywordWidth, lineNum: lineNum, curIndex: i, totalCount: showingCount) {
                /*
                if isFold && lineNum == 1{
                    _app.viewDict["contentView"] = self.contentBGView
                    return
                }*/
                
                /*
                if isFold == false && lineNum == 3 {
                    _app.viewDict["contentView"] = self.contentBGView
                    return
                }*/
                
                lineNum += 1
                keywordBGView = makeKeywordBGView(lineNum: lineNum)
            }
            makeKeywordButton(bgView: keywordBGView, keyword: keyword.value!, size: keywordStringSize)
            adjustKeywordBGViewFrame(_bgView: keywordBGView)
            
            if i >= showingCount {
                _app.viewDict[keywordType.rawValue] = self.contentBGView
                return
            }
            
        }
    }
    
    func addMoreButton(bgView: UIView?) {
        isAddedMoreBtn = true
        
        let keywordButton = UIButton()
        keywordButton.frame = CGRect(x: sumKeywordsLength, y: 0, width: 46, height: 27)
        keywordButton.addTarget(self, action: #selector(self.actionMoreButton), for: .touchUpInside)
        keywordButton.isExclusiveTouch = true
        
        let normalImage = UIImage(named: "myprofile_btn_addbox")
        let selectedImage = UIImage(named: "myprofile_btn_addbox_pressed")
        
        keywordButton.setBackgroundImage(normalImage, for: UIControlState.normal)
        keywordButton.setBackgroundImage(selectedImage, for: UIControlState.selected)
        bgView?.addSubview(keywordButton)
        sumKeywordsLength += (46 + keywordSpacing)
        adjustKeywordBGViewFrame(_bgView: bgView)
    }
    
    func makeKeywordBGView(lineNum: Int) -> UIView? {
        guard let _ = self.contentBGView else {
            return nil
        }
        let bgView = UIView(frame: CGRect(x: 0, y: CGFloat(lineNum) * 35, width: 0, height: 35))
        self.contentBGView.addSubview(bgView)
        adjustContentBGViewFrame(lineNum: lineNum)
        return bgView
    }
    
    func adjustKeywordBGViewFrame(_bgView: UIView?){
        guard let bgView = _bgView else {
            return
        }
        
        let viewWidth = sumKeywordsLength - keywordSpacing
        var viewFrame = bgView.frame
        viewFrame.origin.x = (getScreenSize().width - viewWidth) / 2
        viewFrame.size.width = viewWidth
        
        bgView.frame = viewFrame
    }
    
    func adjustContentBGViewFrame(lineNum: Int){
        var viewFrame = contentBGView.frame
        viewFrame.origin.x = 0
        viewFrame.origin.y = 50 + yCoord
        viewFrame.size.width = getScreenSize().width
        //viewFrame.size.height = CGFloat(lineNum == 0 ? 1 : lineNum) * 35
        viewFrame.size.height = CGFloat(lineNum + 1) * 35
        if let t = titleLabelTop {
            t.constant = 15 + yCoord
        }else{
            print("a")
        }
        
        contentBGView.frame = viewFrame
    }
    
    func makeKeywordButton(bgView: UIView?, keyword: String, size: CGSize) {
        if keyword == "더보기" {
            addMoreButton(bgView: bgView)
        }else {
            let textColor = isMe ? UIColor(rgba: "#726763") : UIColor(red: 236/255, green: 82/255, blue: 72/255, alpha: 1.0)
            let keywordButton = UIButton()
            
            keywordButton.frame = CGRect(x: sumKeywordsLength, y: 0, width: size.width + buttonInsetMargin, height: 27)
            keywordButton.addTarget(self, action: #selector(self.actionButton), for: .touchUpInside)
            keywordButton.isExclusiveTouch = true
            keywordButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            keywordButton.setTitleColor(textColor, for: UIControlState.normal)
            keywordButton.setTitle(keyword, for: UIControlState.normal)
            
            let imageSize = CGSize(width: normalImg!.size.width / 2, height: normalImg!.size.height / 2)
            if isMe {
                let resizeNormalImg = normalImg!.resizableImage(withCapInsets: UIEdgeInsetsMake(imageSize.height/2,imageSize.width/2,imageSize.height/2,imageSize.width/2))
                let resizeSelectImg = selectedImg!.resizableImage(withCapInsets: UIEdgeInsetsMake(imageSize.height/2,imageSize.width/2,imageSize.height/2,imageSize.width/2))
                
                keywordButton.setBackgroundImage(resizeNormalImg, for: UIControlState.normal)
                keywordButton.setBackgroundImage(resizeSelectImg, for: UIControlState.selected)
            }else {
                let resizeNormalImg = selectedImg!.resizableImage(withCapInsets: UIEdgeInsetsMake(imageSize.height/2,imageSize.width/2,imageSize.height/2,imageSize.width/2))
                let resizeSelectImg = normalImg!.resizableImage(withCapInsets: UIEdgeInsetsMake(imageSize.height/2,imageSize.width/2,imageSize.height/2,imageSize.width/2))
                
                keywordButton.setBackgroundImage(resizeNormalImg, for: UIControlState.normal)
                keywordButton.setBackgroundImage(resizeSelectImg, for: UIControlState.selected)
            }
            
            bgView?.addSubview(keywordButton)
            
            sumKeywordsLength += (size.width + keywordSpacing + buttonInsetMargin)
        }
    }
    
    func isOverLineMaxLength(keywordBGView: UIView?, keywordSize: CGFloat, lineNum: Int, curIndex: Int, totalCount: Int) -> Bool{
        var isOver: Bool = false
        var keywordsLength = sumKeywordsLength
        var isAddButtonMargin: CGFloat = 0
        if isFold && totalCount == curIndex {
            isAddButtonMargin = 46
        }
        
        keywordsLength += (keywordSize + keywordSpacing + buttonInsetMargin + isAddButtonMargin)
        
        if keywordsLength > limitLengthOneline {
            if isFold && totalCount + 1 == curIndex {
                addMoreButton(bgView: keywordBGView)
            }
            
            sumKeywordsLength = 0
            isOver = true
        }
        
        return isOver
    }
    
    @objc func actionMoreButton() {
        _app.viewDict[keywordType.rawValue] = nil
        delegate?.onClickMoreButton()
        guard let datas = _app.getProfileTypeCodes(type: keywordType) else {
            return
        }
        PopupListView().show(keywordType: keywordType, title: cardTitleLabel.text, data: datas, cancelButton: true, confirmAction: {
            [weak self] in
            if let wself = self {
                wself.updateKeyword?()
            }
        })
    }
    
    @objc func actionButton(_ sender: UIButton){
        if let title = sender.titleLabel?.text {
            delegate?.onClickKeywordButton(title: title)
        }
    }
    
    @IBAction func actionUpFold() {
        actionMoreButton()
    }
}
