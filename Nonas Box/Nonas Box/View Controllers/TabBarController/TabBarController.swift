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
        configureTabBarItemsVCs(embedWithNavigationController: [.search, .cook, .shopping, .pantry])
        tabBar.isTranslucent = false
        tabBar.tintColor = #colorLiteral(red: 1, green: 0.7459085584, blue: 0.4750729799, alpha: 1)
        tabBar.barTintColor = .black
        tabBar.unselectedItemTintColor = #colorLiteral(red: 0.4587794542, green: 0.463016808, blue: 0.4736304283, alpha: 0.8525791952)
        setTabBarTitleFont(font: .wideMarker, size: 10.5)
    }
    

    // MARK: - Private Functions
    private func createTabBarItemVC(tabBarItemType: TabBarItemType) -> UIViewController {
        let vc = tabBarItemType.viewController
        vc.tabBarItem = UITabBarItem(title: tabBarItemType.title, image: tabBarItemType.image, tag: tabBarItemType.index)
        return vc
    }
    
    private func configureTabBarItemsVCs(embedWithNavigationController rootViewControllers: Set<TabBarItemType>? = nil) {
        if let rootViewControllers = rootViewControllers {
            viewControllers = TabBarItemType.allCases.map {
                if rootViewControllers.contains($0) {
                    return UINavigationController(rootViewController: createTabBarItemVC(tabBarItemType: $0))
                } else {
                    return createTabBarItemVC(tabBarItemType: $0)
                }
            }
        } else {
            viewControllers = TabBarItemType.allCases.map { createTabBarItemVC(tabBarItemType: $0) }
        }
    }
    
    private func setTabBarTitleFont(font: Fonts, size: CGFloat) {
        guard let customFont = UIFont(name: font.rawValue, size: size) else { return }
        UITabBarItem.appearance().setTitleTextAttributes([.font : customFont], for: .normal)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let itemTitle = item.title?.lowercased() else { return }
        tabBar.tintColor = TabBarItemType.init(rawValue: itemTitle)?.colorScheme
    }
    
    

}

fileprivate enum TabBarItemType: String, CaseIterable {
    case search, cook, timer, shopping, pantry
    
    var title: String { rawValue.uppercased() }
    var index: Int { Self.allCases.firstIndex(of: self) ?? 0 }
    
    var image: UIImage? {
        switch self {
            case .search:           return UIImage(systemName: .magnifyingglass)
            case .cook:             return UIImage(systemName: .dial)
            case .timer:            return UIImage(systemName: .timer)
            case .shopping:         return UIImage(systemName: .bag)
            case .pantry:           return UIImage(systemName: .trays)
        }
    }
    
    var colorScheme: UIColor {
        switch self {
            case .search:           return #colorLiteral(red: 1, green: 0.6408555508, blue: 0.365842253, alpha: 0.9022502369)
            case .cook:             return #colorLiteral(red: 0.9539069533, green: 0.6485298276, blue: 0.5980203748, alpha: 1)
            case .timer:            return #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
            case .shopping:         return #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
            case .pantry:           return #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        }
    }
    
    var viewController: UIViewController {
        switch self {
            case .search:           return SearchRecipesOnlineVC()
            case .cook:             return CookVC()
            case .timer:            return TimerVC()
            case .shopping:         return UIViewController()
            case .pantry:           return MyStuffVC()
        }
    }
}
