//
//  SingleVideoViewController.swift
//  BufferingTestApp
//
//  Created by Marius Seufzer on 16.06.20.
//  Copyright © 2020 Marius Seufzer. All rights reserved.
//

import UIKit
import AVKit

class SingleVideoViewController: UIViewController {

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

    private let playerLayer: AVPlayerLayer = {
        let avPlayerLayer = AVPlayerLayer()

        let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
        let playerItem = AVPlayerItem(asset: .init(url: url))
        let player = AVPlayer(playerItem: playerItem)
        avPlayerLayer.player = player

        return avPlayerLayer
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if playerLayer.frame == .zero && playerContainerView.bounds != .zero {
            playerLayer.frame = playerContainerView.bounds
        }
    }

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

        NSLayoutConstraint.activate([
            playerContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 64),
            playerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            playerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            playerContainerView.heightAnchor.constraint(equalToConstant: 300),

            controlButtonStackView.topAnchor.constraint(equalTo: playerContainerView.bottomAnchor, constant: 8),
            controlButtonStackView.leadingAnchor.constraint(equalTo: playerContainerView.leadingAnchor, constant: 8),
            controlButtonStackView.trailingAnchor.constraint(equalTo: playerContainerView.trailingAnchor, constant: -8)
        ])
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
}

