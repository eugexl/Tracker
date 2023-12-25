//
//  TabBarController.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 20.12.2023.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackersVC = TrackersNavigationController()
        trackersVC.tabBarItem = UITabBarItem(title: "Трекекы", image: UIImage(named: ImageNames.trackerTBI), selectedImage: nil)
        
        let statisticsVC = StatisticsViewController()
        statisticsVC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: ImageNames.statisticsTBI), selectedImage: nil)
        
        viewControllers = [
            trackersVC,
            statisticsVC
        ]
        
        let tabBarTopSeparator = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 1.0))
        tabBarTopSeparator.backgroundColor = UIColor(named: ColorNames.gray)
        tabBar.addSubview(tabBarTopSeparator)
    }
}
