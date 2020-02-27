//
//  MyRankDetailCell.swift
//  DateApp
//
//  Created by Daehyun Lim on 2018. 5. 20..
//  Copyright © 2018년 iflet.com. All rights reserved.
//

import Foundation


class MyRankDetailCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var moreBGView: UIView!
    
    var onSelectedItem: ((Int) -> Void)?
    
    var moreSegue: DSegue?
    var parentController: MyDetailRankViewController?
    var voiceLikeModels: [VoiceLikedModel] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    var fromType: String?   // 지나간카드목록일경우 H (자나간 카드일때는 좋아요 10버찌 차감)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        moreBtn.layer.cornerRadius = moreBtn.frame.size.height / 2
        moreBtn.layer.borderWidth = 1
        moreBtn.layer.borderColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0).cgColor
    }
    
    @IBAction func more() {
        moreSegue?.perform()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func enableMoreButton(isEnable: Bool) {
        moreBGView.isHidden = !isEnable
    }
    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = min(voiceLikeModels.count, 6)
        return count == 0 ? 1 : count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if voiceLikeModels.count == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyLikeCell", for: indexPath)
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! NewsProfileCollectionCell
        cell.cardModel = voiceLikeModels[indexPath.item].convertCardModel()
        cell.fromType = fromType
        cell.dDayLabel.isHidden = !(cell.cardModel?.isFuture ?? false)
        cell.enableBlueProfileImageView(isEnable: cell.cardModel?.isHidden ?? false)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let rankInfo = voiceLikeModels[indexPath.item].convertCardModel()
        if rankInfo.isFuture {
            onSelectedItem?(indexPath.row)
        }else {
            Toast.showToast(message: "프로필 열람 기한이 지났습니다.", duration: 0.3)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.size.width
        return CGSize(width: voiceLikeModels.count == 0 ? screenWidth : 94, height: voiceLikeModels.count == 0 ? 75 : 164)
    }
}

