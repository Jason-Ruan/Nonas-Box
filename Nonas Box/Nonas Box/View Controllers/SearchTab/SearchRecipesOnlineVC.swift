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
    
    private lazy var appNameLabel: UILabel = {
        return UILabel(text: "Nona's\nBox", fontName: "Chalkduster", fontSize: 60, alignment: .center)
    }()
    
    private lazy var screenTitleLabel: UILabel = {
        return UILabel(text: "Discover new recipes!", fontName: "ChalkboardSE-Bold", fontSize: 25)
    }()
    
    private lazy var searchBar: UISearchBar = {
        let sb = UISearchBar(placeHolderText: "Search for recipes here")
        sb.delegate = self
        return sb
    }()
    
    private lazy var resultsNumberLabel: UILabel = {
        return UILabel(fontName: "Tamil Sangam MN", fontSize: 12)
    }()
    
    private lazy var recipeCollectionView: UICollectionView = {
        let cv = UICollectionView(scrollDirection: .horizontal, scrollIndicatorsIsVisible: false)
        cv.register(RecipeCollectionViewCell.self, forCellWithReuseIdentifier: RecipeCollectionViewCell.identifier)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    
    //MARK: - Private Properties
    private var searchedQueryResults: [String : [Recipe] ] = [:]
    private var recipes: [Recipe] = [] {
        didSet {
            recipeCollectionView.reloadData()
        }
    }
    
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.isHidden = true
        setUpViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        recipeCollectionView.reloadData()
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
        view.addSubview(screenTitleLabel)
        screenTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            screenTitleLabelDefaultConstraints
        )
        
        view.addSubview(appNameLabel)
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            appNameLabel.bottomAnchor.constraint(equalTo: screenTitleLabel.topAnchor, constant: -60),
            appNameLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
        ])
        
        view.addSubview(gridLayoutButton)
        gridLayoutButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gridLayoutButton.topAnchor.constraint(equalTo: screenTitleLabel.topAnchor),
            gridLayoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            gridLayoutButton.bottomAnchor.constraint(equalTo: screenTitleLabel.bottomAnchor)
        ])
        
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBarCenterXContraint,
            searchBarWidthConstraint,
            searchBarTopConstraint
        ])
        
        view.addSubview(resultsNumberLabel)
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
    
    private func showNoResultsAlert() {
        let alert = UIAlertController(title: "Oops", message: "Sorry, that search had no results in our database.", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        let waitTime = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: waitTime, execute: {
            alert.dismiss(animated: true, completion: nil)
        })
    }
    
    
    //MARK: - Private Constraints
    
    private lazy var screenTitleLabelTopConstraint: NSLayoutConstraint = {
        self.screenTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -30)
    }()
    
    private lazy var screenTitleLabelCenterXConstraint: NSLayoutConstraint = {
        self.screenTitleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
    }()
    
    private lazy var searchBarCenterXContraint: NSLayoutConstraint = {
        self.searchBar.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
    }()
    
    private lazy var searchBarWidthConstraint: NSLayoutConstraint = {
        self.searchBar.widthAnchor.constraint(equalToConstant: view.frame.width / 1.5)
    }()
    
    private lazy var searchBarTopConstraint: NSLayoutConstraint = {
        self.searchBar.topAnchor.constraint(equalTo: screenTitleLabel.bottomAnchor, constant: 20)
    }()

}

//MARK: - SearchBar Methods

extension SearchRecipesOnlineVC: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        searchBar.placeholder = nil
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.placeholder = "Search for recipes here"
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        guard let query = searchBar.text else { return }
        
        showLoadingScreen()
        
        // Check if the query has been searched before and show relevant results/alert
        if let searchedResults = searchedQueryResults[query] {
            removeLoadingScreen()
            
            if !searchedResults.isEmpty {
                recipes = searchedResults
                resultsNumberLabel.text = "Here are some recipes we found for '\(query)'"
            } else {
                showNoResultsAlert()
            }
            
            // Make an API call if query has not been searched before during current session
        } else {
            SpoonacularAPIClient.manager.getRecipes(query: query) { [weak self] (result) in
                
                self?.removeLoadingScreen()
                
                switch result {
                    case .success(let spoonacularResults):
                        guard let recipes = spoonacularResults.results, !recipes.isEmpty else {
                            // Actions when API call is successful but found no results for query
                            self?.showNoResultsAlert()
                            self?.searchedQueryResults[query] = []
                            return
                        }
                        
                        // Actions when API call is successful and query has results
                        self?.recipes = recipes
                        self?.searchedQueryResults[query] = recipes
                        
                        self?.resultsNumberLabel.text = "Here are some recipes we found for '\(query)'"
                        self?.animateRecipesRetrieved()
                        self?.appNameLabel.removeFromSuperview()
                        self?.gridLayoutButton.isHidden = false
                        
                    case .failure(let error):
                        print(error)
                }
            }
        }
        
        if recipes.count > 0 {
            recipeCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: false)
        }
        searchBar.resignFirstResponder()
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recipeCell", for: indexPath) as? RecipeCollectionViewCell else { return UICollectionViewCell()}
        cell.recipe = recipes[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.navigationController?.pushViewController(RecipeDetailVC(recipeID: recipes[indexPath.row].id), animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width / 2 - 20, height: collectionView.frame.height / 2 - 20)
    }
    
}


//MARK: - Animation & Visual Methods

extension SearchRecipesOnlineVC {
    
    private func showLoadingAnimation() {
        view.addSubview(loadingScreenOverlay)
        view.addSubview(spinner)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            spinner.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
        
        spinner.startAnimating()
        
    }
    
    private func removeLoadingAnimation() {
        self.loadingScreenOverlay.removeFromSuperview()
        self.spinner.removeFromSuperview()
    }
    
    // This func is to animate the title and searchbar constraints to move from the initial center to the top to make room for recipeCollectionView to show results of query
    private func animateRecipesRetrieved() {
        self.screenTitleLabel.textAlignment = .left
        
        self.screenTitleLabelTopConstraint.isActive = false
        self.screenTitleLabelCenterXConstraint.isActive = false
        self.searchBarCenterXContraint.isActive = false
        
        self.searchBarTopConstraint.constant = self.searchBarTopConstraint.constant / 5
        self.searchBarWidthConstraint.constant = self.view.frame.width - 40
        
        NSLayoutConstraint.activate([
            self.screenTitleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            self.screenTitleLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            self.searchBar.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            self.resultsNumberLabel.leadingAnchor.constraint(equalTo: screenTitleLabel.leadingAnchor)
        ])
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func toggleCollectionViewLayout() {
        guard let cvFlowLayout = self.recipeCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        switch cvFlowLayout.scrollDirection {
            case .vertical:
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                    cvFlowLayout.scrollDirection = .horizontal
                }, completion: nil)
                
                self.gridLayoutButton.setImage(UIImage(systemName: "square.grid.2x2")!, for: .normal)
            case .horizontal:
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                    cvFlowLayout.scrollDirection = .vertical
                }, completion: nil)
                
                self.gridLayoutButton.setImage(UIImage(systemName: "square.grid.3x2")!, for: .normal)
            default:
                return
        }
    }
}
