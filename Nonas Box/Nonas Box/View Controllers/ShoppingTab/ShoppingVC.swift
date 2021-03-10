//
//  ShoppingVC.swift
//  Nonas Box
//
//  Created by Jason Ruan on 3/7/21.
//  Copyright © 2021 Jason Ruan. All rights reserved.
//

import UIKit

class ShoppingVC: UIViewController {
    
    private lazy var shoppingListTableView: UITableView = {
        let tv = UITableView(frame: view.safeAreaLayoutGuide.layoutFrame, style: .plain)
        tv.backgroundColor = TabBarItemType.shopping.colorScheme
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "shoppingCell")
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()
    
    public var recipeDetails: [RecipeDetails] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.overrideUserInterfaceStyle = .light
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.standardAppearance.largeTitleTextAttributes = [.font : UIFont(name: Fonts.handwriting.rawValue, size: 34)!]
        
        navigationItem.title = TabBarItemType.shopping.title.capitalized
        view.addSubview(shoppingListTableView)
    }
    

}

extension ShoppingVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shoppingCell", for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(RecipeDetailVC(recipeDetails: recipeDetails[indexPath.row]), animated: true)
    }
    
}
