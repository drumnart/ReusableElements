//
//  VideoPlayerView.swift
//
//  Created by Sergey Gorin on 05/02/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit
import AVFoundation

typealias Player = AVPlayer
typealias PlayerItem = AVPlayerItem
typealias PlayerAsset = AVAsset

class VideoPlayerView: UIView {
    
    struct Settings {
        var startImmediately = true
    }
    
    var settings = Settings()
    
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
    
    var status: AVPlayerItem.Status {
        return player?.currentItem?.status ?? .unknown
    }
    
    var isPaused: Bool {
        return player?.timeControlStatus == .paused
    }
    
    var isPlaying: Bool {
        return player?.timeControlStatus == .playing
    }
    
    var isMuted: Bool {
        return player?.volume == 0.0
    }
    
    var hidesCloseButton = true {
        didSet {
            closeButton.isHidden = hidesCloseButton
        }
    }
    
    var hidesMuteButton = false {
        didSet {
            muteButton.isHidden = hidesMuteButton
        }
    }
    
    var hidesPlayPauseButton = true {
        didSet {
            playPauseButton.isHidden = hidesPlayPauseButton
        }
    }
    
    /// Whether the player is currently in loop mode or not
    private(set) var isLooping = false
    
    private lazy var onTapClosure: (() -> ()) = didTap
    private lazy var onDoubleTapClosure: (() -> ()) = didDoubleTap
    private var onVolumeDidChangeClosure: ((_ volume: Float) -> ())?
    private var onCloseBtnTouchClosure: UIControl.ActionClosure = { _ in }
    
    private var playerStatusObserver: NSKeyValueObservation?
    private var currentItemStatusObserver: NSKeyValueObservation?
    
    lazy var muteButton = WidenTouchAreaButton(type: .custom).with {
        $0.isUserInteractionEnabled = false
        $0.setImage(Asset.Video.volumeOn.image, for: .normal)
        $0.setImage(Asset.Video.volumeOff.image, for: .selected)
    }
    
    lazy var previewImageView = UIImageView().with {
        $0.alpha = 1.0
    }
    
    var closeButton = WidenTouchAreaButton(type: .custom).with {
        $0.isHidden = true
        $0.setImage(Asset.Video.cancel24.image, for: [])
        $0.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
    }
    
    var playPauseButton = WidenTouchAreaButton(type: .custom).with {
        $0.isHidden = true
        $0.setImage(Asset.Video.pauseCircleFilled24.image, for: .normal)
        $0.setImage(Asset.Video.playCircleFilled24.image, for: .selected)
        $0.addTarget(self, action: #selector(playPauseButtonAction), for: .touchUpInside)
    }
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    init() {
        super.init(frame: .zero)
        prepareSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareSubviews()
    }
    
    deinit {
        stopLooping()
        removeObservers()
    }
}

extension VideoPlayerView {
    
    func prepareSubviews() {
        xt.addSubviews(previewImageView, playPauseButton, muteButton, closeButton)
        
        previewImageView.xt.pinEdges()
        
        playPauseButton.xt.layout {
            $0.leading(8)
            $0.bottom(-8)
            $0.size(w: 28, h: 28)
        }
        
        muteButton.xt.layout {
            $0.edges([.right, .bottom],
                     insets: .apply(bottom: 13, right: 16))
            $0.size(w: 28, h: 28)
        }
        
        closeButton.xt.layout {
            $0.pinEdges([.top, .right])
            $0.size(w: 28, h: 28)
        }
        
        addDefaultGestureRecognizers()
    }
    
    func resetSubviews() {
        previewImageView.alpha = 1.0
    }
    
    func configure(with player: Player?,
                   videoGravity: AVLayerVideoGravity = .resizeAspectFill) {
        removeObservers()
        playerLayer?.player = player
        playerLayer?.videoGravity = videoGravity
        resetSubviews()
        addObservers()
    }
    
    func replaceCurrentItem(with item: PlayerItem) {
        player?.replaceCurrentItem(with: item)
    }
}

extension VideoPlayerView {
    
    func startPlayback() {
        if status == .readyToPlay {
            player?.play()
            playPauseButton.isSelected = true
        }
    }
    
    func pausePlayback() {
        player?.pause()
        playPauseButton.isSelected = false
    }
    
