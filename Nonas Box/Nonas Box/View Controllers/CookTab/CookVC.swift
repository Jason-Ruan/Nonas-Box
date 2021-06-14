//
//  CookVC.swift
//  Nonas Box
//
//  Created by Jason Ruan on 8/31/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

class CookVC: UIViewController {
    // MARK: - Private Enums
    private enum RecipeFilterCriteria: Int {
        case upToHalfHour = 1
        case overHalfHour = 2
    }
    
    private enum Layout: Int {
        case cardView
        case gridView
    }

    // MARK: - UI Objects
    private lazy var recipesCollectionView: UICollectionView = {
        let cv = UICollectionView(scrollDirection: .vertical,
                                  spacing: 0,
                                  scrollIndicatorsIsVisible: true,
                                  shouldInset: false)
        cv.dataSource = self
        cv.delegate = self
        cv.register(CookingCollectionViewCell.self, forCellWithReuseIdentifier: CookingCollectionViewCell.identifier)
        cv.register(RecipeCollectionViewCell.self, forCellWithReuseIdentifier: RecipeCollectionViewCell.identifier)
        cv.backgroundView = PromptView(colorTheme: .white,
                                       image: UIImage(systemName: .archiveBox)!,
                                       title: "Uh-oh!",
                                       message: "It's looking a little empty here.\n\nYou can get started by searching for recipes or by creating your own!")
        return cv
    }()
    
    private lazy var buttonToScrollToTop: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(systemName: .chevronUpFill), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(scrollToTop), for: .touchUpInside)
        button.isHidden = true
        
        button.layer.shadowColor = UIColor.darkGray.cgColor
        button.layer.shadowOpacity = 1
        button.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        button.layer.shadowRadius = 5
        return button
    }()
    
    private lazy var layoutButton: UIBarButtonItem = {
       return UIBarButtonItem(image: UIImage(systemName: .squareGrid2x2),
                              style: .plain,
                              target: self,
                              action: #selector(layoutBarButtonPressed))
    }()
    
    private var searchController: UISearchController!
    private var layout: Layout = .cardView
    
    // MARK: - Properties
    var recipes: [RecipeDetails] = [] {
        didSet {
            recipesCollectionView.reloadData()
        }
    }
    
    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        view.backgroundColor = #colorLiteral(red: 0.9539069533, green: 0.6485298276, blue: 0.5980203748, alpha: 1)
        configureNavigationItems()
        configureNavigationBarForTranslucence()
        addSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        recipes = fetchBookmarkedRecipes(withTitleContaining: searchController.searchBar.text,
                                         filteredBy: (1...2).contains(searchController.searchBar.selectedScopeButtonIndex) ?
                                            RecipeFilterCriteria.init(rawValue: searchController.searchBar.selectedScopeButtonIndex) : nil)
        recipesCollectionView.backgroundView?.isHidden = !recipes.isEmpty
        recipesCollectionView.layoutIfNeeded()
        searchController.searchBar.isHidden = recipes.isEmpty
        
    }
    
    // MARK: - Private Methods
    private func configureNavigationItems() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.automaticallyShowsScopeBar = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.scopeButtonTitles = ["All", "Quick", "Steady"]
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = .white
        searchController.searchBar.setImage(UIImage(systemName: .xmarkCircleFill)?.withTintColor(.white), for: .clear, state: .normal)
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Looking for a specific recipe?", attributes: [.foregroundColor: UIColor.white])
        
        navigationItem.title = "Nona's Box"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: .compose),
                                                              style: .plain,
                                                              target: self,
                                                              action: #selector(composeButtonPressed)), layoutButton]
        navigationItem.rightBarButtonItems?.forEach { $0.tintColor = .white }
        navigationItem.backButtonTitle = String()
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
            buttonToScrollToTop.heightAnchor.constraint(equalTo: recipesCollectionView.heightAnchor, multiplier: 0.08),
            buttonToScrollToTop.widthAnchor.constraint(equalTo: buttonToScrollToTop.heightAnchor)
        ])
        
    }
    
    private func fetchBookmarkedRecipes(withTitleContaining term: String? = nil, filteredBy criteria: RecipeFilterCriteria? = nil) -> [RecipeDetails] {
        var recipes: [RecipeDetails] = []
        
        do {
            recipes = try Spoonacular_PersistenceHelper.manager.getSavedRecipes(persistenceStorage: .collection)
        } catch {
            print(error)
        }
        
        if let term = term?.lowercased(), term.count > 0 {
            recipes = recipes.filter {
                guard let title = $0.title?.lowercased(), let min = $0.readyInMinutes else { return false }
                switch criteria {
                case .upToHalfHour:                 return title.contains(term) && min <= 30
                case .overHalfHour:                 return title.contains(term) && min > 30
                default:                            return title.contains(term)
                }
            }
        } else {
            recipes = recipes.filter {
                guard let min = $0.readyInMinutes else { return false }
                switch criteria {
                case .upToHalfHour:                 return min <= 30
                case .overHalfHour:                 return min > 30
                default:                            return true
                }
            }
        }
        
        return recipes
    }
    
    private func updateScopeBarTitles(numResults: [Int]) {
        searchController.searchBar.scopeButtonTitles = ["All (\(numResults[0]))", "Quick (\(numResults[1]))", "Steady (\(numResults[2]))"]
    }
    
    // MARK: - Private ObjC Functions
    @objc private func scrollToTop() {
        recipesCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    @objc private func composeButtonPressed() {
        present(UINavigationController(rootViewController: RecipeCreationVC()), animated: true, completion: nil)
    }
    
    @objc private func layoutBarButtonPressed() {
        layout = (layout == .cardView) ? .gridView : .cardView
        layoutButton.image = UIImage(systemName: (layout == .cardView) ? .squareGrid2x2 : .rectangleGrid1x2)
        recipesCollectionView.reloadData()
    }
}

// MARK: - CollectionView Methods
extension CookVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch layout {
        case .cardView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CookingCollectionViewCell.identifier, for: indexPath) as? CookingCollectionViewCell else {
                fatalError("Could not make CookingCollectionViewCell")
            }
            cell.recipe = recipes[indexPath.row]
            return cell
        case .gridView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecipeCollectionViewCell.identifier, for: indexPath) as? RecipeCollectionViewCell else {
                fatalError("Could not make RecipeCollectionViewCell")
            }
            cell.layer.cornerRadius = 0
            cell.layer.borderColor = UIColor.white.cgColor
            cell.recipeDetails = recipes[indexPath.row]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let recipeDetailVC = RecipeDetailVC(from: recipes[indexPath.row])
        navigationController?.pushViewController(recipeDetailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch layout {
        case .cardView:
            return CGSize(width: view.frame.width, height: view.frame.height / 4)
        case .gridView:
            return CGSize(width: view.frame.width / 2, height: collectionView.frame.height / 2.5)
        }
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
        var numResults: [Int] = [0, 0, 0]
        numResults[searchBar.selectedScopeButtonIndex] = recipes.count
        updateScopeBarTitles(numResults: numResults)
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        recipes = fetchBookmarkedRecipes()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        switch selectedScope {
        case 0:                 recipes = fetchBookmarkedRecipes(withTitleContaining: searchBar.text)
        case 1:                 recipes = fetchBookmarkedRecipes(withTitleContaining: searchBar.text, filteredBy: .upToHalfHour)
        case 2:                 recipes = fetchBookmarkedRecipes(withTitleContaining: searchBar.text, filteredBy: .overHalfHour)
        default:                return
        }
    }
    
}
