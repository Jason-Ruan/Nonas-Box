//
//  TabBarController.swift
//  Nonas Box
//
//  Created by Jason Ruan on 11/25/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    // MARK: - Private Properties
    private let tabBarTintColor: UIColor = .black
    private let tabBarUnselectedItemTintColor: UIColor = #colorLiteral(red: 0.4587794542, green: 0.463016808, blue: 0.4736304283, alpha: 0.8525791952)
    
    private lazy var barIndicatorLineView: UIView = {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
        v.backgroundColor = TabBarItemType.init(rawValue: tabBar.items?.first?.title?.lowercased() ?? "")?.colorScheme
        return v
    }()
    
    
    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBarItemsVCs(embedWithNavigationController: [.search, .cook, .shopping, .pantry])
        configureTabBarAttributes()
        setTabBarTitleFont(font: .wideMarker, size: 10.5)
        createLineView()
    }
    
    
    // MARK: - Private Functions
    private func createTabBarItemVC(tabBarItemType: TabBarItemType) -> UIViewController {
        let vc = tabBarItemType.viewController
        vc.tabBarItem = UITabBarItem(title: tabBarItemType.title, image: tabBarItemType.image, tag: tabBarItemType.index)
        return vc
    }
    
    private func configureTabBarAttributes() {
        tabBar.itemWidth = tabBar.frame.width / CGFloat(tabBar.items?.count ?? 5)
        tabBar.isTranslucent = false
        tabBar.tintColor = TabBarItemType.allCases.first?.colorScheme
        tabBar.barTintColor = tabBarTintColor
        tabBar.unselectedItemTintColor = tabBarUnselectedItemTintColor
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
    
    private func createLineView() {
        tabBar.addSubview(barIndicatorLineView)
        barIndicatorLineView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            barIndicatorLineView.heightAnchor.constraint(equalTo: tabBar.heightAnchor, multiplier: 0.025),
            barIndicatorLineView.bottomAnchor.constraint(equalTo: tabBar.safeAreaLayoutGuide.bottomAnchor),
            barIndicatorLineView.widthAnchor.constraint(equalTo: tabBar.widthAnchor, multiplier: CGFloat(1) / CGFloat(tabBar.items?.count ?? 1))
        ])
    }
    
    private func animateLineView(forTabBar tabBar: UITabBar, toSelectedItem item: UITabBarItem, color: UIColor) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: { [weak self] in
            let translationX: CGFloat = CGFloat(tabBar.items?.firstIndex(of: item) ?? 0) * tabBar.itemWidth
            self?.barIndicatorLineView.backgroundColor = color
            self?.barIndicatorLineView.transform = CGAffineTransform(translationX: translationX, y: 0)
        }, completion: nil)
    }
    
    
    // MARK: - Tab Bar Functions
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let color = TabBarItemType.allCases[item.tag].colorScheme
        tabBar.tintColor = color
        animateLineView(forTabBar: tabBar, toSelectedItem: item, color: color)
    }
    
    
    
}

public enum TabBarItemType: String, CaseIterable {
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
        case .timer:            return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        case .shopping:         return #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        case .pantry:           return #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        }
    }
    
    var viewController: UIViewController {
        switch self {
        case .search:           return SearchRecipesOnlineVC()
        case .cook:             return CookVC()
        case .timer:            return TimerVC()
        case .shopping:         return ShoppingVC()
        case .pantry:           return MyStuffVC()
        }
    }
}
