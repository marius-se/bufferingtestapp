//
//  MultiVideoViewController.swift
//  BufferingTestApp
//
//  Created by Marius Seufzer on 16.06.20.
//  Copyright © 2020 Marius Seufzer. All rights reserved.
//

import UIKit

class MultiVideoViewController: UIViewController {
    // MARK: - Configuration
    private let testVideoURLs: [URL] = [
        URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4")!,
        URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!,
        URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4")!,
        URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4")!,
        URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4")!
    ]

    // MARK: - Declaration
    private let videoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        configureTestVideos()
    }

    private func setUpViews() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Test multitple videos"
        tabBarItem = UITabBarItem(
            title: "Multi",
            image: UIImage(systemName: "arrowshape.turn.up.left.2"),
            selectedImage: UIImage(systemName: "arrowshape.turn.up.left.2.fill")
        )

        view.addSubview(videoStackView)

        NSLayoutConstraint.activate([
            videoStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            videoStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            videoStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func configureTestVideos() {
        for (index, value) in testVideoURLs.enumerated() {
            let viewModel = VideoControlCellViewModel(
                url: value,
                title: "\(index + 1)"
            )
            videoStackView.addArrangedSubview(VideoControlCellView(viewModel: viewModel))
        }
    }


}
