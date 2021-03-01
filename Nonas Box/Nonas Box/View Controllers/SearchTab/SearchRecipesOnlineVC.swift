//
//  SearchRecipesOnlineVC.swift
//  Nonas Box
//
//  Created by Jason Ruan on 6/30/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

class SearchRecipesOnlineVC: UIViewController {
    //MARK: - UI Objects
    private lazy var backgroundImageView: UIImageView = {
        let iv = UIImageView(frame: view.frame)
        iv.image = UIImage(named: ImageNames.foodBorderEmptyCenter.rawValue)
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private lazy var appNameLabel: UILabel = {
        let label = UILabel(text: "Nona's\nBox", fontName: .chalkduster, fontSize: 60, alignment: .center)
        label.layer.masksToBounds = true
        label.backgroundColor = #colorLiteral(red: 1, green: 0.687940836, blue: 0.5207877159, alpha: 0.8489672517)
        return label
    }()
    
    private lazy var screenTitleLabel: UILabel = {
        return UILabel(text: "Discover new recipes!", fontName: .chalkboard, fontSize: 25, fontWeight: .bold)
    }()
    
    private lazy var searchBar: UISearchBar = {
        let sb = UISearchBar(placeHolderText: "Search for recipes here")
        sb.delegate = self
        sb.searchTextField.backgroundColor = .white
        (sb.searchTextField.leftView as? UIImageView)?.tintColor = .systemOrange
        sb.searchTextField.textColor = .darkText
        sb.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search for recipes here", attributes: [.foregroundColor : UIColor.systemGray])
        return sb
    }()
    
    private lazy var resultsNumberLabel: UILabel = {
        return UILabel(fontName: .tamil, fontSize: 12)
    }()
    
    private lazy var recipeCollectionView: UICollectionView = {
        let cv = UICollectionView(scrollDirection: .horizontal,
                                  spacing: 5,
                                  scrollIndicatorsIsVisible: false,
                                  shouldInset: true)
        cv.register(RecipeCollectionViewCell.self, forCellWithReuseIdentifier: RecipeCollectionViewCell.identifier)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    
    //MARK: - Private Properties
    private var lastSearchedQuery: String?
    private var searchedQueryResults: [String : [Recipe] ] = [:]
    private var recipes: [Recipe] = [] {
        willSet {
            guard recipes.isEmpty else { return }
            backgroundImageView.image = UIImage(named: ImageNames.plainWoodTable.rawValue)
            backgroundImageView.addGradientLayer(colors: [#colorLiteral(red: 1, green: 0.6408555508, blue: 0.365842253, alpha: 0.9022502369), .clear, .clear])
        }
        
        didSet {
            recipeCollectionView.reloadData()
        }
    }
    
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.isHidden = true
        configureTapGesture()
        setUpViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        // Reload to update cells, in case recipe(s) favorite status is changed
        recipeCollectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        appNameLabel.layer.cornerRadius = appNameLabel.frame.height / 2
    }
    
    
    //MARK: - Private Functions
    private func showNoResultsAlert() {
        let alert = UIAlertController(title: "Oops", message: "Sorry, that search had no results in our database.", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        let waitTime = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: waitTime, execute: {
            alert.dismiss(animated: true, completion: nil)
        })
    }
    
    private func configureTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - ObjC Functions
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    //MARK: - Private Constraints
    
    private lazy var screenTitleLabelDefaultConstraints: [NSLayoutConstraint] = {
        [self.screenTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -30),
         self.screenTitleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ]
    }()
    
    private lazy var searchBarDefaultContraints: [NSLayoutConstraint] = {
        [self.searchBar.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
         self.searchBar.widthAnchor.constraint(equalToConstant: view.frame.width / 1.5),
         self.searchBar.topAnchor.constraint(equalTo: screenTitleLabel.bottomAnchor, constant: 20)]
    }()
    
    private lazy var constraintsWhenRecipesFound: [NSLayoutConstraint] = {
        [self.screenTitleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
         self.screenTitleLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
         self.searchBar.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
         self.searchBar.topAnchor.constraint(equalTo: screenTitleLabel.bottomAnchor, constant: 5),
         self.searchBar.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
         self.resultsNumberLabel.leadingAnchor.constraint(equalTo: screenTitleLabel.leadingAnchor)]
    }()
    
    private func setUpViews() {
        view.addSubview(backgroundImageView)

        view.addSubview(screenTitleLabel)
        screenTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            screenTitleLabelDefaultConstraints
        )
        
        let appNameLayoutGuide = UILayoutGuide()
        view.addLayoutGuide(appNameLayoutGuide)
        NSLayoutConstraint.activate([
            appNameLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            appNameLayoutGuide.bottomAnchor.constraint(equalTo: screenTitleLabel.topAnchor)
        ])
        
        view.addSubview(appNameLabel)
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            appNameLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            appNameLabel.centerYAnchor.constraint(equalTo: appNameLayoutGuide.centerYAnchor),
            appNameLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            appNameLabel.heightAnchor.constraint(equalTo: appNameLabel.widthAnchor)
            
        ])
            
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(searchBarDefaultContraints)
        
