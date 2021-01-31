//
//  CookVC.swift
//  Nonas Box
//
//  Created by Jason Ruan on 8/31/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

class CookVC: UIViewController {
    
    //MARK: - UI Objects
    private lazy var recipesCollectionView: UICollectionView = {
        let cv = UICollectionView(scrollDirection: .vertical, scrollIndicatorsIsVisible: true)
        cv.dataSource = self
        cv.delegate = self
        cv.register(CookingCollectionViewCell.self, forCellWithReuseIdentifier: CookingCollectionViewCell.identifier)
        return cv
    }()
    
    private var searchController: UISearchController!
    
    
    //MARK: - Properties
    var recipes: [RecipeDetails] = [] {
        didSet {
            recipesCollectionView.reloadData()
        }
    }
    
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        configureBackgroundColor()
        configureSearchController()
        configureNavigationBarForTranslucence()
        addSubviews()
        recipes = fetchBookmarkedRecipes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
        recipes = fetchBookmarkedRecipes()
    }
    
    
    //MARK: - Private Methods
    private func configureBackgroundColor() {
        let gradientBackgroundLayer = CAGradientLayer()
        gradientBackgroundLayer.colors = [#colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1).cgColor, UIColor.white.cgColor]
        gradientBackgroundLayer.frame = view.bounds
        view.layer.insertSublayer(gradientBackgroundLayer, at: 0)
    }
    
    private func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.automaticallyShowsScopeBar = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.scopeButtonTitles = ["All", "Bookmarked", "My Recipes"]
        searchController.searchBar.delegate = self
        
        editSearchbarAttributedPlaceholder(withText: "Looking for a specific recipe?", andColor: .white)
        
        navigationItem.title = "Nona's Box"
        navigationItem.searchController = searchController
    }
    
    private func addSubviews() {
        view.addSubview(recipesCollectionView)
        recipesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recipesCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            recipesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            recipesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            recipesCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func fetchBookmarkedRecipes() -> [RecipeDetails] {
        do {
            return try Spoonacular_PersistenceHelper.manager.getSavedRecipes()
        } catch {
            print(error)
            return []
        }
    }
    
    private func editSearchbarAttributedPlaceholder(withText text: String, andColor color: UIColor) {
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: text, attributes: [.foregroundColor : color])
    }
    
    
}


// MARK: - CollectionView Methods
extension CookVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CookingCollectionViewCell.identifier, for: indexPath) as? CookingCollectionViewCell else {
            fatalError("Could not make CookingCollectionViewCell")
        }
        cell.recipe = recipes[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let recipeDetailVC = RecipeDetailVC(recipeDetails: recipes[indexPath.row])
        navigationController?.pushViewController(recipeDetailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width * 0.9, height: view.frame.height / 5)
    }
    
}


// MARK: - UISearchResults Methods
extension CookVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        print("Updating search results")
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        editSearchbarAttributedPlaceholder(withText: "Looking for a specific recipe?", andColor: .systemGray2)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        editSearchbarAttributedPlaceholder(withText: "Looking for a specific recipe?", andColor: .white)
    }
}


// MARK: - UISearchBar Methods
extension CookVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        recipes = fetchBookmarkedRecipes().filter {
            guard let recipeTitle = $0.title?.lowercased(), let query = searchBar.text?.lowercased() else { return false }
            return recipeTitle.contains(query)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText.count > 0 else {
            recipes = fetchBookmarkedRecipes()
            return
        }
        recipes = fetchBookmarkedRecipes().filter {
            guard let recipeTitle = $0.title?.lowercased() else { return false }
            return recipeTitle.contains(searchText.lowercased())
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        recipes = fetchBookmarkedRecipes()
    }
    
}
