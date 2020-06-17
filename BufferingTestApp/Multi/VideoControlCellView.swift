//
//  VideoControlCellView.swift
//  BufferingTestApp
//
//  Created by Marius Seufzer on 17.06.20.
//  Copyright © 2020 Marius Seufzer. All rights reserved.
//

import UIKit
import Combine
import AVFoundation

class VideoControlCellView: UIView {

    private let viewModel: VideoControlCellViewModel

    private let playerButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let progressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let progressView: UIProgressView = {
        let progress = UIProgressView()
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private var cancellables: Set<AnyCancellable> = []

    init(viewModel: VideoControlCellViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setUpViews()
        setUpBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpViews() {
        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(playerButton)
        stackView.addArrangedSubview(progressView)
        stackView.addArrangedSubview(progressLabel)

        titleLabel.text = viewModel.title

        playerButton.addTarget(self, action: #selector(didTapPlayerButton), for: .touchUpInside)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            titleLabel.widthAnchor.constraint(equalToConstant: 70),
            playerButton.widthAnchor.constraint(equalToConstant: 20),
            progressView.widthAnchor.constraint(equalToConstant: 150)
        ])

        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

    private func setUpBindings() {
        viewModel.state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case .paused, .waitingToPlayAtSpecifiedRate:
                    self?.playerButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                case .playing:
                    self?.playerButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                @unknown default:
                    fatalError("Unknown state")
                }
            }
        .store(in: &cancellables)

        viewModel.$bufferProgress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bufferProgress in
                self?.progressLabel.text = String(format: "%.1f", bufferProgress * 100) + "%"
                self?.progressView.setProgress(bufferProgress, animated: true)
        }.store(in: &cancellables)

        viewModel.$length
            .receive(on: DispatchQueue.main)
            .sink { [weak self] time in
                guard let formattedTime = time?.formattedString() else { return }
                self?.titleLabel.text = (self?.viewModel.title)! + " - (\(formattedTime))"
        }.store(in: &cancellables)
    }

    @objc private func didTapPlayerButton() {
        switch viewModel.state.value {
        case .paused, .waitingToPlayAtSpecifiedRate:
            viewModel.play()
        case .playing:
            viewModel.pause()
        @unknown default:
            fatalError("Unknown state")
        }
    }
}
