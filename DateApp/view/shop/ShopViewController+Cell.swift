//
//  ShopViewController+Cell.swift
//  DateApp
//
//  Created by ryan on 1/16/16.
//  Copyright © 2016 iflet.com. All rights reserved.
//

import UIKit

// 상품 목록 tableviewcell
class ShopGoodsCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    static let ShopBird1Image = UIImage(assetIdentifier: .shopBird1)
    static let ShopBird2Image = UIImage(assetIdentifier: .shopBird2)
    static let ShopBird3Image = UIImage(assetIdentifier: .shopBird3)
    static let ShopBird4Image = UIImage(assetIdentifier: .shopBird4)
    static let ShopBirdNImage = UIImage(assetIdentifier: .shopBirdN)
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.isScrollEnabled = false
        _app.pointsViewModel.bind (view: self) { [weak self] (model, oldModel) -> () in
            self?.collectionView.reloadData()
        }
    }
}

class ShopGoodsCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bonusLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var eventBonusLabel: UILabel!
    @IBOutlet weak var eventBonusLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var priceTopMarign: NSLayoutConstraint!
    
    var pointModel: PointModel? {
        didSet {
            guard let pointModel = pointModel else {
                return
            }
            
            eventImageView.isHidden = true
            eventBonusLabel.isHidden = true
            eventBonusLabelHeight.constant = isEventMode ? 21 : 0
            priceTopMarign.constant = 0
            
            switch pointModel.identifier {
            case .Point30, .Point30Event:
                coverImageView.image = ShopGoodsCell.ShopBird1Image
                eventImageView.isHidden = !isEventMode
                eventBonusLabel.isHidden = !isEventMode
                priceTopMarign.constant = isEventMode ? 21 : 0
            case .Point80:
                coverImageView.image = ShopGoodsCell.ShopBird2Image
            case .Point150, .Point150Event:
                coverImageView.image = ShopGoodsCell.ShopBird3Image
                eventImageView.isHidden = !isEventMode
                eventBonusLabel.isHidden = !isEventMode
                priceTopMarign.constant = isEventMode ? 21 : 0
            case .Point300:
                coverImageView.image = ShopGoodsCell.ShopBird4Image
            case .Point600, .Point600Event:
                coverImageView.image = ShopGoodsCell.ShopBirdNImage
                eventImageView.isHidden = !isEventMode
                eventBonusLabel.isHidden = !isEventMode
                priceTopMarign.constant = isEventMode ? 21 : 0
            }
            titleLabel.text = "\(pointModel.pointCount)개"
            
            let bonusStr = "보너스 +\(pointModel.bonusCount)"
            if isEventMode &&
                (pointModel.identifier == .Point30 ||
                    pointModel.identifier == .Point150 ||
                    pointModel.identifier == .Point600 ||
                    pointModel.identifier == .Point30Event  ||
                    pointModel.identifier == .Point150Event ||
                    pointModel.identifier == .Point600Event ){
                let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: bonusStr)
    
                attributeString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
                
                bonusLabel.attributedText = attributeString
            }else {
                bonusLabel.text = bonusStr
            }
            
            eventBonusLabel.text = "보너스 +\(pointModel.promotionCount)"
            priceLabel.text = pointModel.priceString
            self.layoutIfNeeded()
        }
    }
    
    var isEventMode: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        coverImageView.makeCircleStyleWithBorder(borderWidth: 1.0, borderColor: UIColor(rgba: "#f2523d"))
        titleLabel.makeHCircleStyle()
    }
}
