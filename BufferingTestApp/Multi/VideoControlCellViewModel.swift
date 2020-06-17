//
//  VideoControlCellViewModel.swift
//  BufferingTestApp
//
//  Created by Marius Seufzer on 17.06.20.
//  Copyright © 2020 Marius Seufzer. All rights reserved.
//

import UIKit
import Combine
import AVFoundation

class VideoControlCellViewModel: NSObject {
    let title: String
    @Published var length: CMTime?
    @Published var bufferProgress: Float = 0

    private(set) var state = CurrentValueSubject<AVPlayer.TimeControlStatus, Never>(.paused)

    private let videoURL: URL
    private let avPlayer: AVPlayer

    deinit {
        avPlayer.removeObserver(self, forKeyPath: "timeControlStatus")
        avPlayer.currentItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
    }

    init(url videoURL: URL, title: String) {
        self.videoURL = videoURL
        self.title = title
        let urlAsset = AVURLAsset(url: videoURL)
        let playerItem = AVPlayerItem(asset: urlAsset)
        self.avPlayer = AVPlayer(playerItem: playerItem)
        super.init()

        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.length = self?.avPlayer.currentItem!.asset.duration
        }

        setUpObservers()
    }

    private func setUpObservers() {
        avPlayer.addObserver(self, forKeyPath: "timeControlStatus", options: [], context: nil)
        avPlayer.currentItem!.addObserver(self, forKeyPath: "loadedTimeRanges", options: [], context: nil)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is AVPlayer {
            switch keyPath {
            case "timeControlStatus":
                state.value = avPlayer.timeControlStatus
            default:
                break
            }
        } else if object is AVPlayerItem {
            switch keyPath {
            case "loadedTimeRanges":
                guard let timeRange = avPlayer.currentItem?.loadedTimeRanges.first as? CMTimeRange else { return }
                bufferProgress = Float(timeRange.end.seconds / avPlayer.currentItem!.asset.duration.seconds)
            default:
                break
            }
        }
    }

    func play() {
        avPlayer.play()
    }

    func pause() {
        avPlayer.pause()
    }
}
