//
//  VideoView.swift
//
//  Created by Sergey Gorin on 16/09/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit
import AVFoundation

class VideoView: UIView {
    
    var player: AVPlayer? {
        get {
            return playerLayer?.player
        }
        set {
            playerLayer?.player = newValue
        }
    }
    
    var playerLayer: AVPlayerLayer? {
        return layer as? AVPlayerLayer
    }
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    override var bounds: CGRect {
        didSet {
            playerLayer?.frame = bounds
        }
    }
    
    /// Defines how the video is displayed within a layer’s bounds rectangle
    var videoGravity: AVLayerVideoGravity = .resizeAspectFill
    
    /// Indicates whether audio session is ambient or not.
    /// True value means that acivated audio session will not interrupt any other
    /// audio sessions on the device .
    /// Applicable only under iOS 10.0+
    var isAudioSessionAmbient: Bool = true
    
    /// Whether video playback prevents display and device sleep or not.
    /// Applicable only under iOS 12.0+
    var preventsDisplaySleepDuringVideoPlayback: Bool = true
    
    /// Transparency value from 0.0 to 1.0
    var overlayAlpha: CGFloat = 0.0 {
        didSet {
            overlayView.alpha = overlayAlpha
        }
    }
    
    /// Mute or Unmute the video
    var isMuted = true {
        didSet {
            playerLayer?.player?.isMuted = isMuted
        }
    }
    
    /// Whether the player should play video in a loop mode
    var isLoopingEnabled = true
    
    lazy var overlayView = UIView().with {
        $0.backgroundColor = .black
    }
    
    init() {
        super.init(frame: .zero)
        prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepare()
    }
    
    func prepare() {
        playerLayer?.player = AVPlayer(playerItem: nil)
        addSubview(overlayView)
        overlayView.xt.pinEdges()
    }
    
    deinit {
        pause()
        removeObservers()
    }
    
    @objc private func playerItemDidReachEnd(notification: Notification) {
        if isLoopingEnabled { restart() }
    }
    
    @objc private func willEnterForeground(notification: Notification) {
        resume()
    }
}

extension VideoView {
    
    func play(url: URL, overlayAlpha: CGFloat = 0.3, isLooping: Bool = true) {
        
        if isAudioSessionAmbient {
            if #available(iOS 10.0, *) {
                try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
                try? AVAudioSession.sharedInstance().setActive(true)
            }
        }
        
        if #available(iOS 12.0, *) {
            player?.preventsDisplaySleepDuringVideoPlayback = preventsDisplaySleepDuringVideoPlayback
        }
        
        NotificationCenter.default.addUniqueObserver(
            self,
            selector: #selector(willEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addUniqueObserver(
            self,
            selector: #selector(playerItemDidReachEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
        
        overlayView.alpha = overlayAlpha
        
        player?.replaceCurrentItem(with: AVPlayerItem(url: url))
        player?.actionAtItemEnd = .none
        player?.isMuted = isMuted
        player?.play()
        
        playerLayer?.needsDisplayOnBoundsChange = true
        playerLayer?.videoGravity = videoGravity
        playerLayer?.zPosition = -1
    }
    
    func pause() {
        player?.pause()
    }
    
    func resume() {
        player?.play()
    }
    
    func restart() {
        player?.currentItem?.seek(to: .zero) { _ in }
    }
}

extension VideoView {
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func generateThumbnail(from url: URL, at time: CMTime) throws -> UIImage {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        let thumbnailImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
        return UIImage(cgImage: thumbnailImage)
    }
}
