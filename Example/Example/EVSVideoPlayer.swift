//
//  EVSVideoPlayer.swift
//  EVSVideoPlayer
//
//  Created by Mackenzie Boudreau on 2016-02-05.
//  Copyright © 2016 Mackenzie Boudreau. All rights reserved.
//

import AVFoundation
import UIKit

protocol EVSVideoPlayerDelagate {
    func fullScreenTapped(_ isFullscreen: Bool)
}

class EVSVideoPlayer: UIView {
    
    fileprivate var videoPlayer = AVPlayer()
    fileprivate var videoPlayerLayer: AVPlayerLayer!
    fileprivate var title: UILabel!
    
    fileprivate var videoUrl = URL(string: "http://content.jwplatform.com/manifests/vM7nH0Kl.m3u8")! {
        didSet {
            let videoItem = AVPlayerItem(url: videoUrl)
            videoPlayer.replaceCurrentItem(with: videoItem)
            videoPlayer.play()
        }
    }
    
    fileprivate let topContainter = UIView()
    fileprivate let bottomContainer = UIView()
    fileprivate let menuContainer = UIView()
    
    fileprivate var menuStatus = true
    
    fileprivate var timeObserver: AnyObject!
    
    var delegate: EVSVideoPlayerDelagate?
    
    fileprivate var userIsFullscreen = false
    
    let displayMenu = UIButton()
    let play = UIButton()
    let extra = UIButton()
    let fullscreen = UIButton()
    let playback = UILabel()
    
    let seeker = UISlider()
    var playerRateBeforeSeek: Float = 0.0
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    init(url: String, frame: CGRect) {
        super.init(frame: frame)
        setVideoURL(url)
        setup()
    }
    
    func setVideoPathURL(_ url: URL) {
        self.videoUrl = url
    }

    func setVideoTitle(_ text: String) {
        if (title != nil) {
            title.text = text;
        }
    }
    
    func setVideoURL(_ url: String) {
        if let url = URL(string: url) {
            self.videoUrl = url
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        videoPlayerLayer.frame = self.bounds
        
        topGradient.frame = topContainter.bounds
        bottomGradient.frame = bottomContainer.bounds
        displayMenu.frame = self.bounds
    }
    
    override func awakeFromNib() {
        displayMenu.addTarget(self, action: #selector(EVSVideoPlayer.triggerMenu(_:)), for: .touchUpInside)
        self.addSubview(displayMenu)
         setupMenu()
    }
    
    fileprivate func setup() {
        self.backgroundColor = UIColor.black
        
        videoPlayerLayer = AVPlayerLayer(player: videoPlayer)
        self.layer.insertSublayer(videoPlayerLayer, at: 0)
        
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        
        let timeInterval: CMTime = CMTimeMakeWithSeconds(1.0, 10)
        timeObserver = videoPlayer.addPeriodicTimeObserver(forInterval: timeInterval, queue: DispatchQueue.main) { (elapsedTime: CMTime) in
            self.observeTime(elapsedTime)
        } as AnyObject!
        
    }
    
    func updateTimeLabel(elapsedTime: Float64, duration: Float64) {
        
//        UIView.animateWithDuration(0.05) { () -> Void in
            self.seeker.setValue(Float(elapsedTime / duration), animated: true)
//        }
//        
        let timeRemaining: Float64 = CMTimeGetSeconds(videoPlayer.currentItem!.duration) - elapsedTime
        playback.text = String(format: "%02d:%02d", ((lround(timeRemaining) / 60) % 60), lround(timeRemaining) % 60)

    }
    
    func observeTime(_ elapsedTime: CMTime) {
        let duration = CMTimeGetSeconds(videoPlayer.currentItem!.duration);
        if (duration.isFinite) {
            let elapsedTime = CMTimeGetSeconds(elapsedTime)
            updateTimeLabel(elapsedTime: elapsedTime, duration: duration)
        }
    }
    
    deinit {
        videoPlayer.removeTimeObserver(timeObserver)
    }
    
    func playButtonTapped(_ btn: UIButton) {
        print(btn.state)
        let isPlaying = videoPlayer.rate > 0
        if isPlaying {
            videoPlayer.pause()
            btn.setImage(UIImage(named: "Play"), for: UIControlState())
        } else {
            videoPlayer.play()
            btn.setImage(UIImage(named: "Pause"), for: UIControlState())
        }
    }
    
    let topGradient = CAGradientLayer()
    let bottomGradient = CAGradientLayer()
    fileprivate func setupMenu() {
     
        topContainter.translatesAutoresizingMaskIntoConstraints = false
        self.insertSubview(topContainter, aboveSubview: displayMenu)
        setMenuConstraints(topContainter, top: true)
        
        topGradient.colors = [UIColor.black.withAlphaComponent(0.45).cgColor, UIColor.clear.cgColor]
        topGradient.locations = [-0.2, 1]
        self.topContainter.layer.insertSublayer(topGradient, at: 0)
        
        bottomContainer.translatesAutoresizingMaskIntoConstraints = false
        self.insertSubview(bottomContainer, aboveSubview: displayMenu)
        setMenuConstraints(bottomContainer, top: false)
        
        
        //bottomGradient.colors = [UIColor.blackColor().colorWithAlphaComponent(0.0).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.75).CGColor]
        bottomGradient.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.45).cgColor]
        bottomGradient.locations = [0, 1.2]
    
        self.bottomContainer.layer.insertSublayer(bottomGradient, at: 0)
        
        setupMenuItems()
        
    }
    
