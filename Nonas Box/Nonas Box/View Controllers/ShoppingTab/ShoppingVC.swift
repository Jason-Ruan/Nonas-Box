//
//  ShoppingVC.swift
//  Nonas Box
//
//  Created by Jason Ruan on 3/7/21.
//  Copyright © 2021 Jason Ruan. All rights reserved.
//

import UIKit

class ShoppingVC: UIViewController {
    // MARK: - Private Properties
    private lazy var shoppingListTableView: UITableView = {
        let tv = UITableView(frame: view.safeAreaLayoutGuide.layoutFrame, style: .plain)
        tv.register(ShoppingListTableViewCell.self, forCellReuseIdentifier: ShoppingListTableViewCell.reuseIdentifier)
        tv.tableFooterView = UIView()
        tv.backgroundView = PromptView(colorTheme: .black,
                                       image: UIImage(systemName: "list.bullet.rectangle")!,
                                       title: "Nothing to see here!",
                                       message: "Looks like your shopping list is empty!\n\nYou can add ingredients to your list from a recipe.")
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()
    
    // MARK: - Public Properties
    var shoppingList: [ShoppingItem] = [] {
        didSet {
            promptView.isHidden = !shoppingList.isEmpty
        }
    }
    
    
    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavController()
        setUpViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadShoppingItems()
        promptView.isHidden = !shoppingList.isEmpty
        shoppingListTableView.isScrollEnabled = promptView.isHidden
        shoppingListTableView.reloadData()
    }
    
    
    // MARK: - Private Functions
    private func setUpViews() {
        view.addSubview(shoppingListTableView)
        shoppingListTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shoppingListTableView.topAnchor.constraint(equalTo: view.topAnchor),
            shoppingListTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            shoppingListTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            shoppingListTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func configureNavController() {
        navigationController?.overrideUserInterfaceStyle = .light
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.standardAppearance.largeTitleTextAttributes = [.font : UIFont(name: Fonts.optima.rawValue, size: 34)!,
                                                                                           .foregroundColor : UIColor.black,
                                                                                           .strokeColor : UIColor.white,
                                                                                           .strokeWidth : -0.5]
        
        navigationItem.title = "Shopping List"
        
        let trashBarButton = UIBarButtonItem(image: UIImage(systemName: .trashFill), style: .plain, target: self, action: #selector(clearShoppingList))
        let addBarButton = UIBarButtonItem(image: UIImage(systemName: .plusCircleFill), style: .plain, target: self, action: nil)

        trashBarButton.tintColor = .systemGray
        addBarButton.tintColor = .systemBlue
        
        navigationItem.rightBarButtonItems = [addBarButton, trashBarButton]
        
    }
    
    private func loadShoppingItems() {
        do {
            shoppingList = try ShoppingItemPersistenceHelper.manager.getSavedItems()
        } catch {
            print(error)
        }
    }
    
    
    // MARK: - ObjC Functions
    @objc private func clearShoppingList() {
        do {
            try ShoppingItemPersistenceHelper.manager.deleteAll()
            shoppingList.removeAll()
            promptView.isHidden = false
            shoppingListTableView.isScrollEnabled = false
            shoppingListTableView.reloadData()
        } catch {
            print(error)
        }
    }
    
    
}

// MARK: - TableView Methods
extension ShoppingVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shoppingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ShoppingListTableViewCell.reuseIdentifier, for: indexPath) as? ShoppingListTableViewCell else { return UITableViewCell() }
        cell.shoppingItem = shoppingList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Remove") { (action, view, completionHandler) in
            do {
                try ShoppingItemPersistenceHelper.manager.delete(key: self.shoppingList[indexPath.row].itemName)
                self.shoppingList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                return
            }
        }
        
        delete.image = UIImage(systemName: .trashFill)
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
}
