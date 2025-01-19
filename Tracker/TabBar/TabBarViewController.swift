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
        
        let trackersTitle = NSLocalizedString("trackers.navigationItem.title", comment: "Text displayed on tracker title")
        let statisticsTitle = NSLocalizedString("statistics.navigationItem.title", comment: "Text displayed on statistics title")
        
        trackers.tabBarItem = UITabBarItem(
            title: trackersTitle,
            image: UIImage(named: "trackers_tabBar_icon"),
            selectedImage: nil)
        statistics.tabBarItem = UITabBarItem(
            title: statisticsTitle,
            image: UIImage(named: "statistics_tabBar_icon"),
            selectedImage: nil)
        
    
        let navigationTrackers = UINavigationController(rootViewController: trackers)
        let navigationStatistics = UINavigationController(rootViewController: statistics)
        
        trackers.navigationItem.title = trackersTitle
        statistics.navigationItem.title = statisticsTitle
        
        navigationTrackers.navigationBar.prefersLargeTitles = true
        navigationStatistics.navigationBar.prefersLargeTitles = true
        
        viewControllers = [navigationTrackers, navigationStatistics]
    }
}

