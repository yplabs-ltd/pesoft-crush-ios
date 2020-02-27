//
//  StoryViewMainController+Cell.swift
//  DateApp
//
//  Created by Yang Hyeon Gyu on 2017. 4. 16..
//  Copyright © 2017년 iflet.com. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit
import SDWebImage

final class StoryInfoCell: UITableViewCell {

}

final class StoryReplyCell: UITableViewCell, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    let downloadPprofileImage = UIButton()
    @IBOutlet weak var voicePlayButton: UIButton!
    @IBOutlet weak var userProfileButton: UIButton!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var blurImageView: UIImageView!
    
    @IBOutlet weak var stopImage: UIImageView!
    @IBOutlet weak var playImage: UIImageView!
    
    @IBOutlet weak var badVoiceReportButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var topMargin: NSLayoutConstraint!
    @IBOutlet weak var loveButton: LoveButton!
    
    private var otherUserId: Int?
    private var otherVoiceCloudId: String?
    private var voiceUrlPath: String?
    
    var soundRecorder : AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!
    
    private var userVoiceModel: UserVoiceOneModel!

    var progress : KDCircularProgress!
    
    var onMoveToProfile: (() -> Void)?
    
    var heartCount: Int = 0 {
        didSet {
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 6
            style.alignment = NSTextAlignment.center
            
            let attrs = [
                NSAttributedStringKey.font : nameLabel.font,
                NSAttributedStringKey.foregroundColor : nameLabel.textColor,
                NSAttributedStringKey.paragraphStyle:style.copy()]
            
            let attributedString = NSMutableAttributedString(string:"\(userVoiceOneModel!.userName!)\n", attributes:attrs )
            attributedString.append(heartCount.heartCountLabelText)
            
            nameLabel.attributedText = attributedString
        }
    }
    
    var userVoiceOneModel: UserVoiceOneModel? {
        didSet {
            guard let userVoiceOneModel = userVoiceOneModel else {
                return
            }
            
            heartCount = userVoiceOneModel.heartCount ?? 0
            
            if let profileImage = userVoiceOneModel.image {
                userProfileButton.setBackgroundImage(profileImage, for: .normal)
                blurImageView.image = userVoiceOneModel.profileOpened == true ? profileImage : profileImage.applyDarkEffect()
            }else if let url = userVoiceOneModel.imageUrlPath {
                downloadPprofileImage.sd_setImage(with: URL(string: url), for: .normal) { (image , error, cacheType, url) in
                    if let img = image {
                        DispatchQueue.main.async {
                            if self.userVoiceOneModel!.profileOpened == true {
                                self.userProfileButton.setBackgroundImage(img, for: .normal)
                            }else {
                                let resizedImage = img.ResizeImage(targetSize: self.userProfileButton.frame.size)
                                self.userProfileButton.setBackgroundImage(resizedImage.applyDarkEffect(), for: .normal)
                            }
                        }
                    }
                    
                    if let err = error {
                        #if DEBUG
                            print("url::: \(url), error::: \(err)")
                        #endif
                    }
                }
            }
            
            voiceUrlPath = userVoiceOneModel.voiceUriPath
            loveButton.isLoved = userVoiceOneModel.isHearted == true
        }
    }
    
    override func awakeFromNib() {
        /*
        loveButton.layer.cornerRadius = 48.5 / 2
        loveButton.layer.masksToBounds = true
        loveButton.layer.borderColor = UIColor(r: 235, g: 235, b: 235).cgColor
        loveButton.layer.borderWidth = 1
         */
        
        
        userProfileButton.layer.cornerRadius = 245 / 2
        userProfileButton.clipsToBounds = true
        
        blurImageView.layer.cornerRadius = 245 / 2
        blurImageView.clipsToBounds = true
        
        visualEffectView.layer.cornerRadius = 245 / 2
        visualEffectView.clipsToBounds = true
        playImage.isHidden = false
        
        visualEffectView.isUserInteractionEnabled = false
        
        progress = KDCircularProgress()
        self.contentView.addSubview(progress)

        progress.snp.makeConstraints { (make) in
            make.left.equalTo(containerView)
            make.right.equalTo(containerView)
            make.top.equalTo(containerView)
            make.bottom.equalTo(containerView)
            make.leftMargin.equalTo(containerView)
            make.rightMargin.equalTo(containerView)
            make.topMargin.equalTo(containerView)
        }
        progress.startAngle = -90
        progress.progressThickness = 0.02
        progress.trackThickness = 0.02
        progress.clockwise = true
        progress.gradientRotateSpeed = 0.1
        progress.roundedCorners = true
        progress.angle = 0
        progress.trackColor = UIColor(red: 227/255, green: 225/255, blue: 224/255, alpha: 1.0)
        progress.setColors(colors: UIColor(red: 242/255, green: 80/255, blue: 59/255, alpha: 1.0))

        
        
        badVoiceReportButton.layer.zPosition = 1
        loveButton.layer.zPosition = 1
        profileButton.layer.zPosition = 1
        
        if voicePlayButton != nil {
            self.contentView.bringSubview(toFront: voicePlayButton)
        }
        if badVoiceReportButton != nil {
            self.contentView.bringSubview(toFront: badVoiceReportButton)
        }
        if loveButton != nil {
            self.contentView.bringSubview(toFront: loveButton)
        }
        if profileButton != nil {
            self.contentView.bringSubview(toFront: profileButton)
        }
    }
    
    var currentCount:Double = 0
    var maxCount:Double = 360
    
    var updater : CADisplayLink!
    
    deinit {
        print("StoryReplyCell")
    }
    
    @IBAction func onClickLove() {
        guard let id = userVoiceOneModel?.voiceCloudId else { return }
        guard loveButton.isLoved == false else {
            return Toast.showToast(message: "이미 좋아요를 누르셨습니다.", duration: 0.2)
        }
        loveButton.isLoved = true
        let responseViewModel = ApiResponseViewModelBuilder<ServerDefaultResponseModel>(successHandlerWithDefaultError: { (model) -> Void in
            self.heartCount += 1
        }).viewModel
        let _ = _app.api.requestHeart(voiceCloudId: "\(id)", apiResponseViewModel: responseViewModel, loadingViewModel: nil)
    }
    
    @IBAction func playFirstVoice(sender: AnyObject) {
        if _app.sessionViewModel.model?.status == .Normal {
            if soundPlayer != nil && soundPlayer.isPlaying {
                stop()
            } else {
                play()
            }
        } else {
            if _app.sessionViewModel.model?.status == .Waiting {
                alert(title: "프로필 승인 대기중입니다.", message: "서비스를 이용하기 위해선 프로필 승인이 완료되어야 합니다.")
                return
            }
            
            confirm(title: "프로필 입력화면으로 이동합니다.", message: "서비스를 이용하기 위해선 추가 회원정보를 입력해야 합니다", handler: { [weak self] (action) -> Void in
                self?.onMoveToProfile?()
            })
        }
    }
    
    func stop() {
        if soundPlayer != nil && soundPlayer.isPlaying {
            soundPlayer.stop()
            updater.invalidate()
            progress.angle = 0
            progress.angle = 0
            playImage.isHidden = false
            stopImage.isHidden = true
        }
    }
    
    func play() {
        guard let urlPath = self.voiceUrlPath else {
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
        
        updater = CADisplayLink(target: self, selector: #selector(StoryReplyCell.trackAudio))
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
        
        soundPlayer.play()
    }
    
    func adjustFrame() {
        self.layoutIfNeeded()
        
        if self.frame.height > 413 && getScreenSize().width > 320 {
            let topConstraint = (UIScreen.main.bounds.height - 102 - 45 - 413) / 2
            topMargin.constant = topConstraint
        }else {
            topMargin.constant = 0
        }
    }
    
    @objc func trackAudio() {
        playImage.isHidden = true
        stopImage.isHidden = false
        let newAngleValue = newAngle()
        print("currentTime: \(soundPlayer.currentTime), duration: \(soundPlayer.duration), angle: \(newAngleValue)")
        progress.animate(toAngle: newAngleValue, duration: 1, completion: nil)
    }
    
    func newAngle() -> Double {
        
        return 360 * (soundPlayer.currentTime / soundPlayer.duration.roundToPlaces(places: 1))
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        updater.invalidate()
        progress.finishAnimate(completion: { [weak self] isFinish in
            guard let wself = self else { return }
            wself.playImage.isHidden = false
            wself.stopImage.isHidden = true
        })

        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch _ {
        }
    }
}


final class StoryNoVoiceCell: UITableViewCell {
    @IBOutlet weak var noStartVoiceView: UIView!
    @IBOutlet weak var noStartVoiceInnerView: UIView!
    @IBOutlet weak var noStartVoiewButtonView: UIView!
    @IBOutlet weak var startRecordNoStartVoiceButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var checkTimer: Timer? = nil
    var storyViewController: StoryViewMainController!
    var rippleLayer: RippleLayer? = nil
    
    deinit {
        rippleLayer?.stopAnimation()
        checkTimer?.invalidate()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        descriptionLabel.text = "사람들의 이야기를 찾고 있습니다\n먼저 이야기를 시작해 보시는건 어떠세요?"
        
        noStartVoiewButtonView.layer.cornerRadius = 91.5 / 2
        noStartVoiewButtonView.layer.masksToBounds = true
        noStartVoiewButtonView.layer.borderColor = UIColor(rgba: "#e3e1e0").withAlphaComponent(0.8).cgColor
        noStartVoiewButtonView.layer.borderWidth = 1
 
        
        noStartVoiceView.backgroundColor = UIColor.clear
        noStartVoiceInnerView.backgroundColor = UIColor.clear
        noStartVoiewButtonView.backgroundColor = UIColor.white
        startRecordNoStartVoiceButton.backgroundColor = UIColor.clear
        
        checkTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.checkRippleAnimationPlay), userInfo: nil, repeats: true)
    }
    
    func setRippleLayer() {
        if rippleLayer == nil {
            rippleLayer = RippleLayer()
            let screenSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 102 - 45)
            let yCoord = (UIScreen.main.bounds.height - 102 - 45 - 221) / 2 - 28 + (221 / 2)
            rippleLayer?.position = CGPoint(x: screenSize.width / 2, y: yCoord);
            self.layer.insertSublayer(rippleLayer!, at: 0)
        }else {
            rippleLayer?.stopAnimation()
        }
     
        let time = DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.rippleLayer?.startAnimation()
        }
    }
    
    @objc func checkRippleAnimationPlay() {
        if rippleLayer?.isAnimationRunning == false {
            rippleLayer?.startAnimation()
        }
    }
}



