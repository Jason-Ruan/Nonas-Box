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
        let cv = UICollectionView(scrollDirection: .vertical,
                                  spacing: 0,
                                  scrollIndicatorsIsVisible: true,
                                  shouldInset: false)
        cv.dataSource = self
        cv.delegate = self
        cv.register(CookingCollectionViewCell.self, forCellWithReuseIdentifier: CookingCollectionViewCell.identifier)
        return cv
    }()
    
    private lazy var buttonToScrollToTop: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(systemName: .chevronUpFill), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(scrollToTop), for: .touchUpInside)
        button.isHidden = true
        return button
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
        view.backgroundColor = #colorLiteral(red: 0.9539069533, green: 0.6485298276, blue: 0.5980203748, alpha: 1)
        configureSearchController()
        configureNavigationBarForTranslucence()
        addSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        recipes = fetchBookmarkedRecipes(withTitleContaining: searchController.searchBar.text,
                                         filteredBy: (1...2).contains(searchController.searchBar.selectedScopeButtonIndex) ?
                                            RecipeFilterCriteria.init(rawValue: searchController.searchBar.selectedScopeButtonIndex) : nil)
        
    }
    
    
    //MARK: - Private Methods
    private func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.automaticallyShowsScopeBar = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.scopeButtonTitles = ["All", "Quick (<1hr)", "Steady (1hr+)"]
        searchController.searchBar.delegate = self
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Looking for a specific recipe?", attributes: [.foregroundColor : UIColor.white])
        
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
        
        view.addSubview(buttonToScrollToTop)
        buttonToScrollToTop.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonToScrollToTop.bottomAnchor.constraint(equalTo: recipesCollectionView.bottomAnchor, constant: -15),
            buttonToScrollToTop.trailingAnchor.constraint(equalTo: recipesCollectionView.trailingAnchor, constant: -15),
            buttonToScrollToTop.heightAnchor.constraint(equalTo: recipesCollectionView.heightAnchor, multiplier: 0.1),
            buttonToScrollToTop.widthAnchor.constraint(equalTo: buttonToScrollToTop.heightAnchor)
        ])
    }
    
    private func fetchBookmarkedRecipes(withTitleContaining term: String? = nil, filteredBy criteria: RecipeFilterCriteria? = nil) -> [RecipeDetails] {
        var recipes: [RecipeDetails] = []
        
        do {
            recipes = try Spoonacular_PersistenceHelper.manager.getSavedRecipes()
        } catch {
            print(error)
        }
        
        if let term = term?.lowercased(), term.count > 0 {
            recipes = recipes.filter {
                guard let title = $0.title?.lowercased(), let min = $0.readyInMinutes else { return false }
                switch criteria {
                    case .underAnHour:              return title.contains(term) && min < 60
                    case .hourOrMore:               return title.contains(term) && min >= 60
                    default:                        return title.contains(term)
                }
            }
        }
        
        return recipes
    }
    
    
    // MARK: - Private ObjC Functions
    @objc private func scrollToTop() {
        recipesCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
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
        return CGSize(width: view.frame.width, height: view.frame.height / 4)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        buttonToScrollToTop.isHidden = scrollView.contentOffset.y > 0 ? false : true
    }
    
}


// MARK: - UISearchBar Methods
extension CookVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        recipes = fetchBookmarkedRecipes(withTitleContaining: searchBar.text,
                                         filteredBy: (1...2).contains(searchBar.selectedScopeButtonIndex) ?
                                                        RecipeFilterCriteria.init(rawValue: searchBar.selectedScopeButtonIndex) : nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        recipes = fetchBookmarkedRecipes(withTitleContaining: searchText,
                                         filteredBy: (1...2).contains(searchBar.selectedScopeButtonIndex) ?
                                                        RecipeFilterCriteria.init(rawValue: searchBar.selectedScopeButtonIndex) : nil)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        recipes = fetchBookmarkedRecipes()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        switch selectedScope {
            case 0:                 recipes = fetchBookmarkedRecipes(withTitleContaining: searchBar.text)
            case 1:                 recipes = fetchBookmarkedRecipes(withTitleContaining: searchBar.text, filteredBy: .underAnHour)
            case 2:                 recipes = fetchBookmarkedRecipes(withTitleContaining: searchBar.text, filteredBy: .hourOrMore)
            default:                return
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.selectedScopeButtonIndex = 0
        recipes = fetchBookmarkedRecipes(withTitleContaining: searchBar.text)
        return true
    }
    
}

fileprivate enum RecipeFilterCriteria: Int {
    case underAnHour = 1
    case hourOrMore = 2
}
