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

        let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
        let playerItem = AVPlayerItem(asset: .init(url: url))
        let player = AVPlayer(playerItem: playerItem)
        player.volume = .zero
        player.addObserver(self, forKeyPath: "timeControlStatus", options: [], context: nil)
        player.addObserver(self, forKeyPath: "reasonForWaitingToPlay", options: [], context: nil)
        player.addObserver(self, forKeyPath: "rate", options: [], context: nil)
        player.addObserver(self, forKeyPath: "loadedTimeRanges", options: [], context: nil)
        player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
            queue: .main,
            using: { [weak self] in
                self?.videoInfoView.setCurrentTime($0)
            }
        )
        player.currentItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: [], context: nil)
        playerItem.addObserver(self, forKeyPath: "timebase", options: [], context: nil)
        avPlayerLayer.player = player

        return avPlayerLayer
    }()

    private let videoInfoView: VideoInfoView = {
        let videoInfoView = VideoInfoView()
        videoInfoView.translatesAutoresizingMaskIntoConstraints = false
        return videoInfoView
    }()

    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        setUpBindings()
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

    @objc private func didTapPause() {
        playerLayer.player?.pause()
    }

    @objc private func didTapPlay() {
        playerLayer.player?.play()
    }

    @objc private func didTapPlayImmediately() {
        playerLayer.player?.playImmediately(atRate: 1)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let player = playerLayer.player else { return }
        if object as AnyObject? === player {
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
        } else if object as AnyObject? === player.currentItem {
            switch keyPath {
            case "loadedTimeRanges":
                videoInfoView.setLoadedTimeRanges(player.currentItem!.loadedTimeRanges)
            default:
                break
            }
        }
    }
}
