//
//  SingleVideoViewController.swift
//  BufferingTestApp
//
//  Created by Marius Seufzer on 16.06.20.
//  Copyright © 2020 Marius Seufzer. All rights reserved.
//

import UIKit
import Combine
import AVKit

class SingleVideoViewController: UIViewController {
    // MARK: - Configuration
    private let testVideoURL = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!

    // MARK: - Declaration
    private lazy var playerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemFill
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.addSublayer(playerLayer)
        return view
    }()

    private let controlButtonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var playerLayer: AVPlayerLayer = {
        let avPlayerLayer = AVPlayerLayer()
        let player = AVPlayer()
        player.volume = .zero
        avPlayerLayer.player = player
        return avPlayerLayer
    }()

    private let videoInfoView: VideoInfoView = {
        let videoInfoView = VideoInfoView()
        videoInfoView.translatesAutoresizingMaskIntoConstraints = false
        return videoInfoView
    }()

    private var currentTimeObserver: Any?

    private var observersAreActive: Bool = false

    private var backupPlayerItem: AVPlayerItem?

    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        setUpBindings()
        resetPlayer()
        resetVideoInfoView()
        setUpObservers()
    }

    override func viewDidDisappear(_ animated: Bool) {
        if let player = playerLayer.player {
            player.pause()
            tearDownObservers()
            backupPlayerItem = player.currentItem
            player.replaceCurrentItem(with: nil)
        }

        super.viewDidDisappear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let player = playerLayer.player, let backupPlayerItem = backupPlayerItem {
            player.replaceCurrentItem(with: backupPlayerItem)
            setUpObservers()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if playerLayer.frame == .zero && playerContainerView.bounds != .zero {
            playerLayer.frame = playerContainerView.bounds
        }
    }

    // MARK: - Setup
    private func setUpViews() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Test single video"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(didTapResetButton)
        )

        let pauseButton = UIButton()
        pauseButton.setTitle("PAUSE", for: .normal)
        pauseButton.addTarget(self, action: #selector(didTapPause), for: .touchUpInside)
        let playButton = UIButton()
        playButton.setTitle("PLAY", for: .normal)
        playButton.addTarget(self, action: #selector(didTapPlay), for: .touchUpInside)
        let playImmediatelyButton = UIButton()
        playImmediatelyButton.setTitle("PLAY IMMEDIATELY", for: .normal)
        playImmediatelyButton.addTarget(self, action: #selector(didTapPlayImmediately), for: .touchUpInside)

        [pauseButton, playButton, playImmediatelyButton].forEach {
            $0.setTitleColor(.systemBlue, for: .normal)
            $0.setTitleColor(.systemTeal, for: .highlighted)
        }

        view.addSubview(playerContainerView)
        view.addSubview(controlButtonStackView)
        controlButtonStackView.addArrangedSubview(pauseButton)
        controlButtonStackView.addArrangedSubview(playButton)
        controlButtonStackView.addArrangedSubview(playImmediatelyButton)
        view.addSubview(videoInfoView)

        NSLayoutConstraint.activate([
            playerContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            playerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            playerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            playerContainerView.heightAnchor.constraint(equalToConstant: 250),

            controlButtonStackView.topAnchor.constraint(equalTo: playerContainerView.bottomAnchor, constant: 8),
            controlButtonStackView.leadingAnchor.constraint(equalTo: playerContainerView.leadingAnchor, constant: 8),
            controlButtonStackView.trailingAnchor.constraint(equalTo: playerContainerView.trailingAnchor, constant: -8),

            videoInfoView.topAnchor.constraint(equalTo: controlButtonStackView.bottomAnchor, constant: 8),
            videoInfoView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setUpBindings() {
        NotificationCenter
            .default
            .publisher(for: kCMTimebaseNotification_EffectiveRateChanged as Notification.Name)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                guard let currentTimebase = self.playerLayer.player?.currentItem?.timebase else { return }
                self.videoInfoView.setTimebaseRate(currentTimebase)
        }.store(in: &cancellables)
    }

    private func setUpObservers() {
        guard let player = playerLayer.player,
            let playerItem = player.currentItem,
            observersAreActive == false else { return }
        player.addObserver(self, forKeyPath: "timeControlStatus", options: [], context: nil)
        player.addObserver(self, forKeyPath: "reasonForWaitingToPlay", options: [], context: nil)
        player.addObserver(self, forKeyPath: "rate", options: [], context: nil)

        currentTimeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
            queue: .main,
            using: { [weak self] in
                self?.videoInfoView.setCurrentTime($0)
            }
        )

        playerItem.addObserver(self, forKeyPath: "timebase", options: [], context: nil)
        playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: [], context: nil)
        playerItem.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: [], context: nil)
        playerItem.addObserver(self, forKeyPath: "playbackBufferEmpty", options: [], context: nil)
        // This one is not working for some reason
        playerItem.addObserver(self, forKeyPath: "playbackBufferFull", options: [], context: nil)

        observersAreActive = true
    }

    private func tearDownObservers() {
        guard let player = playerLayer.player,
            let playerItem = player.currentItem,
            observersAreActive == true else { return }
        player.removeObserver(self, forKeyPath: "timeControlStatus")
        player.removeObserver(self, forKeyPath: "reasonForWaitingToPlay")
        player.removeObserver(self, forKeyPath: "rate")
        if let currentTimeObserver = currentTimeObserver {
            player.removeTimeObserver(currentTimeObserver)
            self.currentTimeObserver = nil
        }

        playerItem.removeObserver(self, forKeyPath: "timebase")
        playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
        playerItem.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        playerItem.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        playerItem.removeObserver(self, forKeyPath: "playbackBufferFull")

        observersAreActive = false

    }

    private func resetPlayer() {
        guard let player = playerLayer.player else { return }
        player.pause()
        player.replaceCurrentItem(with: AVPlayerItem(url: testVideoURL))
    }

    private func resetVideoInfoView() {
        videoInfoView.setTimeControlStatus(.paused)
        videoInfoView.setReasonForWaitingToPlay(nil)
        videoInfoView.setPlayerRate(nil)
        videoInfoView.setTimebaseRate(nil)
        videoInfoView.setCurrentTime(nil)
        videoInfoView.setLoadedTimeRanges(nil)
        videoInfoView.setIsPlaybackLikelyToKeepUp(nil)
        videoInfoView.setIsPlaybackBufferEmpty(nil)
    }

    @objc private func didTapPause() {
        playerLayer.player?.pause()
    }

    @objc private func didTapPlay() {
        playerLayer.player?.play()
    }

    @objc private func didTapPlayImmediately() {
        playerLayer.player?.playImmediately(atRate: 1)
    }

    @objc private func didTapResetButton() {
        tearDownObservers()
        resetPlayer()
        resetVideoInfoView()
        setUpObservers()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let player = playerLayer.player else { return }
        if object is AVPlayer {
            switch keyPath {
            case "timeControlStatus":
                videoInfoView.setTimeControlStatus(player.timeControlStatus)
            case "reasonForWaitingToPlay":
                videoInfoView.setReasonForWaitingToPlay(player.reasonForWaitingToPlay)
            case "rate":
                videoInfoView.setPlayerRate(player.rate)
            default:
                break
            }
        } else if object is AVPlayerItem {
            switch keyPath {
            case "loadedTimeRanges":
                videoInfoView.setLoadedTimeRanges(player.currentItem!.loadedTimeRanges)
            case "playbackLikelyToKeepUp":
                videoInfoView.setIsPlaybackLikelyToKeepUp(player.currentItem!.isPlaybackLikelyToKeepUp)
            case "playbackBufferEmpty":
                videoInfoView.setIsPlaybackBufferEmpty(player.currentItem!.isPlaybackBufferEmpty)
            case "playbackBufferFull":
                videoInfoView.setIsPlaybackBufferFull(player.currentItem!.isPlaybackBufferFull)
            default:
                break
            }
        }
    }
}
