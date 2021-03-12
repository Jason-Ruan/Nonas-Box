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
    
    private lazy var promptView: PromptView = {
        return PromptView(colorTheme: .black,
                          image: UIImage(systemName: "list.bullet")!,
                          title: "Nothing to see here!",
                          message: "Looks like your shopping list is empty!\n\nYou can add ingredients to your list from a recipe")
    }()
    
    public var recipeDetails: [RecipeDetails] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavController()
        setUpViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        promptView.isHidden = !recipeDetails.isEmpty
        shoppingListTableView.isScrollEnabled = promptView.isHidden
    }
    
    private func setUpViews() {
        view.addSubview(shoppingListTableView)
        view.addSubview(promptView)
        promptView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            promptView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75),
            promptView.heightAnchor.constraint(equalTo: promptView.widthAnchor),
            promptView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            promptView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func configureNavController() {
        navigationController?.overrideUserInterfaceStyle = .light
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.standardAppearance.largeTitleTextAttributes = [.font : UIFont(name: Fonts.handwriting.rawValue, size: 34)!]
        
        navigationItem.title = "Shopping List"
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
