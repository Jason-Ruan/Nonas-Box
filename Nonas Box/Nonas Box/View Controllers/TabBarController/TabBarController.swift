//
//  TabBarController.swift
//  Nonas Box
//
//  Created by Jason Ruan on 11/25/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewControllers()
        tabBar.isTranslucent = false
        tabBar.tintColor = .white
        tabBar.barTintColor = .black
        tabBar.unselectedItemTintColor = #colorLiteral(red: 0.3599925637, green: 0.361663878, blue: 0.3657304049, alpha: 0.8525791952)
    }
    

    // MARK: - Private Functions
    private func configureViewControllers() {
        let searchVC = UINavigationController(rootViewController: SearchRecipesOnlineVC())
        let cookVC = UINavigationController(rootViewController: CookVC())
        let timerVC = TimerVC()
        let myStuffVC = UINavigationController(rootViewController: MyStuffVC())
        
        searchVC.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 0)
        cookVC.tabBarItem = UITabBarItem(title: "Cook", image: UIImage(systemName: "dial.min.fill"), tag: 1)
        timerVC.tabBarItem = UITabBarItem(title: "Timer", image: UIImage(systemName: "timer"), tag: 2)
        myStuffVC.tabBarItem = UITabBarItem(title: "Pantry", image: UIImage(systemName: "tray.2.fill"), tag: 3)
                        
        viewControllers = [searchVC, cookVC, timerVC, myStuffVC]
    }

}
