//
//  VerifyViewController.swift
//  vegas-ios
//
//  Created by Lim Daehyun on 2018. 1. 24..
//  Copyright © 2018년 refactoring. All rights reserved.
//
import UIKit
import Foundation

struct BottomButtonInfo {
    let bgColor: UIColor!
    let title: String!
    let titleStyle: LabelStyle!
}

class VerifyViewController: UIViewController {
    let cellItemHeight: CGFloat = 75
    var headerView: UIView!
    var bottomButton: UIButton!
    var colletionView: UICollectionView!
    var isUseHeaderView: Bool = true
    var verifyViewModel: VerifyViewModel!
    var bottomButtonInfo: BottomButtonInfo? {
        didSet {
            if let i = bottomButtonInfo {
                bottomButton.backgroundColor = i.bgColor
                bottomButton.titleLabel?.setLabelStyle(style: i.titleStyle)
                bottomButton.setTitle(i.title, for: .normal)
            }
            updateBottomButtonFrame()
        }
    }
    
    var collectionHeaderViewHeight: CGFloat = 180 {
        didSet {
            updateCollectionViewFrame()
        }
    }
    
    var collectionFooterViewHeight: CGFloat = 115 {
        didSet {
            colletionView.reloadData()
        }
    }
    
    var titleLabelStyle: LabelStyle = LabelStyle(font: UIFont.systemFont( ofSize: 30), normalColor: UIColor.white, highlightColor: nil)
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardNotification),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc func keyboardNotification(_ notification: NSNotification) {
        if let userInfo = notification.userInfo,
            let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var viewFrame = self.view.frame
            viewFrame.size.height = keyboardEndFrame.origin.y
            self.view.frame = viewFrame
        }
    }
}

extension VerifyViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    override func viewDidLoad() {
        super.viewDidLoad()
        addNotification()
        makeViews()
    }
    
    func makeViews() {
        let bounds = UIScreen.main.bounds
        headerView = UIView()
        self.view.addSubview(headerView)
        headerView.backgroundColor = UIColor.clear
        headerView.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top)
            make.leading.equalTo(0)
            make.trailing.equalTo(0)
            make.height.equalTo(isUseHeaderView ? 44 : 0)
        }
//        headerView.onClickLeftButton = { [weak self] in
//            guard let wself = self else { return }
//            wself.navigationController?.popViewControllerAnimated(true)
//        }
        
        bottomButton = UIButton()
        bottomButton.addTarget(self, action: #selector(self.pressedBottomButton), for: UIControlEvents.touchUpInside)
        view.addSubview(bottomButton)
        
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: bounds.width, height: cellItemHeight)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        colletionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        colletionView.backgroundColor = UIColor.clear
        colletionView.register(VerifyCell.self, forCellWithReuseIdentifier: "VerifyCell")
        colletionView.register(UINib(nibName: "SelectGenderCell", bundle: nil), forCellWithReuseIdentifier: "SelectGenderCell")
        colletionView.register(VerifyViewHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "VerifyViewHeader")
        colletionView.register(VerifyViewFooter.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "VerifyViewFooter")

        colletionView.delegate = self
        colletionView.dataSource = self
        view.addSubview(colletionView)
        updateCollectionViewFrame()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        colletionView.reloadData()
        setHeaderStyle()
    }
    
    func pressedButtonMenu(index: Int) { }
    
    @objc func pressedBottomButton() { }
    
    func hideKeyboard() {
        colletionView.visibleCells.forEach({ (cell) in
            guard let c = cell as? VerifyCell else {
                return
            }
            c.hideKeyboard()
        })
    }
    private func updateBottomButtonFrame() {
        bottomButton.snp.updateConstraints { (make) in
            make.bottom.equalTo(view.snp.bottom)
            make.leading.equalTo(0)
            make.trailing.equalTo(0)
            make.height.equalTo(bottomButtonInfo == nil ? 0 : 45)
        }
    }

    
    private func updateCollectionViewFrame() {
        colletionView.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.equalTo(0)
            make.trailing.equalTo(0)
            make.bottom.equalTo(bottomButton.snp.top)
        }
    }
    
    private func setHeaderStyle() {
//        headerView.leftButtonInfo = verifyViewModel.headerItems.first
//        headerView.rightButtonInfo = verifyViewModel.headerItems.last
    }
}

