//
//  VoiceChatViewController+Cell.swift
//  DateApp
//
//  Created by Yang Hyeon Gyu on 2017. 3. 26..
//  Copyright © 2017년 iflet.com. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit
import SDWebImage

final class VoiceChatProfileInfoCell: UITableViewCell {
    var downloadPprofileImage: UIButton!
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var profileImageContentView: UIView!
    @IBOutlet weak var badReportVoiceButton: UIButton!

    var bluredProfileImage: UIImage?
    var cellVoiceChatRoomModel: VoiceChatRoomModel!
    var blurImage: UIImage?
    var normalImage: UIImage?
    
    var onClickProfile: ((Bool) -> Void)?
    
    
    var voiceChatRoomModel: VoiceChatRoomModel? {
        didSet {
            guard let voiceChatRoomModel = voiceChatRoomModel else {
                return
            }
            cellVoiceChatRoomModel = voiceChatRoomModel
        }
    }
    
    var isCanReportBadVoice: Bool? {
        didSet {
            guard let _ = isCanReportBadVoice else {
                return
            }
            
            self.badReportVoiceButton.isHidden = false
            self.isUserInteractionEnabled = true
        }
    }
    
    
    @IBAction func onPressedProfile() {
        onClickProfile?(voiceChatRoomModel?.profileOpened ?? false)
    }
    
