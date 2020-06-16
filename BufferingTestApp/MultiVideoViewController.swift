//
//  MultiVideoViewController.swift
//  BufferingTestApp
//
//  Created by Marius Seufzer on 16.06.20.
//  Copyright © 2020 Marius Seufzer. All rights reserved.
//

import UIKit

class MultiVideoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }

    private func setUpViews() {
        view.backgroundColor = .systemRed
        navigationItem.title = "Test multitple videos"
        tabBarItem = UITabBarItem(
            title: "Multi",
            image: UIImage(systemName: "arrowshape.turn.up.left.2"),
            selectedImage: UIImage(systemName: "arrowshape.turn.up.left.2.fill")
        )
    }


}