    fileprivate func setupMenuItems() {
        
        // PLAY/PAUSE BUTTON
        
        play.setTitle("", for: UIControlState())
        play.setImage(UIImage(named: "Pause"), for: UIControlState())
        play.addTarget(self, action: #selector(EVSVideoPlayer.playButtonTapped(_:)), for: .touchUpInside)
        play.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.addSubview(play)
        
        // Play Button Constraints
        let playLeadingConstraint = NSLayoutConstraint(item: play, attribute: .leading, relatedBy: .equal, toItem: bottomContainer, attribute: .leading, multiplier: 1, constant: 15)
        bottomContainer.addConstraint(playLeadingConstraint)
        let playCenterY = NSLayoutConstraint(item: play, attribute: .centerY, relatedBy: .equal, toItem: bottomContainer, attribute: .centerY, multiplier: 1, constant: 0)
        bottomContainer.addConstraint(playCenterY)
        // 13 x 15
        let playHeight = NSLayoutConstraint(item: play, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 25)
        play.addConstraint(playHeight)
        let playWidth = NSLayoutConstraint(item: play, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 25)
        play.addConstraint(playWidth)
        
        // Extra button
        extra.setTitle("", for: UIControlState())
        extra.alpha = 0
        extra.setImage(UIImage(named: "More"), for: UIControlState())
        extra.addTarget(self, action: #selector(EVSVideoPlayer.extraButtonTapped(_:)), for: .touchUpInside)
        extra.translatesAutoresizingMaskIntoConstraints = false
        topContainter.addSubview(extra)
        
        // Extra button constraints
        let extraTrailingConstraint = NSLayoutConstraint(item: extra, attribute: .trailing, relatedBy: .equal, toItem: topContainter, attribute: .trailing, multiplier: 1, constant: -15)
        topContainter.addConstraint(extraTrailingConstraint)
        let extraCenterY = NSLayoutConstraint(item: extra, attribute: .centerY, relatedBy: .equal, toItem: topContainter, attribute: .centerY, multiplier: 1, constant: 0)
        topContainter.addConstraint(extraCenterY)
        
        // TITLE + LOGO
        
        let logo = UIImageView(image: UIImage(named: "Logo"))
        logo.contentMode = UIViewContentMode.center
        logo.clipsToBounds = true
        logo.translatesAutoresizingMaskIntoConstraints = false
        topContainter.addSubview(logo)
        
        // Logo Constraints
        let logoLeadingConstraint = NSLayoutConstraint(item: logo, attribute: .leading, relatedBy: .equal, toItem: topContainter, attribute: .leading, multiplier: 1, constant: 15)
        topContainter.addConstraint(logoLeadingConstraint)
        let logoCenterY = NSLayoutConstraint(item: logo, attribute: .centerY, relatedBy: .equal, toItem: topContainter, attribute: .centerY, multiplier: 1, constant: 0)
        topContainter.addConstraint(logoCenterY)
        
        title = UILabel()
        title.textColor = UIColor.white
        
        title.font = UIFont(name: Fonts.OpenSans.Regular, size: 12)
        title.translatesAutoresizingMaskIntoConstraints = false
        topContainter.addSubview(title)
        
        // Title Constraints
        let titleLeadingConstraint = NSLayoutConstraint(item: title, attribute: .leading, relatedBy: .equal, toItem: logo, attribute: .trailing, multiplier: 1, constant: 6)
        topContainter.addConstraint(titleLeadingConstraint)
        let titleCenterY = NSLayoutConstraint(item: title, attribute: .centerY, relatedBy: .equal, toItem: topContainter, attribute: .centerY, multiplier: 1, constant: 0)
        topContainter.addConstraint(titleCenterY)
        let titleTrailingConstraint = NSLayoutConstraint(item: title, attribute: .trailing, relatedBy: .equal, toItem: extra, attribute: .leading, multiplier: 1, constant: -10)
        topContainter.addConstraint(titleTrailingConstraint)
        
        // Full Screen
        fullscreen.setTitle("", for: UIControlState())
        fullscreen.setImage(UIImage(named: "FullScreen"), for: UIControlState())
        fullscreen.addTarget(self, action: #selector(EVSVideoPlayer.fullscreenButtonTapped(_:)), for: .touchUpInside)
        fullscreen.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.addSubview(fullscreen)
        
        // fullscreen constraints
        let fullscreenTrailing = NSLayoutConstraint(item: fullscreen, attribute: .trailing, relatedBy: .equal, toItem: bottomContainer, attribute: .trailing, multiplier: 1, constant: -15)
        bottomContainer.addConstraint(fullscreenTrailing)
        let fullscreenCenterY = NSLayoutConstraint(item: fullscreen, attribute: .centerY, relatedBy: .equal, toItem: bottomContainer, attribute: .centerY, multiplier: 1, constant: 0)
        bottomContainer.addConstraint(fullscreenCenterY)
        
        // Playback time
        playback.text = ""
        playback.textColor = UIColor.white
        playback.font = UIFont(name: Fonts.OpenSans.Regular, size: 12)
        playback.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.addSubview(playback)
        
        let playbackTrailingConstraint = NSLayoutConstraint(item: playback, attribute: .trailing, relatedBy: .equal, toItem: fullscreen, attribute: .leading, multiplier: 1, constant: -10)
        bottomContainer.addConstraint(playbackTrailingConstraint)
        let playbackCenterY = NSLayoutConstraint(item: playback, attribute: .centerY, relatedBy: .equal, toItem: bottomContainer, attribute: .centerY, multiplier: 1, constant: 0)
        bottomContainer.addConstraint(playbackCenterY)
        
        // Seeker
        seeker.translatesAutoresizingMaskIntoConstraints = false
        seeker.isContinuous = true
        seeker.setThumbImage(UIImage(named: "Thumb"), for: UIControlState()) // 	67, 241, 105
        seeker.minimumTrackTintColor = UIColor(red: 67/255, green: 241/255, blue: 105/255, alpha: 1)
        seeker.addTarget(self, action: #selector(EVSVideoPlayer.sliderBeganTracking(_:)), for: .touchDown)
        seeker.addTarget(self, action: #selector(EVSVideoPlayer.sliderEndedTracking(_:)), for: UIControlEvents.touchUpInside)
        seeker.addTarget(self, action: #selector(EVSVideoPlayer.sliderEndedTracking(_:)), for: UIControlEvents.touchUpOutside)
        seeker.addTarget(self, action: #selector(EVSVideoPlayer.sliderValueChanged(_:)), for: .valueChanged)
        bottomContainer.addSubview(seeker)
        
        let seekerTrailingConstraint = NSLayoutConstraint(item: seeker, attribute: .trailing, relatedBy: .equal, toItem: playback, attribute: .leading, multiplier: 1, constant: -10)
        bottomContainer.addConstraint(seekerTrailingConstraint)
        let seekerLeadingConstraint = NSLayoutConstraint(item: seeker, attribute: .leading, relatedBy: .equal, toItem: play, attribute: .trailing, multiplier: 1, constant: 10)
        bottomContainer.addConstraint(seekerLeadingConstraint)
        let seekerCenterY = NSLayoutConstraint(item: seeker, attribute: .centerY, relatedBy: .equal, toItem: bottomContainer, attribute: .centerY, multiplier: 1, constant: 0)
        bottomContainer.addConstraint(seekerCenterY)
        
    
    }
    
    func extraButtonTapped(_ btn: UIButton) {
        
    }
    
    func fullscreenButtonTapped(_ btn: UIButton) {
        if UIScreen.main.bounds.width < UIScreen.main.bounds.height {
            if delegate != nil {
                userIsFullscreen = userIsFullscreen ? false : true
                delegate?.fullScreenTapped(userIsFullscreen)
            }
        }
    }
    
    func sliderBeganTracking(_ slider: UISlider) {
        playerRateBeforeSeek = videoPlayer.rate
        videoPlayer.pause()
    }
    
    func sliderEndedTracking(_ slider: UISlider!) {
        let videoDuration = CMTimeGetSeconds(videoPlayer.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(seeker.value)
        updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
        
        videoPlayer.seek(to: CMTimeMakeWithSeconds(elapsedTime, 1), completionHandler: { (completed: Bool) -> Void in
            if (self.playerRateBeforeSeek > 0) {
                self.videoPlayer.play()
            }
        }) 
    }
    
    func sliderValueChanged(_ slider: UISlider!) {
        let videoDuration = CMTimeGetSeconds(videoPlayer.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(seeker.value)
        updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
    }
    
    
    func triggerMenu(_ btn: UIButton) {
        if menuTopConstraint.constant == 0 && menuBottomConstraint.constant == 0 {
            self.menuTopConstraint.constant = -50
            self.menuBottomConstraint.constant = 50
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.layoutIfNeeded()
            })
        } else {
            self.menuTopConstraint.constant = 0
            self.menuBottomConstraint.constant = 0
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.layoutIfNeeded()
            })
        }

    }
    
    var menuTopConstraint: NSLayoutConstraint!
    var menuBottomConstraint: NSLayoutConstraint!
    fileprivate func setMenuConstraints(_ menuContainer: UIView, top: Bool) {
        let leftConstraint = NSLayoutConstraint(item: menuContainer, attribute: .leading, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        self.addConstraint(leftConstraint)
        
        let rightConstraint = NSLayoutConstraint(item: menuContainer, attribute: .trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        self.addConstraint(rightConstraint)

        let heightConstraint = NSLayoutConstraint(item: menuContainer, attribute: .height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
        menuContainer.addConstraint(heightConstraint)
        

        if top {
            menuTopConstraint = NSLayoutConstraint(item: menuContainer, attribute: .top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
            self.addConstraint(menuTopConstraint)
        } else {
            menuBottomConstraint = NSLayoutConstraint(item: menuContainer, attribute: .bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
            self.addConstraint(menuBottomConstraint)
        }
    }
    
   
}







