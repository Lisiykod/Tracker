//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Olga Trofimova on 22.11.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    let launchService = UserDefaultsService.shared

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let onboardingPageViewController = OnboardingPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        window?.rootViewController = !launchService.getIsFirstLaunch() ? onboardingPageViewController : TabBarViewController()
        window?.makeKeyAndVisible()
    }

}