    func onTap(_ closure: @escaping () -> ()) {
        onTapClosure = closure
    }
    
    func onDoubleTap(_ closure: @escaping () -> ()) {
        onDoubleTapClosure = closure
    }
    
    func toggleVolume() {
        player?.volume == 1.0 ? mute() : unmute()
    }
    
    func mute() {
        player?.volume = 0.0
        muteButton.isSelected = true
    }
    
    func unmute() {
        player?.volume = 1.0
        muteButton.isSelected = false
    }
    
    func onClose(_ closure: @escaping UIControl.ActionClosure) {
        onCloseBtnTouchClosure = closure
    }
    
    func onVolumeDidChange(_ closure: ((_ volume: Float) -> ())?) {
        onVolumeDidChangeClosure = closure
    }
    
    func startLooping() {
        player?.actionAtItemEnd = .none
        NotificationCenter.default.addUniqueObserver(self,
                                                     selector: #selector(playerItemDidReachEnd),
                                                     name: .AVPlayerItemDidPlayToEndTime,
                                                     object: nil)
        isLooping = true
    }
    
    func stopLooping() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        isLooping = false
    }
    
    @objc private func playerItemDidReachEnd(notification: Notification) {
        (notification.object as? AVPlayerItem).let {
            $0.seek(to: .zero) { _ in }
        }
    }
    
    @objc private func playPauseButtonAction(_ sender: UIButton) {
        sender.isSelected ? pausePlayback() : startPlayback()
    }
    
    @objc private func closeAction(_ sender: UIButton) {
        onCloseBtnTouchClosure(sender)
    }
}
    
extension VideoPlayerView {
    
    private func addDefaultGestureRecognizers() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap)).with {
            $0.numberOfTapsRequired = 2
        }
        singleTap.require(toFail: doubleTap)
        addGestureRecognizer(singleTap)
        addGestureRecognizer(doubleTap)
    }
    
    @objc private func didTap() {
        toggleVolume()
        onVolumeDidChangeClosure?(player?.volume ?? 0.0)
    }
    
    @objc private func didDoubleTap() {
    }
}

extension VideoPlayerView {
    
    func addObservers() {
        
        currentItemStatusObserver = player?
            .currentItem?
            .observe(\.status, options: [.new, .initial]) { [unowned self] (item, change) in
                
            switch item.status {
            case .readyToPlay:
                if self.settings.startImmediately && !self.isPlaying {
                    self.startPlayback()
                }
                UIView.animate(withDuration: 0.5) {
                    self.previewImageView.alpha = 0.0
                }
                
            case .failed:
                self.printError(item.error)
                
            default: break
            }
        }
        
        #if DEBUG
        addErrorsObservers()
        #endif
    }
    
    private func addErrorsObservers() {
    
        playerStatusObserver = player?
            .observe(\.status, options: [.new, .initial]) { [unowned self] (item, change) in
                if item.status == .failed {
                    self.printError(item.error)
                }
        }
        
        // Watch notifications
        let center = NotificationCenter.default
        center.addUniqueObserver(self,
                                 selector: #selector(getNewErrorLogEntry),
                                 name: .AVPlayerItemNewErrorLogEntry,
                                 object: player?.currentItem)
        center.addUniqueObserver(self,
                                 selector: #selector(failedToPlayToEndTime),
                                 name: .AVPlayerItemFailedToPlayToEndTime,
                                 object: player?.currentItem)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
        playerStatusObserver?.invalidate()
        playerStatusObserver = nil
        currentItemStatusObserver?.invalidate()
        currentItemStatusObserver = nil
    }
    
    // Getting error from Notification payload
    @objc func getNewErrorLogEntry(_ notification: Notification) {
        guard let object = notification.object,
            let playerItem = object as? AVPlayerItem else {
            return
        }
        guard let errorLog = playerItem.errorLog() else {
            return
        }
        print("[Error]: \(errorLog)")
    }
    
    @objc func failedToPlayToEndTime(_ notification: Notification) {
        if let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? NSError {
            print("[Error]: \(error)")
        }
    }
    
    private func printError(_ error: Error?) {
        #if DEBUG
        if let error = error {
            print("[Error]: \(error)")
        }
        #endif
    }
}