        view.addSubview(resultsNumberLabel)
        resultsNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            resultsNumberLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 3),
            resultsNumberLabel.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor)
        ])
        
        view.addSubview(recipeCollectionView)
        recipeCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recipeCollectionView.topAnchor.constraint(equalTo: resultsNumberLabel.bottomAnchor),
            recipeCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            recipeCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            recipeCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
    
    
}

//MARK: - SearchBar Methods

extension SearchRecipesOnlineVC: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.enablesReturnKeyAutomatically = false
        searchBar.placeholder = nil
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.placeholder = "Search for recipes here"
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let query = searchBar.text, !query.isEmpty else { return }
        
        showLoadingScreen(blockBackgroundViews: false)
        
        // Check if the query has been searched before and show relevant results/alert
        if let searchedResults = searchedQueryResults[query] {
            removeLoadingScreen()
            
            if !searchedResults.isEmpty {
                recipes = searchedResults
                lastSearchedQuery = query
                resultsNumberLabel.text = "Here are some recipes we found for '\(query)'"
            } else {
                showNoResultsAlert()
            }
            
            // Make an API call if query has not been searched before during current session
        } else {
            SpoonacularAPIClient.manager.getRecipes(query: query) { [weak self] (result) in
                
                self?.removeLoadingScreen()
                
                switch result {
                    case .success(let recipeResults):
                        guard !recipeResults.isEmpty else {
                            // Actions when API call is successful but found no results for query
                            self?.showNoResultsAlert()
                            self?.searchedQueryResults[query] = []
                            return
                        }
                        
                        // Actions when API call is successful and query has results
                        self?.recipes = recipeResults
                        self?.searchedQueryResults[query] = self?.recipes
                        self?.lastSearchedQuery = query
                        
                        self?.resultsNumberLabel.text = "Here are some recipes we found for '\(query)'"
                        self?.animateRecipesRetrieved()
                        self?.appNameLabel.removeFromSuperview()
                        
                    case .failure(let error):
                        print(error)
                        self?.showAlert(message: "Sorry, it seems there was a problem trying to find recipes. Please try again later.")
                }
            }
        }
        
        if recipes.count > 0 {
            recipeCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: false)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
}

//MARK: - CollectionView Methods

extension SearchRecipesOnlineVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecipeCollectionViewCell.identifier, for: indexPath) as? RecipeCollectionViewCell else { return UICollectionViewCell()}
        cell.recipe = recipes[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.navigationController?.pushViewController(RecipeDetailVC(recipeID: recipes[indexPath.row].id), animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width / 2 - 20, height: collectionView.frame.height / 2 - 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard (indexPath.row == recipes.count - 1) && recipes.count % 10 == 0 else { return }
        guard let lastSearchedQuery = lastSearchedQuery else { return }
        showLoadingScreen(blockBackgroundViews: false)
        SpoonacularAPIClient.manager.getRecipes(query: lastSearchedQuery, offset: recipes.count) { [weak self] (result) in
            switch result {
                case .failure(let error):
                    print(error)
                    self?.showAlert(message: "Oops, looks like there was an error when trying to load more recipes for this search.")
                case .success(let recipes):
                    self?.recipes.append(contentsOf: recipes)
                    if self?.searchedQueryResults[lastSearchedQuery] != nil {
                        self?.searchedQueryResults[lastSearchedQuery] = self?.recipes
                    }
            }
            self?.removeLoadingScreen()
        }
    }
    
}


//MARK: - Animation & Visual Methods

extension SearchRecipesOnlineVC {
    // This func is to animate the title and searchbar constraints to move from the initial center to the top to make room for recipeCollectionView to show results of query
    private func animateRecipesRetrieved() {
        screenTitleLabel.textAlignment = .left
        NSLayoutConstraint.deactivate(screenTitleLabelDefaultConstraints + searchBarDefaultContraints)
        NSLayoutConstraint.activate(constraintsWhenRecipesFound)
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
}
