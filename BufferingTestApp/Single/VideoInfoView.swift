//
//  VideoInfoView.swift
//  BufferingTestApp
//
//  Created by Marius Seufzer on 16.06.20.
//  Copyright © 2020 Marius Seufzer. All rights reserved.
//

import UIKit
import AVFoundation

class VideoInfoView: UIView {
    private let listStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let timeControlStatusLabel = UILabel()
    private let reasonForWaitingToPlayLabel = UILabel()
    private let playerRateLabel = UILabel()
    private let timebaseRateLabel = UILabel()
    private let currentTimeLabel = UILabel()
    private let loadedTimeRangesLabel = UILabel()
    private let isPlaybackLikelyToKeepUpLabel = UILabel()
    private let isPlaybackBufferFullLabel = UILabel()
    private let isPlaybackBufferEmptyLabel = UILabel()

    init() {
        super.init(frame: .zero)

        addSubview(listStackView)
        NSLayoutConstraint.activate([
            listStackView.topAnchor.constraint(equalTo: topAnchor),
            listStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            listStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            listStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        addInfo(description: "timeControlStatus", statusLabel: timeControlStatusLabel)
        addInfo(description: "reasonForWaitingToPlay", statusLabel: reasonForWaitingToPlayLabel)
        addInfo(description: "playerRate", statusLabel: playerRateLabel)
        addInfo(description: "timebaseRate", statusLabel: timebaseRateLabel)
        addInfo(description: "currentTime", statusLabel: currentTimeLabel)
        addInfo(description: "loadedTimeRanges", statusLabel: loadedTimeRangesLabel)
        addInfo(description: "isPlaybackLikelyToKeepUp", statusLabel: isPlaybackLikelyToKeepUpLabel)
//        addInfo(description: "isPlaybackBufferFull", statusLabel: isPlaybackBufferFullLabel)
        addInfo(description: "isPlaybackBufferEmpty", statusLabel: isPlaybackBufferEmptyLabel)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// This method will add a new line to the listStackView. It creates a description label with the passed description and puts it together with the
    /// statusLabel in a horizontal StackView.
    private func addInfo(description: String, statusLabel: UILabel) {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 8

        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.textAlignment = .right
        descriptionLabel.font = .systemFont(ofSize: 13, weight: .semibold)

        statusLabel.font = .systemFont(ofSize: 13, weight: .regular)

        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(statusLabel)

        listStackView.addArrangedSubview(stackView)
    }

    func setTimeControlStatus(_ timeControlStatus: AVPlayer.TimeControlStatus) {
        switch timeControlStatus {
        case .paused:
            timeControlStatusLabel.text = "Paused"
            timeControlStatusLabel.backgroundColor = .systemRed
        case .playing:
            timeControlStatusLabel.text = "Playing"
            timeControlStatusLabel.backgroundColor = .systemGreen
        case .waitingToPlayAtSpecifiedRate:
            timeControlStatusLabel.text = "Waiting"
            timeControlStatusLabel.backgroundColor = .systemOrange
        @unknown default:
            fatalError("Unknown case")
        }
    }

    func setReasonForWaitingToPlay(_ reason: AVPlayer.WaitingReason?) {
        switch reason {
        case .some(.evaluatingBufferingRate):
            reasonForWaitingToPlayLabel.text = "Evaluating buffering rate"
        case .some(.noItemToPlay):
            reasonForWaitingToPlayLabel.text = "Not item to play"
        case .some(.toMinimizeStalls):
            reasonForWaitingToPlayLabel.text = "Minimizing Stalls"
        case .none:
            reasonForWaitingToPlayLabel.text = "-"
        default:
            fatalError("Unexpected case")
        }
    }

    func setPlayerRate(_ playerRate: Float?) {
        playerRateLabel.text = playerRate != nil ? String(playerRate!) : "-"
    }

    func setTimebaseRate(_ timebaseRate: CMTimebase?) {
        timebaseRateLabel.text = timebaseRate != nil ? "\(timebaseRate!.rate)" : "-"
    }

    func setCurrentTime(_ currentTime: CMTime?) {
        currentTimeLabel.text = currentTime != nil ? currentTime!.formattedString() : "-"
    }

    func setLoadedTimeRanges(_ loadedTimeRanges: [NSValue]?) {
        guard let loadedTimeRanges = loadedTimeRanges else {
            loadedTimeRangesLabel.text = "-"
            return
        }
        guard let timeRange = loadedTimeRanges.first as? CMTimeRange else { return }
        loadedTimeRangesLabel.text = "\(timeRange.start.formattedString()) to \(timeRange.end.formattedString())"
    }

    func setIsPlaybackLikelyToKeepUp(_ isPlaybackLikelyToKeepUp: Bool?) {
        isPlaybackLikelyToKeepUpLabel.text = isPlaybackLikelyToKeepUp != nil ? String(isPlaybackLikelyToKeepUp!) : "-"
    }

    func setIsPlaybackBufferFull(_ isPlaybackBufferFull: Bool?) {
        isPlaybackBufferFullLabel.text = isPlaybackBufferFull != nil ? String(isPlaybackBufferFull!) : "-"
    }

    func setIsPlaybackBufferEmpty(_ isPlaybackBufferEmpty: Bool?) {
        isPlaybackBufferEmptyLabel.text = isPlaybackBufferEmpty != nil ? String(isPlaybackBufferEmpty!) : "-"
    }
}
