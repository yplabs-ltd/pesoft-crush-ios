//
//  CardDetailTableViewController.swift
//  DateApp
//
//  Created by ryan on 12/21/15.
//  Copyright © 2015 iflet.com. All rights reserved.
//

import UIKit
import AVFoundation
import SDWebImage

class CardDetailTableViewController: UITableViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate, UICollectionViewDelegateFlowLayout {
    private var profileSegue: DSegue!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileImageCollectionView: UICollectionView!
    @IBOutlet weak var voicelikePlayButtonTop: NSLayoutConstraint!
    @IBOutlet weak var thumbnailContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var thumbnail1Button: UIButton!
    @IBOutlet weak var thumbnail2Button: UIButton!
    @IBOutlet weak var thumbnail3Button: UIButton!
    @IBOutlet weak var thumbnail4Button: UIButton!
    @IBOutlet weak var thumbnail5Button: UIButton!
    @IBOutlet weak var thumbnail6Button: UIButton!
    @IBOutlet weak var headLineLabel: UILabel!
    @IBOutlet weak var subLineLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!           // 제가 꿈에 그리던 이상형이시네요
    @IBOutlet weak var messageLabelBGView: UIView!
    @IBOutlet weak var messageToggleButton: UIButton!
    @IBOutlet weak var voicelikePlayButton: UIButton!
    
    @IBOutlet weak var messageBGHeight: NSLayoutConstraint!
    let cellForCheckSize = NowNearKeywordTableViewCell()

    var soundPlayer : AVAudioPlayer!
    var updater : CADisplayLink!
    
    var progress : KDCircularProgress!
    var voiceLikeProgress : KDCircularProgress!
    
    func getProfileInfo() {
        let responseViewModel = ApiResponseViewModelBuilder<ProfileModel>(successHandlerWithDefaultError: { (profileModel) -> Void in
            _app.profileViewModel.model = profileModel
        }).viewModel
        let _ = _app.api.profileEdit(apiResponseViewModel: responseViewModel, loadingViewModel: _app.loadingViewModel)
    }
    
    @IBAction func toggleMessage(sender: AnyObject) {
        messageLabel.isHidden = !messageLabel.isHidden
        messageLabelBGView.isHidden = messageLabel.isHidden
        if messageLabel.isHidden {
            messageToggleButton.setImage(detailsBtnChatImage, for: UIControlState.normal)
        } else {
            messageToggleButton.setImage(detailsBtnChatCloseImage, for: UIControlState.normal)
        }
    }
    
    @IBAction func onPressedVoiceLikeMessage(sender: AnyObject) {
        if soundPlayer != nil && soundPlayer.isPlaying {
            voiceLikeMessageStop()
        } else {
            voiceLikeMessagePlayVoiceURL()
        }
    }
    
    
    @IBAction func thumbnailTouchUpInside(sender: AnyObject) {
        guard let imageInfoList = profileImagesViewModel.model else {
            return
        }
        guard let index = sender.tag , index - 1 < imageInfoList.count else {
            return
        }
        
        guard index - 1 >= 0 else {
            // Voice
            guard _app.profileViewModel.model?.voiceUrl != nil else {
                confirm(title: "상대의 목소리를 들어보실래요?", message: "상대의 목소리를 듣기 위해선 회원님의\n자기 소개 목소리 등록이 필요해요!\n등록하러 가실래요?") { (action) -> Void in
                    self.profileSegue.perform()
                }
                return
            }
            
            if soundPlayer != nil && soundPlayer.isPlaying {
                stop()
            } else {
                playVoiceURL()
            }

            return
        }
        
        
        
        let indexPath = IndexPath(row: index - 1, section: 0)
        selectedThumbnail(index: indexPath.row)
        profileImageCollectionView.scrollToItem(at: indexPath, at: .right, animated: false)
        
        /*
        let imageInfo = imageInfoList[index - 1]
        if let hidden = imageInfo.hidden , hidden == true {
            // 유료 결제 필요함
            unlockImageSegue.perform()
            _app.ga.trackingEventCategory(category:"user_detail", action: "photo_more", label: "try")
        } else {
            if let largeImageUrl = imageInfo.largeImageUrl {
                setProfileImageFromUrl(largeImageUrl)
            } else if let imageUrl = imageInfo.imageUrl {
                setProfileImageFromUrl(imageUrl)
            }
        }*/
    }
    
