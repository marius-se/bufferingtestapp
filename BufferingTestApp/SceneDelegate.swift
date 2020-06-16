//
//  SceneDelegate.swift
//  BufferingTestApp
//
//  Created by Marius Seufzer on 16.06.20.
//  Copyright © 2020 Marius Seufzer. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.windowScene = windowScene

        let tabBarController = UITabBarController()
        
        let singleVideoViewController = UINavigationController(rootViewController: SingleVideoViewController())
        singleVideoViewController.tabBarItem = UITabBarItem(
            title: "Single",
            image: UIImage(systemName: "arrowshape.turn.up.left"),
            selectedImage: UIImage(systemName: "arrowshape.turn.up.left.fill")
        )

        let multiVideoViewController = UINavigationController(rootViewController: MultiVideoViewController())
        multiVideoViewController.tabBarItem = UITabBarItem(
            title: "Multi",
            image: UIImage(systemName: "arrowshape.turn.up.left.2"),
            selectedImage: UIImage(systemName: "arrowshape.turn.up.left.2.fill")
        )

        tabBarController.addChild(singleVideoViewController)
        tabBarController.addChild(multiVideoViewController)
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }

}

