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
        let tableView = UITableView(frame: view.safeAreaLayoutGuide.layoutFrame, style: .plain)
        tableView.register(ShoppingListTableViewCell.self, forCellReuseIdentifier: ShoppingListTableViewCell.reuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.backgroundView = PromptView(colorTheme: .black,
                                              image: UIImage(systemName: .bulletList)!,
                                              title: "Nothing to see here!",
                                              message: "Looks like your shopping list is empty!\n\nYou can add ingredients to your list from a recipe.")
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    // MARK: - Public Properties
    var shoppingList: [ShoppingItem] = [] {
        didSet {
            shoppingListTableView.backgroundView?.isHidden = !shoppingList.isEmpty
            shoppingListTableView.isScrollEnabled = !shoppingList.isEmpty
            if shoppingList.isEmpty {
                crossedOutList.removeAll()
            }
        }
    }
    
    var crossedOutList: Set<ShoppingItem> = []
    
    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavController()
        configureNavigationBarForTranslucence()
        setUpViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadShoppingItems()
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
        navigationController?.navigationBar.standardAppearance.largeTitleTextAttributes = [.font: UIFont(name: Fonts.optima.rawValue, size: 34)!,
                                                                                           .foregroundColor: UIColor.black,
                                                                                           .strokeColor: UIColor.white,
                                                                                           .strokeWidth: -0.5]
        navigationItem.title = "Shopping List"
        
        let trashBarButton = UIBarButtonItem(image: UIImage(systemName: .trashFill), style: .plain, target: self, action: #selector(clearShoppingList))
        let addBarButton = UIBarButtonItem(image: UIImage(systemName: .barcodeScanner), style: .plain, target: self, action: #selector(addBarButtonPressed))
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
            shoppingListTableView.backgroundView?.isHidden = !shoppingList.isEmpty
            shoppingListTableView.reloadData()
        } catch {
            print(error)
        }
    }
    
    @objc private func addBarButtonPressed() {
        present(BarcodeScanVC(), animated: true, completion: nil)
    }
    
}

// MARK: - TableView Methods
extension ShoppingVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shoppingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ShoppingListTableViewCell.reuseIdentifier, for: indexPath) as? ShoppingListTableViewCell else { return UITableViewCell() }
        let shoppingItem = shoppingList[indexPath.row]
        cell.shoppingItem = shoppingItem
        cell.toggleCrossedLineStatus(isCrossedOut: crossedOutList.contains(shoppingItem))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ShoppingListTableViewCell else { return }
        let shoppingItem = shoppingList[indexPath.row]
        if crossedOutList.contains(shoppingItem) {
            crossedOutList.remove(shoppingItem)
            tableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 0))
            shoppingList.remove(at: indexPath.row)
            shoppingList.insert(shoppingItem, at: 0)
        } else {
            crossedOutList.insert(shoppingItem)
            tableView.moveRow(at: indexPath, to: IndexPath(row: (tableView.numberOfRows(inSection: 0) - 1), section: 0))
            shoppingList.remove(at: indexPath.row)
            shoppingList.append(shoppingItem)
        }
        cell.toggleCrossedLineStatus(isCrossedOut: crossedOutList.contains(shoppingItem))
        tableView.reloadRows(at: [tableView.indexPathsForVisibleRows!.last!], with: .none)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Remove") { (_, _, _) in
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
