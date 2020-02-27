//
//  NewsListViewController+Cell.swift
//  DateApp
//
//  Created by ryan on 12/20/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit

class NewsHeaderView: UIView {
    let titleImageView: UIImageView!
    var moreButton: UIButton!
    var moreSegue: DSegue?
    let itemMoreCount = 6   // 6개 이상일때만 더보기 버튼 보임
    
    init(titleImage: UIImage, itemCount: Int) {
        titleImageView = UIImageView(image: titleImage)
        super.init(frame: CGRect.zero)
        
        backgroundColor = UIColor.white
        
        titleImageView.frame.origin = CGPoint(x: 16, y: 25)
        titleImageView.sizeToFit()
        addSubview(titleImageView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func more(sender: AnyObject?) {
        moreSegue?.perform()
    }
}

class NewsTableCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var moreBGView: UIView!
    var moreSegue: DSegue?
    var parentController: NewsListViewController?
    var cardModels: [CardModel] = [] {
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
        return min(cardModels.count, 6)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! NewsProfileCollectionCell
        
        var cardObj = cardModels[indexPath.item]
        if cardObj.isHidden == true {
            
            print("a")
        }
        cell.cardModel = cardModels[indexPath.item]
        cell.fromType = fromType
        cell.enableBlueProfileImageView(isEnable: false)
        if let isHiddenBlurImage = cell.cardModel?.isHidden {
            cell.enableBlueProfileImageView(isEnable: isHiddenBlurImage)
        }
        cell.enableNewBadge = cardModels[indexPath.item].newlikecheck
        return cell
    }
}


class NewsProfileCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImageContainerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileBlurImageView: UIImageView!
    @IBOutlet weak var dDayLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var newBadgeLabel: UILabel!
    
    var enableNewBadge: Bool = false {
        didSet {
            if newBadgeLabel != nil {
                newBadgeLabel.isHidden = !enableNewBadge
            }
        }
    }
    var profileBlurImage: UIImage? = nil
    
    var cardModel: CardModel? {
        didSet {
            guard var cardModel = cardModel else {
                return
            }
            
            self.profileImageView.image = nil
            if profileBlurImageView != nil {
                self.profileBlurImageView.image = nil
            }

            enableBlueProfileImageView(isEnable: false)
            
            if var url = cardModel.mainImageUrl {
                let responseViewModel = ApiResponseViewModelBuilder<Data>(successHandler: { [weak self] (data) -> Void in
                    self?.profileImageView.image = UIImage(data: data)
                    if cardModel.isHidden == true {
                        self!.loadProfileImage(url: url, cardModel: cardModel)
                    }
                }).viewModel
                let loadingViewModel = LoadingViewModelBuilder(superview: profileImageView).viewModel
                let _ = _app.api.download(url: url, apiResponseViewModel: responseViewModel, loadingViewModel: loadingViewModel)
            }
            dDayLabel.text = cardModel.expiredString
            titleLabel.text = cardModel.name
            var ageString = ""
            if let age = cardModel.birthDate?.ageFromBirthDate {
                ageString = "\(age), "
            }
            subTitleLabel.text = "\(ageString)\(cardModel.hometown?.value ?? "")"
            profileImageContainerView.layer.borderColor = UIColor(rgba: "#e3e1e0").cgColor
            if cardModel.isILike == true {
                switch cardModel.reply {
                case .Accept:
                    stateLabel.isHidden = false
                    stateLabel.text = "성공   "
                    stateLabel.backgroundColor = UIColor(rgba: "#ef5142")
                case .Reject:
                    stateLabel.isHidden = false
                    stateLabel.text = "실패   "
                    stateLabel.backgroundColor = UIColor(rgba: "#c0bcbb")
                default:
                    stateLabel.isHidden = false
                    stateLabel.text = cardModel.isLikeCheck == true ? "좋아요 확인   " : "진행중   "
                    stateLabel.backgroundColor = UIColor(rgba: "#726763")
                }
            } else {
                stateLabel.isHidden = true
            }
            
            if let voiceUrl = cardModel.likeMeVoiceMessage , voiceUrl.length > 0 {
                profileImageContainerView.layer.borderColor = UIColor(r: 242, g: 80, b: 59).cgColor
            }
        }
    }
    
    func loadProfileImage(url: String, cardModel: CardModel){
        var profileBlurImage: UIImage = self.profileImageView.image!
        
        let fileName = "Blur" + url.components(separatedBy:"/").last! + ".jpg"
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        
        let filePathToWrite = "\(paths)/" + fileName
        
        let getImagePath = (paths as NSString).appendingPathComponent(fileName)
        if (fileManager.fileExists(atPath: getImagePath)) {
            profileBlurImage = UIImage(named: filePathToWrite)!
        }
        else {
            profileBlurImage = (self.profileImageView.image?.applyLightEffect())!
            
            let jpgImageData = UIImageJPEGRepresentation(profileBlurImage, 1.0)
            fileManager.createFile(atPath: filePathToWrite, contents: jpgImageData, attributes: nil)
            if let url = URL(string: filePathToWrite) {
                do {
                    try UIImageJPEGRepresentation(profileBlurImage, 1.0)?.write(to: url)
                }catch {
                    
                }
            }
        }
        
        self.profileBlurImageView.image = profileBlurImage
    }
    
    func enableBlueProfileImageView(isEnable: Bool) {
        if profileBlurImageView != nil {
            profileBlurImageView.isHidden = !isEnable
        }
    }
    
    var fromType: String?   // 지나간카드목록일경우 H (자나간 카드일때는 좋아요 10버찌 차감)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if newBadgeLabel != nil {
            newBadgeLabel.makeCircleStyle()
            newBadgeLabel.isHidden = true
        }
        
        
        if profileBlurImageView != nil {
            profileBlurImageView.layer.cornerRadius = profileBlurImageView.frame.size.width / 2
            profileBlurImageView.layer.masksToBounds = true
        }
        
        profileImageContainerView.makeCircleImageContainerWithBorder(borderWidth: 1.0, borderColor: UIColor(rgba: "#e3e1e0"))
        
        dDayLabel.makeCircleStyleWithBorder(borderWidth: 1.0, borderColor: UIColor(rgba: "#e3e1e0"))
        
        // round 처리
        stateLabel.layer.cornerRadius = stateLabel.frame.size.height / 2
        stateLabel.layer.masksToBounds = true
    }
}
