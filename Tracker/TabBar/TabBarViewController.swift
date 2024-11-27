//
//  TabBarViewController.swift
//  Tracker
//
//  Created by Olga Trofimova on 23.11.2024.
//

import UIKit

final class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTapBarViewControllers()
    }
    
    private func setupTapBarViewControllers() {
        let trackers = TrackersViewController()
        let statistics = StatisticsViewController()
        
        trackers.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "trackers_tabBar_icon"),
            selectedImage: nil)
        statistics.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "statistics_tabBar_icon"),
            selectedImage: nil)
        
    
        let navigationTrackers = UINavigationController(rootViewController: trackers)
        let navigationStatistics = UINavigationController(rootViewController: statistics)
        
        trackers.navigationItem.title = "Трекеры"
        statistics.navigationItem.title = "Статистика"
        
        navigationTrackers.navigationBar.prefersLargeTitles = true
        navigationStatistics.navigationBar.prefersLargeTitles = true
        
        viewControllers = [navigationTrackers, navigationStatistics]
    }
}

