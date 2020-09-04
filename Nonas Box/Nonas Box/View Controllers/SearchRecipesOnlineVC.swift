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
    
    lazy var screenTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Discover new recipes!"
        label.font = UIFont(name: "ChalkboardSE-Bold", size: 25)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.delegate = self
        sb.placeholder = "Search for recipes here"
        sb.searchBarStyle = .minimal
        return sb
    }()
    
    lazy var resultsNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Tamil Sangam MN", size: 12)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var recipeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.register(RecipeCollectionViewCell.self, forCellWithReuseIdentifier: "recipeCell")
        cv.dataSource = self
        cv.delegate = self
        cv.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        spinner.color = .lightGray
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    lazy var loadingScreenOverlay: UIView = {
        let uv = UIView(frame: view.safeAreaLayoutGuide.layoutFrame)
        uv.translatesAutoresizingMaskIntoConstraints = false
        uv.backgroundColor = #colorLiteral(red: 0.2056548595, green: 0.2066133618, blue: 0.2089324594, alpha: 0.7473512414)
        return uv
    }()
    
    lazy var gridLayoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.grid.2x2")!, for: .normal)
        button.addTarget(self, action: #selector(self.toggleCollectionViewLayout), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    
    //MARK: - Private Properties
    
    private var recipes: [Recipe] = [] {
        didSet {
            recipeCollectionView.reloadData()
            resultsNumberLabel.text = "We found \(self.recipes.count) recipes for '\(searchBar.text ?? "your search")'"
        }
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
    
    //MARK: - LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: - Private Functions
    
    private func setUpViews() {
        view.addSubview(screenTitleLabel)
        screenTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            screenTitleLabelTopConstraint,
            screenTitleLabelCenterXConstraint
        ])
        
        view.addSubview(gridLayoutButton)
        gridLayoutButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gridLayoutButton.topAnchor.constraint(equalTo: screenTitleLabel.topAnchor),
            gridLayoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            gridLayoutButton.heightAnchor.constraint(equalToConstant: 30),
            gridLayoutButton.widthAnchor.constraint(equalToConstant: 30)
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
        
        showLoadingAnimation()
        
        SpoonacularAPIClient.manager.getRecipes(query: query) { (result) in
            DispatchQueue.main.async {
                
                self.removeLoadingAnimation()
                
                switch result {
                    case .success(let recipes):
                        guard !recipes.isEmpty else {
                            self.showNoResultsAlert()
                            return
                        }
                        self.recipes = recipes
                        self.animateRecipesRetrieved()
                        self.gridLayoutButton.isHidden = false
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
        self.navigationController?.pushViewController(RecipeDetailVC(recipe: recipes[indexPath.row]), animated: true)
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
                cvFlowLayout.scrollDirection = .horizontal
                self.gridLayoutButton.setImage(UIImage(systemName: "square.grid.2x2")!, for: .normal)
            case .horizontal:
                cvFlowLayout.scrollDirection = .vertical
                self.gridLayoutButton.setImage(UIImage(systemName: "square.grid.3x2")!, for: .normal)
            default:
                return
        }
    }
}
