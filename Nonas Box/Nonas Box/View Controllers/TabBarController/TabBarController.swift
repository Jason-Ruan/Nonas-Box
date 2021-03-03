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
        tabBar.unselectedItemTintColor = #colorLiteral(red: 0.4587794542, green: 0.463016808, blue: 0.4736304283, alpha: 0.8525791952)
        
        guard let customFont = UIFont(name: Fonts.wideMarker.rawValue, size: 10.5) else { return }
        UITabBarItem.appearance().setTitleTextAttributes([.font : customFont], for: .normal)
    }
    

    // MARK: - Private Functions
    private func configureViewControllers() {
        let searchVC = UINavigationController(rootViewController: SearchRecipesOnlineVC())
        let cookVC = UINavigationController(rootViewController: CookVC())
        let timerVC = TimerVC()
        let myStuffVC = UINavigationController(rootViewController: MyStuffVC())
        let shoppingVC = UINavigationController(rootViewController: UIViewController())
        
        searchVC.tabBarItem = UITabBarItem(title: TabBarTitles.search.title, image: UIImage(systemName: .magnifyingglass), tag: 0)
        cookVC.tabBarItem = UITabBarItem(title: TabBarTitles.cook.title, image: UIImage(systemName: .dial), tag: 1)
        timerVC.tabBarItem = UITabBarItem(title: TabBarTitles.timer.title, image: UIImage(systemName: .timer), tag: 2)
        shoppingVC.tabBarItem = UITabBarItem(title: TabBarTitles.shopping.title, image: UIImage(systemName: .bag), tag: 3)
        myStuffVC.tabBarItem = UITabBarItem(title: TabBarTitles.pantry.title, image: UIImage(systemName: .trays), tag: 4)
                        
        viewControllers = [searchVC, cookVC, timerVC, shoppingVC, myStuffVC]
    }

}

fileprivate enum TabBarTitles: String {
    case search, cook, timer, shopping, pantry
    
    var title: String {
        rawValue.uppercased()
    }
}
