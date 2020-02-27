//
//  MyDetailRankCell.swift
//  DateApp
//
//  Created by Daehyun Lim on 2018. 5. 20..
//  Copyright © 2018년 iflet.com. All rights reserved.
//

import Foundation
import AVFoundation


final class MyDetailRankCell: UITableViewCell, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    @IBOutlet weak var userProfileButton: UIButton!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var blurImageView: UIImageView!
    @IBOutlet weak var voicePlayButton: UIButton!
    @IBOutlet weak var stopImage: UIImageView!
    @IBOutlet weak var playImage: UIImageView!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var topMargin: NSLayoutConstraint!
    
    private var otherUserId: Int?
    private var otherVoiceCloudId: String?
    private var voiceUrlPath: String?
    
    var soundRecorder : AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!
    
    private var userVoiceModel: UserVoiceOneModel!
    
    var progress : KDCircularProgress!
    
    var heartCount: Int = 0 {
        didSet {
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 6
            style.alignment = NSTextAlignment.center
            
            let attrs = [
                NSAttributedStringKey.font : nameLabel.font,
                NSAttributedStringKey.foregroundColor : nameLabel.textColor,
                 NSAttributedStringKey.paragraphStyle:style.copy()]
            let attributedString = NSMutableAttributedString(string:"\(userVoiceOneModel!.userName!)\n", attributes:attrs)
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
            
            let profileImage = userVoiceOneModel.image
            userProfileButton.setBackgroundImage(profileImage, for: .normal)
            voiceUrlPath = userVoiceOneModel.voiceUriPath
            

            if let url = userVoiceOneModel.imageUrlPath {
                userProfileButton.sd_setImage(with: URL(string: url), for: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        
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
        progress.trackColor = UIColor(red: 227/255, green: 225/255, blue: 224/255, alpha: 1.0)
        progress.startAngle = -90
        progress.progressThickness = 0.02
        progress.trackThickness = 0.02
        progress.clockwise = true
        progress.gradientRotateSpeed = 2
        progress.roundedCorners = true
        progress.angle = 0
        progress.setColors(colors: UIColor(red: 242/255, green: 80/255, blue: 59/255, alpha: 1.0))
        
        self.contentView.bringSubview(toFront: voicePlayButton)
    }
    
    var currentCount:Double = 0
    var maxCount:Double = 360
    
    var updater : CADisplayLink!
    
    deinit {
        print("StoryReplyCell")
    }
    
    @IBAction func playFirstVoice(sender: AnyObject) {
        if soundPlayer != nil && soundPlayer.isPlaying {
            stop()
        } else {
            play()
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
        do {
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
        } catch {
            print("Error playing")
        }
        
        soundPlayer.play()
    }
    
    @objc func trackAudio() {
        playImage.isHidden = true
        stopImage.isHidden = false
        let newAngleValue = newAngle()
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