    func setProfileImage(imageUrl: String?) {
        if let blurImage = self.blurImage , cellVoiceChatRoomModel.profileOpened == false {
            self.profileImageButton.setImage(blurImage, for: .normal)
            return
        }
        
        if let normalImage = self.normalImage , cellVoiceChatRoomModel.profileOpened == true {
            self.profileImageButton.setImage(normalImage, for: .normal)
            return
        }
        self.profileImageButton.imageView?.contentMode = .scaleAspectFill
        self.profileImageButton.contentMode = .scaleAspectFill
        self.profileImageButton.setBackgroundImage(nil, for: .normal)
        self.profileImageButton.setImage(nil, for: .normal)
        if let url = imageUrl {
            downloadPprofileImage.sd_setImage(with: URL(string: url), for: .normal) { (image , error, cacheType, url) in
                if let img = image {
                    DispatchQueue.main.async {
                        self.normalImage = img
                        let resizedImage = img.ResizeImage(targetSize: self.profileImageButton.frame.size)
                        self.blurImage = resizedImage.applyDarkEffect()
                    }
                }
                
                if let err = error {
                    #if DEBUG
                    print("url::: \(String(describing: url)), error::: \(err)")
                    #endif
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        downloadPprofileImage = UIButton()
        
        profileImageContentView.layer.cornerRadius = profileImageContentView.frame.width / 2
        profileImageContentView.layer.masksToBounds = true
        profileImageContentView.layer.borderColor = UIColor(rgba: "#e3e1e0").cgColor
        profileImageContentView.layer.borderWidth = 1
        
        profileImageButton.makeCircleStyle()
    }
}

final class VoiceChatCell: UITableViewCell, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    @IBOutlet weak var playVoiceButtonContainer: UIView!
    @IBOutlet weak var playButtonView: UIView!
    @IBOutlet weak var seperateLine: UIView!
    @IBOutlet weak var leftNameLabel: UILabel!
    @IBOutlet weak var leftTimeLabel: UILabel!
    @IBOutlet weak var rightNameLabel: UILabel!
    @IBOutlet weak var rightTimeLabel: UILabel!
    @IBOutlet weak var playImage: UIButton!
    @IBOutlet weak var stopImage: UIButton!

    
    var soundRecorder : AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!
    var cellIndex: Int!
    
    var progress : KDCircularProgress!
    var chatUserId: Int?
    
    var voiceChatModel: VoiceChatModel? {
        didSet {
            guard let voiceChatModel = voiceChatModel else {
                return
            }
            if let isLast = voiceChatModel.isLast , isLast == true {
                seperateLine.isHidden = true
            }
            guard let order = voiceChatModel.order else {
                return
            }
            
            // my profile
            guard let userId = _app.sessionViewModel.model?.id else {
                return
            }
            chatUserId = voiceChatModel.userId
            if userId != voiceChatModel.userId { // left
                leftNameLabel.text = voiceChatModel.name
                leftTimeLabel.text = voiceChatModel.modifiedAt?.timeAgoForComment()
                playButtonView.backgroundColor = UIColor(rgba: "#726763")
                
                self.progress = KDCircularProgress()
                self.playVoiceButtonContainer.addSubview((self.progress)!)
                
                self.progress.snp.makeConstraints { (make) in
                    make.left.equalTo((self.playVoiceButtonContainer)!)
                    make.right.equalTo((self.playVoiceButtonContainer)!)
                    make.top.equalTo((self.playVoiceButtonContainer)!)
                    make.bottom.equalTo((self.playVoiceButtonContainer)!)
                    make.leftMargin.equalTo((self.playVoiceButtonContainer)!)
                    make.rightMargin.equalTo((self.playVoiceButtonContainer)!)
                    make.topMargin.equalTo((self.playVoiceButtonContainer)!)
                }
                self.progress.trackColor = UIColor(red: 227/255, green: 225/255, blue: 224/255, alpha: 1.0)
                self.progress.startAngle = -90
                self.progress.progressThickness = 0.02
                self.progress.trackThickness = 0.02
                self.progress.clockwise = true
                self.progress.gradientRotateSpeed = 2
                self.progress.roundedCorners = true
                self.progress.angle = 0
                progress.setColors(colors: UIColor(rgba: "#F2503B"))

            } else { // right
                rightNameLabel.text = voiceChatModel.name
                rightTimeLabel.text = voiceChatModel.modifiedAt?.timeAgoForComment()
                playButtonView.backgroundColor = UIColor(rgba: "#F2503B")
                
                self.progress = KDCircularProgress()
                self.playVoiceButtonContainer.addSubview((self.progress)!)
                
                self.progress.snp.makeConstraints { (make) in
                    make.left.equalTo((self.playVoiceButtonContainer)!)
                    make.right.equalTo((self.playVoiceButtonContainer)!)
                    make.top.equalTo((self.playVoiceButtonContainer)!)
                    make.bottom.equalTo((self.playVoiceButtonContainer)!)
                    make.leftMargin.equalTo((self.playVoiceButtonContainer)!)
                    make.rightMargin.equalTo((self.playVoiceButtonContainer)!)
                    make.topMargin.equalTo((self.playVoiceButtonContainer)!)
                }
                self.progress.trackColor = UIColor(red: 227/255, green: 225/255, blue: 224/255, alpha: 1.0)
                self.progress.startAngle = -90
                self.progress.progressThickness = 0.02
                self.progress.trackThickness = 0.02
                self.progress.clockwise = true
                self.progress.gradientRotateSpeed = 2
                self.progress.roundedCorners = true
                self.progress.angle = 0
                self.progress.setColors(colors: UIColor(rgba: "#F2503B"))
            }
            
            cellIndex = voiceChatModel.order! % 2
        }
    }
   
    var currentCount:Double = 0
    var maxCount:Double = 360
    
    var updater : CADisplayLink!


    @IBAction func playVoice(sender: AnyObject) {
        if _app.chatViewCell.count == 0 {
            _app.chatViewCell.append(self)
        } else {
            let selectedCell = _app.chatViewCell.popLast()
            if selectedCell != self {
                selectedCell!.stop()
                _app.chatViewCell.removeAll()
                _app.chatViewCell.append(self)
            }
            
        }

        play()
    }
    
    func stop() {
        if soundPlayer != nil && soundPlayer.isPlaying {
            soundPlayer.stop()
            updater.invalidate()
            progress.angle = 0
            progress.angle = 0
            
            guard let userId = _app.sessionViewModel.model?.id else {
                return
            }
            if userId != chatUserId { // left
                playButtonView.backgroundColor = UIColor(rgba: "#726763")
                playImage.isHidden = false
                stopImage.isHidden = true
            } else {
                playButtonView.backgroundColor = UIColor(rgba: "#F2503B")
                playImage.isHidden = false
                stopImage.isHidden = true
            }
        }
    }
    
    func play() {
        if soundPlayer != nil && soundPlayer.isPlaying {
            soundPlayer.stop()
            updater.invalidate()
            progress.angle = 0
            progress.angle = 0
            
            guard let userId = _app.sessionViewModel.model?.id else {
                return
            }
            if userId != chatUserId { // left
                playButtonView.backgroundColor = UIColor(rgba: "#726763")
                playImage.isHidden = false
                stopImage.isHidden = true
            } else {
                playButtonView.backgroundColor = UIColor(rgba: "#F2503B")
                playImage.isHidden = false
                stopImage.isHidden = true
            }
        } else {
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
            if let voiceUrlPath = voiceChatModel?.voiceUrl, let url = URL(string: voiceUrlPath) {
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

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func trackAudio() {
        playButtonView.backgroundColor = UIColor(rgba: "#FFFFFF")
        playImage.isHidden = true
        stopImage.isHidden = false
        let newAngleValue = newAngle()
        progress.animate(toAngle: newAngleValue, duration: 1, completion: nil)
    }
    
    func newAngle() -> Double {
        return 360 * (soundPlayer.currentTime / soundPlayer.duration.roundToPlaces(places: 2))
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        updater.invalidate()
        
        progress.finishAnimate(completion: { [weak self] isFinish in
            guard let wself = self else { return }
        
            guard let userId = _app.sessionViewModel.model?.id else {
                return
            }
            if userId != wself.chatUserId { // left
                wself.playButtonView.backgroundColor = UIColor(rgba: "#726763")
                wself.playImage.isHidden = false
                wself.stopImage.isHidden = true
            } else {
                wself.playButtonView.backgroundColor = UIColor(rgba: "#F2503B")
                wself.playImage.isHidden = false
                wself.stopImage.isHidden = true
            }
        })
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch _ {
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        playVoiceButtonContainer.layer.cornerRadius = playVoiceButtonContainer.frame.width / 2
        playVoiceButtonContainer.layer.masksToBounds = true
        playVoiceButtonContainer.layer.borderColor = UIColor(rgba: "#e3e1e0").cgColor
        playVoiceButtonContainer.layer.borderWidth = 1
        
        playButtonView.layer.cornerRadius = playButtonView.frame.width / 2
        playButtonView.clipsToBounds = true
    }
}

extension UIButton
{
    func addBlurEffect()
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.9
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
    }
}
