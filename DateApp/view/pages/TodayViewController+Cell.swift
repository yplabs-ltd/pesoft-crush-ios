//
//  TodayViewController+Cell.swift
//  DateApp
//
//  Created by ryan on 12/13/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit

final class TodayMoreCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

final class TodayCardCell: UITableViewCell {
    
    @IBOutlet weak var remainTimeButton: UIButton!
    @IBOutlet weak var profileImageButtonContainer: UIView!
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    
    @IBOutlet var popularBulletLabel: UILabel!    // 인기 마크
    
    private let defaultBorderColor = UIColor(rgba: "#e3e1e0")
    private let highlightBorderColor = UIColor(rgba: "#f2503b")
    
    private let defaultProfileImage = UIImage(assetIdentifier: UIImage.AssetIdentifier.HomeThumbnailDefault)
    
    var rowIndex: Int = 0
    var updateRemainTime: ((String) -> Void)?
    
    var model: CardModel? {
        didSet {
            guard let model = model else {
                return
            }
            
            profileImageButton.tag = model.id ?? -1 // userid 파라미터 전달을 위한 tag 활용
            titleLabel.text = model.name
            subTitleLabel.text = "\(model.birthDate?.ageFromBirthDate ?? ""), \(model.job?.extra ?? "")"
            if let h = model.height, let b = model.bodyType?.value {
                jobLabel.text = "\(Int(h))cm, \(b)"
            } else if let h = model.height {
                jobLabel.text = "\(Int(h))cm"
            }else if let b = model.bodyType?.value {
                jobLabel.text = "\(b)"
            }
            
            if model.grade == "E" || model.grade == "P" {
                // 인기 회원 특수 처리 (border 붉은 색)
                profileImageButtonContainer.makeCircleStyleWithBorder(borderWidth: 1.0, borderColor: highlightBorderColor)
                popularBulletLabel.isHidden = false
                titleLabel.textColor = UIColor(red: 236/255, green: 82/255, blue: 66/255, alpha: 1.0)
                subTitleLabel.textColor = UIColor(red: 236/255, green: 82/255, blue: 66/255, alpha: 1.0)
                jobLabel.textColor = UIColor(red: 236/255, green: 82/255, blue: 66/255, alpha: 1.0)
            } else {
                profileImageButtonContainer.makeCircleStyleWithBorder(borderWidth: 1.0, borderColor: defaultBorderColor)
                popularBulletLabel.isHidden = true
                titleLabel.textColor = UIColor(red: 95/255, green: 84/255, blue: 80/255, alpha: 1.0)
                subTitleLabel.textColor = UIColor(red: 95/255, green: 84/255, blue: 80/255, alpha: 1.0)
                jobLabel.textColor = UIColor(red: 95/255, green: 84/255, blue: 80/255, alpha: 1.0)
            }
            
            if let mainImage = model.mainImage {
                profileImageButton.setImage(mainImage, for: .normal)
            } else {
                // 기본 이미지 세팅 후 download
                profileImageButton.setImage(defaultProfileImage, for: .normal)
                if let url = model.mainImageUrl {
                    setProfileImageFromUrl(url: url)
                }
            }
            
            // 갱신 남은시간 표시
            changeRemainTimeTextForNow(now: Date())
        }
    }
    
    var expiredTimeHidden: Bool = false {
        didSet {
            if !expiredTimeHidden {
                remainTimeButton.isHidden = false
            } else {
                remainTimeButton.isHidden = true
            }
        }
    }
    
    private func changeRemainTimeTextForNow(now: Date) {
        if let expiredDttm = model?.expiredDttm {
            
            let interval = NSDate().timeIntervalSince(expiredDttm)
            let elapse = String.stringHourMinFromTimeInterval(interval: interval, isFirstCell: (rowIndex == 0), expireDate: (rowIndex == 0) ? nil : expiredDttm)
            
            // 시간 표시할때 ":" 깜빡이는 표시 줌
            /*
            if let title = remainTimeButton.currentTitle , title.rangeOfString(":") != nil {
                elapse = elapse.stringByReplacingOccurrencesOfString(":", withString: " ")
            }*/
            self.remainTimeButton.setTitle(elapse, for: UIControlState.normal)
            updateRemainTime?(elapse)
            
            /*
            UIView.performWithoutAnimation({ () -> Void in
                self.remainTimeButton.setTitle(elapse, for: UIControlState.normal)
                self.remainTimeButton.layoutIfNeeded()
            })*/
        }
    }
    
    private func setProfileImageFromUrl(url: String) {
        
        let loadingViewModel = LoadingViewModelBuilder(superview: profileImageButton).viewModel
        let responseViewModel = DViewModel<ApiResponse>(self, { [weak self] (model, oldModel) -> () in
            guard let apiResponse = model, let data = apiResponse.model as? Data else {
                return
            }
            self?.profileImageButton.setImage(UIImage(data: data), for: .normal)
            })
        let _ = _app.api.download(url: url, apiResponseViewModel: responseViewModel, loadingViewModel: loadingViewModel)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 남은시간 원형으로 조정
        remainTimeButton.makeCircleStyleWithBorder(borderWidth: 1.0, borderColor: UIColor(rgba: "#e7e5e4"))
        
        // 남은시간 갱신
        _app.secondViewModel.bind (view: self) { [weak self] (model, oldModel) -> () in
            guard let now = model else {
                return
            }
            self?.changeRemainTimeTextForNow(now: now)
        }
        
        // 프로필 사진 원형으로 조정, border 추가
        profileImageButtonContainer.makeCircleStyleWithBorder(borderWidth: 1.0, borderColor: defaultBorderColor)
        
        profileImageButton.makeCircleStyle()
        profileImageButton.setImage(UIImage(assetIdentifier: .BlankImage), for: UIControlState.normal)
        
        popularBulletLabel.backgroundColor = highlightBorderColor
        popularBulletLabel.layer.cornerRadius = popularBulletLabel.frame.size.height / 2
        popularBulletLabel.layer.masksToBounds = true
        
        // 인기 마크
        /*
        
        popularBulletLabel.text = "우수"
        popularBulletLabel.font = UIFont.systemFont(ofSize: 12)
        popularBulletLabel.backgroundColor = highlightBorderColor
        popularBulletLabel.textColor = UIColor.white
        popularBulletLabel.textAlignment = NSTextAlignment.Center
        popularBulletLabel.makeHCircleStyle()
        popularBulletLabel.isHidden = true
        addSubview(popularBulletLabel)
        
        addConstraints(DConstraintsBuilder()
            .addView(popularBulletLabel, name: "popularBulletLabel")
            .addVFS(
                "H:[popularBulletLabel(46)]",
                "V:[popularBulletLabel(18)]"
            ).constraints)
        let consts = [
            NSLayoutConstraint(item: popularBulletLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: -75.0),
            NSLayoutConstraint(item: popularBulletLabel, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0)
        ]
        addConstraints(consts)
        */
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
