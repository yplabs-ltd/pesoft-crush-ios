//
//  NewVoiceRecordPopupController.swift
//  DateApp
//
//  Created by Yang Hyeon Gyu on 2017. 3. 12..
//  Copyright © 2017년 iflet.com. All rights reserved.
//

import UIKit
import AVFoundation

class NewVoiceRecordPopupController : UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    @IBOutlet weak var recordBTN: UIButton!
    @IBOutlet weak var recordViewContainer: UIView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var reRecordButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    var popupType: PopupType?
    var otherUserId : Int?
    var otherVoiceCloudId : String?
    var voiceChatRoomId: String?
    var useBuzzie: Bool?
    var isSendingVoiceData: Bool = false
    var isPromotion: Bool = false
    let promotionDescribeMessage = "새 이야기를 지금 시작하시면 우수 회원 세분을\nToday에서 지금 바로 추천해드립니다."
    var voiceUrl: String?
    var isPassAfterReply: Bool = true
    
    var newPopupLabelText: [String] = [
        "Ex. 요즘 재미있게 보신 영화 있으신가요?",
        "Ex. 읽었던 책 중에 감명받은거 있으신가요?",
        "Ex. 친구 생일선물로 뭐가 좋을까요?",
        "Ex. 평일에 쉬고 주말에 바쁜분 계신가요?",
        "Ex. 집에서 오랜만에 쉬는데 드라마 추천해주세요",
        "Ex. 스트레스 받을 때 나만의 해소법 있으신가요?",
        "Ex. 어떨때 가장 기분이 좋고 마음이 편하세요?",
        "Ex. 탕수육 부먹이신가요 찍먹이신가요?",
        "Ex. 주말에 뭐 하면서 시간 보내세요?",
        "Ex. 추천해주실 음악 있으신가요?"
    ]
    
    var submitHandler: ((NewVoiceRecordPopupController) -> Void)?
    
    enum RecordButtonStatus {
        case recording, play, record
    }
    
    enum PopupType {
        case New
        case FirstReply
        case Reply
        case AddVoice
    }
    
    var soundRecorder : AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!
    var recordButtonStatus : RecordButtonStatus!
    
    var progress : KDCircularProgress!
    var recordTimer: Timer!
    
    var fileName = "audioFile.m4a"
    
    var isSendVoice: Bool! = false
    
    let recordSettings = [AVSampleRateKey : NSNumber(value: Float(44100.0)),
                          AVFormatIDKey : NSNumber(value: Int32(kAudioFormatMPEG4AAC)),
                          AVNumberOfChannelsKey : NSNumber(value: 1),
                          AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.max.rawValue))]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isSendVoice = false
        
        recordButtonStatus = .record
        
        reRecordButton.layer.cornerRadius = 33 / 2
        
        progress = KDCircularProgress()
        view.addSubview(progress)

        progress.snp.makeConstraints { (make) in
            make.left.equalTo(recordViewContainer)
            make.right.equalTo(recordViewContainer)
            make.top.equalTo(recordViewContainer)
            make.bottom.equalTo(recordViewContainer)
            make.leftMargin.equalTo(recordViewContainer)
            make.rightMargin.equalTo(recordViewContainer)
            make.topMargin.equalTo(recordViewContainer)
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
        
        recordButton.layer.cornerRadius = 145 / 2
        recordButton.layer.backgroundColor = UIColor(rgba: "#F2503B").cgColor
        subtitleLabel.isHidden = true
        
        if (popupType == .New) {
            let diceRoll = Int(arc4random_uniform(10))
            titleLabel.text = "새 이야기 시작"
            descriptionLabel.text = isPromotion ? promotionDescribeMessage : newPopupLabelText[diceRoll]
        } else if popupType == .AddVoice {
            subtitleLabel.isHidden = false
            if _app.sessionViewModel.model?.gender == "F" {
                subtitleLabel.text = "무료로 보낼 수 있어요!"
            }else {
                subtitleLabel.text = "5버찌 필요"
            }
            
            titleLabel.text = "목소리 추가히기"
            descriptionLabel.text = "어떤 부분이 가장 마음에 드셨는지\n용기내서 목소리로 얘기해보세요!"
            sendButton.setTitle("저장", for: UIControlState.normal)
        } else {
            titleLabel.text = "답장하기"
            descriptionLabel.text = "음성을 녹음해서 답장을 보내세요"
        }
        
        _app.voiceViewModel.model = VoiceModel()

         setUpRecorder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isSendVoice = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpRecorder() {
        let audioSession:AVAudioSession = AVAudioSession.sharedInstance()
        
        //ask for permission
        if (audioSession.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    print("granted")
                    
                    //set category and activate recorder session
                    do {
                        
                        try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                        
                        try self.soundRecorder = AVAudioRecorder(url: self.directoryURL()!, settings: self.recordSettings)
                        self.soundRecorder.prepareToRecord()
                        
                    } catch {
                        
                        print("Error Recording");
                        
                    }
                    
                }
            })
        }
    }
    
    func directoryURL() -> URL? {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as NSURL
        let soundURL = documentDirectory.appendingPathComponent("sound.m4a")
        return soundURL
    }
    
    @IBAction func submit(sender: AnyObject) {
        guard !isSendingVoiceData else {
            return
        }
        
        if (isSendVoice != nil && isSendVoice) {
            isSendingVoiceData = true
            do {
                let voiceFile = try Data(contentsOf: directoryURL()!)
                
                if popupType == .AddVoice {
                    _app.voiceViewModel.uploadVoice(loadingViewModel: _app.loadingViewModel, voiceFile: voiceFile) { [weak self] (newVoiceModel) -> () in
                        guard let wself = self else { return }
                        wself.voiceUrl = newVoiceModel?.urlPath
                        wself.callSubmit()
                        wself.dismiss(animated:false, completion: nil)
                    }
                } else if (popupType == .New) {
                    dismiss(animated: true, completion: { () -> Void in
                        _app.voiceViewModel.uploadVoice(loadingViewModel: _app.loadingViewModel, voiceFile: voiceFile) { (newVoiceModel) -> () in
                            self.isSendingVoiceData = false
                            _app.voiceViewModel.insertStartVoice(voiceModel: newVoiceModel!, loadingViewModel: _app.loadingViewModel){() -> () in
                                self.isSendingVoiceData = false
                            }
                        }
                    })
                } else if popupType == .FirstReply {
                    dismiss(animated: true, completion: { () -> Void in
                        _app.voiceViewModel.uploadVoice(loadingViewModel: _app.loadingViewModel, voiceFile: voiceFile) { (voiceModel) -> () in
                            guard var newVoiceModel = voiceModel else {
                                return
                            }
                            newVoiceModel.otherUserId = self.otherUserId
                            newVoiceModel.otherVoiceCloudId = self.otherVoiceCloudId
                            _app.voiceViewModel.replyStartVoice(voiceModel: newVoiceModel, loadingViewModel: _app.loadingViewModel, onSuccess: {
                                () in
                                if self.isPassAfterReply {
                                    var passVoiceModel = PassVoiceModel()
                                    passVoiceModel.voiceCloudId = newVoiceModel.otherVoiceCloudId
                                    _app.passVoiceViewModel.passVoice(passVoiceModel: passVoiceModel, loadingViewModel: _app.loadingViewModel, completeHandler: {() -> Void in
                                        self.isSendingVoiceData = false
                                        _app.userVoiceOneViewModel.reload()
                                    })
                                }
                            })
                        }
                    })
                } else {
                    if self.useBuzzie! {
                        _app.voiceViewModel.uploadVoice(loadingViewModel: _app.loadingViewModel, voiceFile: voiceFile) { (voiceModel) -> () in
                            guard var newVoiceModel = voiceModel else {
                                return
                            }
                            
                            newVoiceModel.voiceChatRoomId = self.voiceChatRoomId
                            _app.voiceViewModel.replyVoiceUseBuzzie(voiceModel: newVoiceModel, loadingViewModel: _app.loadingViewModel) {() -> () in
                                self.isSendingVoiceData = false
                                self.callSubmit()
                            }
                        }
                    } else {
                        _app.voiceViewModel.uploadVoice(loadingViewModel: _app.loadingViewModel, voiceFile: voiceFile) { (voiceModel) -> () in
                            guard var newVoiceModel = voiceModel else {
                                return
                            }
                            newVoiceModel.voiceChatRoomId = self.voiceChatRoomId
                            _app.voiceViewModel.replyVoice(voiceModel: newVoiceModel, loadingViewModel: _app.loadingViewModel) {() -> () in
                                self.isSendingVoiceData = false
                                self.callSubmit()
                            }
                        }
                    }
                }
                
            }catch {
                
            }
        }
    }
    
    func callSubmit() {
        submitHandler?(self)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func reRecord(sender: AnyObject) {
        soundPlayer?.stop()
        updater?.invalidate()
        currentRecordTrack = 0
        progress.angle = 0
        progress.angle = 0
        recordButtonStatus = .recording
        soundRecorder.record()
        
        recordTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(NewVoiceRecordPopupController.recordTractAduio), userInfo: nil, repeats: true)
        recordButton.layer.backgroundColor = UIColor(rgba: "#FFFFFF").cgColor
        recordButton.setImage(UIImage(named: "icoStopRed.png"), for: UIControlState.normal)
        descriptionLabel.isHidden = false
        reRecordButton.isHidden = true
    }
    
    var updater : CADisplayLink!
    
    @IBAction func record(sender: AnyObject) {
        if (recordButtonStatus == .record) {
            currentRecordTrack = 0
            progress.angle = 0
            progress.angle = 0
            recordButtonStatus = .recording
            soundRecorder.record()
            
            recordTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(NewVoiceRecordPopupController.recordTractAduio), userInfo: nil, repeats: true)
            recordButton.layer.backgroundColor = UIColor(rgba: "#FFFFFF").cgColor
            recordButton.setImage(UIImage(named: "icoStopRed.png"), for: UIControlState.normal)
        } else if (recordButtonStatus == .recording) {
            recordTimer.invalidate()
            progress.angle = 0
            progress.angle = 0
            recordButtonStatus = .play
            soundRecorder.stop()
//            soundRecorder.record()
            descriptionLabel.isHidden = true
            reRecordButton.isHidden = false
            recordButton.layer.backgroundColor = UIColor(rgba: "#FFFFFF").cgColor
            recordButton.setImage(UIImage(named: "icoPlayRed.png"), for: UIControlState.normal)
            isSendVoice = true
            sendButton.setTitleColor(UIColor(red: 242/255, green: 80/255, blue: 59/255, alpha : 1.0), for: .normal)
        } else if (recordButtonStatus == .play) {
            if soundPlayer != nil && soundPlayer.isPlaying {
                soundPlayer.stop()
                updater.invalidate()
                progress.angle = 0
                progress.angle = 0
                
                recordButton.layer.backgroundColor = UIColor(rgba: "#FFFFFF").cgColor
                recordButton.setImage(UIImage(named: "icoPlayRed.png"), for: UIControlState.normal)
            } else {
                recordViewContainer.layer.borderColor = UIColor(rgba: "#F2503B").cgColor
                do {
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
                    
                    try soundPlayer = AVAudioPlayer(contentsOf: directoryURL()!)
                    soundPlayer.delegate = self
                    soundPlayer.prepareToPlay()
                    soundPlayer.volume = 5.0
                } catch {
                    print("Error playing")
                }
                
                soundPlayer.play()
            }
        }
    }
    
    var currentRecordTrack: Double = 0
    var maxRecordTrack: Double = 10
    
    @objc func recordTractAduio() {
        if currentRecordTrack != maxRecordTrack {
            currentRecordTrack = currentRecordTrack + 1
            let newAngleValue = newRecordAngle()
            progress.animate(toAngle: newAngleValue, duration: 1, completion: nil)
        } else {
            recordTimer.invalidate()
            progress.angle = 0
            progress.angle = 0
            recordButtonStatus = .play
            soundRecorder.stop()
            descriptionLabel.isHidden = true
            reRecordButton.isHidden = false
            recordButton.layer.backgroundColor = UIColor(rgba: "#FFFFFF").cgColor
            recordButton.setImage(UIImage(named: "icoPlayRed.png"), for: UIControlState.normal)
            isSendVoice = true
            sendButton.setTitleColor(UIColor(red: 242/255, green: 80/255, blue: 59/255, alpha : 1.0), for: .normal)
        }
    }
    
    func newRecordAngle() -> Double {
        return 360 * (currentRecordTrack / maxRecordTrack)
    }
    
    @objc func trackAudio() {
        recordButton.setImage(UIImage(named: "icoStopRed.png"), for: UIControlState.normal)
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
            wself.recordButton.setImage(UIImage(named: "icoPlayRed.png"), for: UIControlState.normal)
        })
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch _ {
        }
    }
}