extension VerifyViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            
            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "VerifyViewHeader", for: indexPath as IndexPath) as! VerifyViewHeader
            reusableview.title = self.title
            reusableview.titleLabelStyle = self.titleLabelStyle
            return reusableview
        case UICollectionElementKindSectionFooter:
            
            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "VerifyViewFooter", for: indexPath as IndexPath) as! VerifyViewFooter
            return reusableview

        default:  fatalError("Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionHeaderViewHeight)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.verifyViewModel.verifyItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard self.verifyViewModel.verifyItems.count > indexPath.row else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        }
        let info = self.verifyViewModel.verifyItems[indexPath.row]
        
        guard let item = info.item else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        }
        let cellIdentifier = (item == VerifyItem.ItemType.selectGender) ? "SelectGenderCell" : "VerifyCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        cell.backgroundColor = UIColor.clear
        
        switch cell {
        case is VerifyCell:
            (cell as! VerifyCell).onProcessVerify = { [weak self] text in
                guard let wself = self else { return }
                let _ = wself.verifyViewModel.updateContentWithIndex(index: indexPath.row, content: text)
                wself.verifyViewModel.requestToVerify(target: text, type: info.item, onStart: nil, onSuccess: nil, onFail: nil, onFinish: nil)
            }
            
            (cell as! VerifyCell).onPressedButton = { [weak self] in
                guard let wself = self else { return }
                wself.pressedButtonMenu(index: indexPath.row)
            }
            (cell as! VerifyCell).setItem(info: info)
        case is SelectGenderCell:
            (cell as! SelectGenderCell).onSelectGender = { [weak self] text in
                guard let wself = self else { return }
                let _ = wself.verifyViewModel.updateContentWithIndex(index: indexPath.row, content: text)
            }
            
            if let c = info.content {
                if let g = SelectedGender(rawValue: c) {
                    (cell as! SelectGenderCell).selectedGender = g
                }
            }
        default:()
            
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width, height: cellItemHeight)
    }
}

class VerifyViewHeader: UICollectionReusableView {
    var titleLabelTopMargin: CGFloat = 68 {
        didSet {
            updateTitleLabelPosition()
        }
    }
    var titleLabelStyle: LabelStyle = LabelStyle(font: UIFont.systemFont( ofSize: 30), normalColor: UIColor.white, highlightColor: nil) {
        didSet {
            titleLabel.font = titleLabelStyle.font
            titleLabel.textColor = titleLabelStyle.normalColor
        }
    }
    var title: String? {
        didSet {
            if titleLabel == nil {
                titleLabel = UILabel()
                titleLabel.setLabelStyle(style: titleLabelStyle)
                addSubview(titleLabel)
                updateTitleLabelPosition()
            }
            titleLabel.text = title
        }
    }
    private var titleLabel: UILabel!
    
    var image: UIImage? {
        didSet {
            if imageView == nil {
                imageView = UIImageView()
                addSubview(imageView)
                updateImageViewPosition()
            }
            imageView.image = image
            updateImageViewPosition()
        }
    }
    private var imageView: UIImageView!
    
    private func updateTitleLabelPosition() {
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top).offset(titleLabelTopMargin)
            make.leading.equalTo(15)
            make.trailing.equalTo(15)
            make.height.equalTo(35)
        }
    }
    
    private func updateImageViewPosition() {
        guard let i = image else {
            return
        }
        imageView.snp.updateConstraints { (make) in
            make.top.equalTo(self.snp.top).offset(60)
            make.height.equalTo(i.size.height)
            make.width.equalTo(i.size.width)
            make.centerX.equalTo(self)
        }
    }
}

class VerifyViewFooter: UICollectionReusableView {
}