    private var unlockImageSegue: DSegue!
    private var profileImagesViewModel = DViewModel<[ProfileModel.ImageInfo]>() // profile image 목록
    
    private let detailsBtnChatImage = UIImage(assetIdentifier: .detailsBtnChat)
    private let detailsBtnChatCloseImage = UIImage(assetIdentifier: .detailsBtnChatClose)
    private let profileLockImage = UIImage(assetIdentifier: .Profilelock)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getProfileInfo()
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)

        self.tableView.register(NowNearKeywordTableViewCell.self, forCellReuseIdentifier: "keywordCell")
        self.tableView.register(UINib(nibName: "NowNearKeywordTableViewCell", bundle: nil) , forCellReuseIdentifier: "keywordCell")
        
        messageToggleButton.setImage(detailsBtnChatImage, for: UIControlState.normal)
        
        thumbnail1Button.makeCircleStyle()
        thumbnail2Button.makeCircleStyleWithBorder(borderWidth:1.0, borderColor: UIColor(rgba: "#e3e1e0"))
        thumbnail3Button.makeCircleStyleWithBorder(borderWidth:1.0, borderColor: UIColor(rgba: "#e3e1e0"))
        thumbnail4Button.makeCircleStyleWithBorder(borderWidth:1.0, borderColor: UIColor(rgba: "#e3e1e0"))
        thumbnail5Button.makeCircleStyleWithBorder(borderWidth:1.0, borderColor: UIColor(rgba: "#e3e1e0"))
        thumbnail6Button.makeCircleStyleWithBorder(borderWidth:1.0, borderColor: UIColor(rgba: "#e3e1e0"))
        
        // thumbnail 은 처음에 안보이고 데이터확인 후 보이게 한다.
        thumbnail1Button.isHidden = true
        thumbnail2Button.isHidden = true
        thumbnail3Button.isHidden = true
        thumbnail4Button.isHidden = true
        thumbnail5Button.isHidden = true
        thumbnail6Button.isHidden = true
        
        // progress
        progress = KDCircularProgress()
        thumbnail1Button.addSubview(progress)
        
        progress.snp.makeConstraints { (make) in
            make.left.equalTo(thumbnail1Button)
            make.right.equalTo(thumbnail1Button)
            make.top.equalTo(thumbnail1Button)
            make.bottom.equalTo(thumbnail1Button)
            make.leftMargin.equalTo(thumbnail1Button)
            make.rightMargin.equalTo(thumbnail1Button)
            make.topMargin.equalTo(thumbnail1Button)
        }
        progress.trackColor = UIColor(red: 227/255, green: 225/255, blue: 224/255, alpha: 1.0)
        progress.startAngle = -90
        progress.progressThickness = 0.1
        progress.trackThickness = 0.02
        progress.clockwise = true
        progress.gradientRotateSpeed = 2
        progress.roundedCorners = true
        progress.angle = 0
        progress.trackColor = UIColor(red: 227/255, green: 225/255, blue: 224/255, alpha: 1.0)
        progress.setColors(colors: UIColor.white)
        // voice like progrss 
        voiceLikeProgress = KDCircularProgress()
        voicelikePlayButton.addSubview(voiceLikeProgress)
        
        voiceLikeProgress.snp.makeConstraints { (make) in
            make.left.equalTo(voicelikePlayButton)
            make.right.equalTo(voicelikePlayButton)
            make.top.equalTo(voicelikePlayButton)
            make.bottom.equalTo(voicelikePlayButton)
            make.leftMargin.equalTo(voicelikePlayButton)
            make.rightMargin.equalTo(voicelikePlayButton)
            make.topMargin.equalTo(voicelikePlayButton)
        }
        voiceLikeProgress.trackColor = UIColor(red: 227/255, green: 225/255, blue: 224/255, alpha: 1.0)
        voiceLikeProgress.startAngle = -90
        voiceLikeProgress.progressThickness = 0.1
        voiceLikeProgress.trackThickness = 0.02
        voiceLikeProgress.clockwise = true
        voiceLikeProgress.gradientRotateSpeed = 2
        voiceLikeProgress.roundedCorners = true
        voiceLikeProgress.angle = 0
        voiceLikeProgress.setColors(colors: UIColor.white)
        
        // profile segue
        profileSegue = DSegue(source: self, destination: { () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Profile", identifier: "ProfileViewController")
            let style = DSegueStyle.Show(animated: true)
            return (destination, style)
        })
        
        // segue
        unlockImageSegue = DSegue(source: self, destination: { [weak self] () -> (destination: UIViewController, style: DSegueStyle)? in
            let destination = UIViewController.viewControllerFromStoryboard(name: "Popup", identifier: "ConfirmPopupController") as! ConfirmPopupController
            let style = DSegueStyle.PresentPopup(sizeHandler: { (parentSize) -> CGSize in
                return CGSize(width: 294.0, height: 172.0)
            })
            destination.line1 = ("상대방의 사진을 더 볼까요?", .Title)
            destination.line2 = ("(TIP.자신이 올린 사진만큼 무료로 볼수 있어요)", .Title)
            destination.line3 = ("1버찌 필요", .Red)
            destination.submitHandler = { (popup: UIViewController) -> Void in
                popup.dismiss(animated:true, completion: { () -> Void in
                    self?.unlock1Image()
                })
                
                _app.ga.trackingEventCategory(category:"user_detail", action: "photo_more", label: "confirm")
            }
            return (destination, style)
            })
        
        // 프로필 이미지 목록
        profileImagesViewModel.bind (view: self) { [weak self] (model, oldModel) -> () in
            guard let wself = self else { return }
            guard let profileImages = model else {
                return
            }
            
            guard let weakSelf = self else {
                return
            }
            wself.profileImageCollectionView.reloadData()
            wself.thumbnail1Button.isHidden = _app.cardDetailViewModel.model?.profileModel?.voiceUrl == nil
            if wself.thumbnail1Button.isHidden == false {
                wself.thumbnail1Button.setImage(UIImage(named: "btnMyPlay"), for: UIControlState.normal)
            }
            
            // thumbnail 이미지 설정
            for (index, imageInfo) in profileImages.enumerated() {
                switch index {
                case 0:
                    weakSelf.thumbnail2Button.isHidden = false
                    if let image = imageInfo.image, let hidden = imageInfo.hidden , hidden == false {
                        weakSelf.thumbnail2Button.setImage(image, for: UIControlState.normal)
                    } else {
                        weakSelf.thumbnail2Button.setImage(self?.profileLockImage, for: UIControlState.normal)
                    }
                    self?.selectedThumbnail(index: 0)
                case 1:
                    weakSelf.thumbnail3Button.isHidden = false
                    if let image = imageInfo.image, let hidden = imageInfo.hidden , hidden == false  {
                        weakSelf.thumbnail3Button.setImage(image, for: UIControlState.normal)
                    } else {
                        weakSelf.thumbnail3Button.setImage(self?.profileLockImage, for: UIControlState.normal)
                    }
                case 2:
                    weakSelf.thumbnail4Button.isHidden = false
                    if let image = imageInfo.image, let hidden = imageInfo.hidden , hidden == false  {
                        weakSelf.thumbnail4Button.setImage(image, for: UIControlState.normal)
                    } else {
                        weakSelf.thumbnail4Button.setImage(self?.profileLockImage, for: UIControlState.normal)
                    }
                case 3:
                    weakSelf.thumbnail5Button.isHidden = false
                    if let image = imageInfo.image, let hidden = imageInfo.hidden , hidden == false  {
                        weakSelf.thumbnail5Button.setImage(image, for: UIControlState.normal)
                    } else {
                        weakSelf.thumbnail5Button.setImage(self?.profileLockImage, for: UIControlState.normal)
                    }
                case 4:
                    weakSelf.thumbnail6Button.isHidden = false
                    if let image = imageInfo.image, let hidden = imageInfo.hidden , hidden == false  {
                        weakSelf.thumbnail6Button.setImage(image, for: UIControlState.normal)
                    } else {
                        weakSelf.thumbnail6Button.setImage(self?.profileLockImage, for: UIControlState.normal)
                    }
                default:
                    break
                }
            }
            weakSelf.setThumbnailContainerWidth()
        }
        voicelikePlayButton.setImage(UIImage(named: "btnMyPlay"), for: UIControlState.normal)
        // 프로필 데이터 채우기
        _app.cardDetailViewModel.bind (view: self) { [weak self] (model, oldModel) -> () in
            guard let weakSelf = self else {
                return
            }
            guard let cardModel = model, let profileModel = cardModel.profileModel else {
                return
            }
            
            if let voiceUrl = cardModel.likeMeVoiceMessage , voiceUrl.length > 0 {
                weakSelf.voicelikePlayButton.isHidden = false
                if let likeMessage = cardModel.likeMeMessage , likeMessage.trim() != "" {
                    weakSelf.voicelikePlayButtonTop.constant = 42
                }else {
                    weakSelf.voicelikePlayButtonTop.constant = 10
                }
            }else {
                weakSelf.voicelikePlayButton.isHidden = true
            }
            
            // 메시지는 기본적으로 감추고 나를 좋아하는 사람이 메시지를 보낸 경우 보여줌
            if cardModel.isLikeMe == true, var likeMessage = cardModel.likeMeMessage , likeMessage.trim() != "" {
                let likeMessageSize = likeMessage.boundingRect(with: CGSize(width: getScreenSize().width - 50, height: 10000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [.font: (self?.messageLabel.font)!], context: nil).size
                
                if likeMessageSize.height + 10 > 40 {
                    weakSelf.messageBGHeight.constant = likeMessageSize.height + 10
                }
                
                //weakSelf.messageLabel.isHidden = false
                weakSelf.messageToggleButton.isHidden = false
                weakSelf.messageLabel.text = likeMessage
            } else {
                weakSelf.messageLabelBGView.isHidden = true
                weakSelf.messageLabel.isHidden = true
                weakSelf.messageToggleButton.isHidden = true
            }
            
            if let mainImageUrl = profileModel.mainImageUrl {
                weakSelf.setProfileImageFromUrl(url: mainImageUrl)
            }
            
            // profile image list 는 viewmodel 을 따로 관리
            self?.profileImagesViewModel.model = profileModel.imageInfoList
            
            // 상세 내용 label 세팅
            weakSelf.headLineLabel.text = profileModel.idealType?.value
            
            var subline = ""
            if let str = profileModel.birthDate?.ageFromBirthDate {
                subline += "\(str)\n"
            }
            if let str = profileModel.hometown?.value {
                if let d = _app.cardDetailViewModel.model?.distance {
                    subline += "\(str), \(d)\n"
                }else {
                    subline += "\(str)\n"
                }
            }
            if let str = profileModel.job?.value {
                subline += "\(str)\n"
            }
            if let str = profileModel.height {
                subline += "\(str)\n"
            }
            if let str = profileModel.bodyType?.value {
                subline += "\(str)\n"
            }
            if let str = profileModel.religion?.value {
                subline += "\(str)\n"
            }
            if let str = profileModel.bloodType?.value {
                subline += "\(str)\n"
            }
            if let str = profileModel.school {
                subline += "\(str)\n"
            }
            
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 12
            style.alignment = NSTextAlignment.center
            let attrStr = NSMutableAttributedString(string: subline,
                                             attributes: [
                                                NSAttributedStringKey.paragraphStyle : style
                ])
            
            if let d = _app.cardDetailViewModel.model?.distance {
                for range in subline.allRanges(of: "\(d)") as [NSRange] {
                    attrStr.addAttributes([.foregroundColor:UIColor.red], range: range)
                }
            }
            
            weakSelf.subLineLabel.attributedText = attrStr
        }
    }
    
    func voiceLikeMessageStop() {
        if soundPlayer != nil && soundPlayer.isPlaying {
            soundPlayer.stop()
            updater.invalidate()
            voiceLikeProgress.angle = 0
            voiceLikeProgress.angle = 0
            voicelikePlayButton.setImage(UIImage(named: "btnMyPlay"), for: UIControlState.normal)
        }
    }
    
    func voiceLikeMessagePlayVoiceURL() {
        guard let urlPath = _app.cardDetailViewModel.model?.likeMeVoiceMessage else {
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        } catch _ {
        }
        
        updater = CADisplayLink(target: self, selector: #selector(voiceLikeMessageTrackAudio))
        updater.preferredFramesPerSecond = 1
        updater.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
        
        var voice: Data?
        if let url = URL(string: urlPath) {
            do {
                voice = try Data(contentsOf: url)
                try soundPlayer = AVAudioPlayer(data: voice!)
                soundPlayer.delegate = self
                soundPlayer.prepareToPlay()
                soundPlayer.volume = 5.0
                
            }catch {
                
            }
            
        }
        
        if soundPlayer != nil {
            soundPlayer.play()
        }
    }
    
    func selectedThumbnail(index: Int) {
        thumbnail2Button.makeCircleStyleWithBorder(borderWidth:1.0, borderColor: UIColor(rgba: "#e3e1e0"))
        thumbnail3Button.makeCircleStyleWithBorder(borderWidth:1.0, borderColor: UIColor(rgba: "#e3e1e0"))
        thumbnail4Button.makeCircleStyleWithBorder(borderWidth:1.0, borderColor: UIColor(rgba: "#e3e1e0"))
        thumbnail5Button.makeCircleStyleWithBorder(borderWidth:1.0, borderColor: UIColor(rgba: "#e3e1e0"))
        thumbnail6Button.makeCircleStyleWithBorder(borderWidth:1.0, borderColor: UIColor(rgba: "#e3e1e0"))
        
        switch index {
        case 0:
            thumbnail2Button.makeCircleStyleWithBorder(borderWidth:1.0, borderColor: UIColor.red)
        case 1:
            thumbnail3Button.makeCircleStyleWithBorder(borderWidth:1.0, borderColor: UIColor.red)
        case 2:
            thumbnail4Button.makeCircleStyleWithBorder(borderWidth:1.0, borderColor: UIColor.red)
        case 3:
            thumbnail5Button.makeCircleStyleWithBorder(borderWidth:1.0, borderColor: UIColor.red)
        case 4:
            thumbnail6Button.makeCircleStyleWithBorder(borderWidth:1.0, borderColor: UIColor.red)
        default:()
        }
        if let profileImages = profileImagesViewModel.model {
            let imageInfo = profileImages[index]
            if let hidden = imageInfo.hidden , hidden == true  {
                askUnlockProfileImage()
            }
        }

    }
    
    @objc func voiceLikeMessageTrackAudio() {
        if soundPlayer != nil {
            voicelikePlayButton.setImage(UIImage(named: "btnMyStop"), for: UIControlState.normal)
            let newAngleValue = newAngle()
            progress.animate(toAngle: newAngleValue, duration: 1, completion: nil)
        }
    }
    
    func stop() {
        if soundPlayer != nil && soundPlayer.isPlaying {
            soundPlayer.stop()
            updater.invalidate()
            progress.angle = 0
            progress.angle = 0
            thumbnail1Button.setImage(UIImage(named: "btnMyPlay"), for: UIControlState.normal)
        }
    }
    
    func playVoiceURL() {
        guard let urlPath = _app.cardDetailViewModel.model?.profileModel?.voiceUrl else {
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        } catch _ {
        }
        
        updater = CADisplayLink(target: self, selector: #selector(trackAudio))
        updater.preferredFramesPerSecond = 1
        updater.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
        
        var voice: Data?
        if let url = URL(string: urlPath) {
            do {
                voice = try Data(contentsOf: url)
                try soundPlayer = AVAudioPlayer(data: voice!)
                soundPlayer.delegate = self
                soundPlayer.prepareToPlay()
                soundPlayer.volume = 5.0
            }catch {
                
            }
            
        }
        if soundPlayer != nil {
            soundPlayer.play()
        }
    }
    
    @objc func trackAudio() {
        if soundPlayer != nil {
            thumbnail1Button.setImage(UIImage(named: "btnMyStop"), for: UIControlState.normal)
            let newAngleValue = newAngle()
            progress.animate(toAngle: newAngleValue, duration: 1, completion: nil)
        }
    }
    
    func newAngle() -> Double {
        return 360 * (soundPlayer.currentTime / soundPlayer.duration.roundToPlaces(places: 2))
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        updater.invalidate()
        
        progress.finishAnimate(completion: { [weak self] isFinish in
            guard let wself = self else { return }
            
            wself.voicelikePlayButton.setImage(UIImage(named: "btnMyPlay"), for: UIControlState.normal)
            wself.thumbnail1Button.setImage(UIImage(named: "btnMyPlay"), for: UIControlState.normal)
        })
        
        voiceLikeProgress.angle = 0
        voiceLikeProgress.angle = 0
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch _ {
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4 + 3
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = super.tableView(tableView, heightForRowAt: indexPath)
        if indexPath.row == 3 {
            height = 0
        }
        
        if indexPath.row == 4 {
            height = cellForCheckSize.getViewHeight(_app.getCardDetailProfileTypeCodes(.HobbyType), isFold: true) + 20
        }
        
        if indexPath.row == 5 {
            height = cellForCheckSize.getViewHeight(_app.getCardDetailProfileTypeCodes(.CharmingType), isFold: true)
        }
        
        if indexPath.row == 6 {
            height = cellForCheckSize.getViewHeight(_app.getCardDetailProfileTypeCodes(.FavoriteType), isFold: true)
        }
        return height
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 4:
            if let cellData = _app.getCardDetailProfileTypeCodes(.HobbyType) {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "keywordCell", for: indexPath) as? NowNearKeywordTableViewCell {
                    cell.updateKeyword = {
                        [weak self] in
                        if let wself = self {
                            wself.tableView.reloadData()
                        }
                    }
                    cell.isMe = false
                    cell.yCoord = 20
                    cell.configure(dataList: cellData, type: ProfileKeywordType.HobbyType)
                    return cell
                }
            }
        case 5:
            if let cellData = _app.getCardDetailProfileTypeCodes(.CharmingType) {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "keywordCell", for: indexPath) as? NowNearKeywordTableViewCell {
                    cell.updateKeyword = {
                        [weak self] in
                        if let wself = self {
                            wself.tableView.reloadData()
                        }
                    }
                    cell.isMe = false
                    cell.yCoord = 0
                    cell.configure(dataList: cellData, type: ProfileKeywordType.CharmingType)
                    return cell
                }
            }
        case 6:
            if let cellData = _app.getCardDetailProfileTypeCodes(.FavoriteType) {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "keywordCell", for: indexPath) as? NowNearKeywordTableViewCell {
                    cell.updateKeyword = {
                        [weak self] in
                        if let wself = self {
                            wself.tableView.reloadData()
                        }
                    }
                    cell.isMe = false
                    cell.yCoord = 0
                    
                    cell.configure(dataList: cellData, type: ProfileKeywordType.FavoriteType)
                    return cell
                }
            }
        default:
            break
        }
        
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    deinit {
        print(#function, "\(self)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension CardDetailTableViewController {
    func setProfileImageFromUrl(url: String) {
        
        let loadingViewModel = LoadingViewModelBuilder(superview: profileImageView).viewModel
        let responseViewModel = DViewModel<ApiResponse>(self, { [weak self] (model, oldModel) -> () in
            guard let apiResponse = model, let data = apiResponse.model as? Data else {
                return
            }
            self?.profileImageView.image = UIImage(data: data)
        })
        _app.api.download(url: url, apiResponseViewModel: responseViewModel, loadingViewModel: loadingViewModel)
    }
    
    func setThumbnailContainerWidth() {
        
        var width: CGFloat = 0.0
        if thumbnail1Button.isHidden == false {
            width = thumbnail1Button.frame.maxX
        }
        if thumbnail2Button.isHidden == false {
            width = thumbnail2Button.frame.maxX
        }
        if thumbnail3Button.isHidden == false {
            width = thumbnail3Button.frame.maxX
        }
        if thumbnail4Button.isHidden == false {
            width = thumbnail4Button.frame.maxX
        }
        if thumbnail5Button.isHidden == false {
            width = thumbnail5Button.frame.maxX
        }
        if thumbnail6Button.isHidden == false {
            width = thumbnail6Button.frame.maxX
        }
        thumbnailContainerWidthConstraint.constant = width + CGFloat(thumbnail1Button.isHidden == true ? 50 : 0)
    }
    
    func unlock1Image() {
        guard let targetUserId = _app.cardDetailViewModel.model?.profileModel?.id else {
            return
        }
        let loadingViewModel = LoadingViewModelBuilder(superview: profileImageView).viewModel
        let responseViewModel = ApiResponseViewModelBuilder<ProfileModel.ImageInfo>(successHandlerWithDefaultError: { [weak self] (imageInfo) -> Void in
            
            if let imageInfoList = self?.profileImagesViewModel.model {
                var imageInfoListNew: [ProfileModel.ImageInfo]  = []
                imageInfoList.forEach({ (oldImageInfo) -> () in
                    if oldImageInfo.ordering != nil && imageInfo.ordering == oldImageInfo.ordering {
                        imageInfoListNew.append(imageInfo)
                    } else {
                        imageInfoListNew.append(oldImageInfo)
                    }
                })
                // profileImages 교체, viewmodel 교체
                self?.profileImagesViewModel.model = imageInfoListNew
                
                // 새로열린 profile image main에 표시
                if let largeImageUrl = imageInfo.largeImageUrl {
                    self?.setProfileImageFromUrl(url: largeImageUrl)
                } else if let imageUrl = imageInfo.imageUrl {
                    self?.setProfileImageFromUrl(url: imageUrl)
                }
            }
            
        }).viewModel
        _app.api.cardOpenImage(userId: targetUserId, apiResponseViewModel: responseViewModel, loadingViewModel: loadingViewModel)
    }
    
    func askUnlockProfileImage() {
        unlockImageSegue.perform()
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()
        
        visibleRect.origin = profileImageCollectionView.contentOffset
        visibleRect.size = profileImageCollectionView.bounds.size
        
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let visibleIndexPath: NSIndexPath = profileImageCollectionView.indexPathForItem(at: visiblePoint) as! NSIndexPath {
            selectedThumbnail(index: visibleIndexPath.row)
        }
    }
}


extension CardDetailTableViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return profileImagesViewModel.model?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: profileImageView.frame.size.width, height: profileImageView.frame.size.height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbnailImageCell", for: indexPath) as! ThumbnailImageCell
        if let profileImages = profileImagesViewModel.model {
            /*
            UIViewController.cancelPreviousPerformRequestsWithTarget(self)
            cell.shouldShowUnlockMessage = { [weak self] in
                guard let wself = self else {
                    return
                }
                wself.performSelector(#selector(wself.askUnlockProfileImage), withObject: nil, afterDelay: 0.5)
                
            }*/
            let imageInfo = profileImages[indexPath.row]
            cell.setImageInfo(imageInfo: imageInfo)
        }
        
        return cell
    }
}


class ThumbnailImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    var downloadProfileImage = UIImageView()
    var shouldShowUnlockMessage: (() -> Void)?
    
    func setImageInfo(imageInfo: ProfileModel.ImageInfo) {
        if let url = imageInfo.largeImageUrl {
            downloadProfileImage.sd_setImage(with: URL(string: url)) { (image , error , cachType , url ) in
                if let img = image {
                    
                    DispatchQueue.main.async {
                        if let hidden = imageInfo.hidden , hidden == false  {
                            self.imageView.image = img
                        }else {
                            let resizedImage = img.ResizeImage(targetSize: CGSize(width: 300, height: 300))
                            self.imageView.image = resizedImage.applyDarkEffect()
                            
                            self.shouldShowUnlockMessage?()
                        }
                    }
                }
            }
        }
    }
    
}
