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
    
    lazy var recipeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: view.frame.width / 2.5, height: view.frame.height / 5)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.register(RecipeCollectionViewCell.self, forCellWithReuseIdentifier: "recipeCell")
        cv.dataSource = self
        cv.delegate = self
        cv.contentInset = UIEdgeInsets(top: 50, left: 20, bottom: 50, right: 20)
        return cv
    }()
    
    lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        spinner.color = .lightGray
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    lazy var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        return blurEffectView
    }()
    
    
    //MARK: - Private Properties
    
    private var recipes: [Recipe] = [] {
        didSet {
            recipeCollectionView.reloadData()
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
        view.backgroundColor = .white
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
        
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBarCenterXContraint,
            searchBarWidthConstraint,
            searchBarTopConstraint
        ])
        
        view.addSubview(recipeCollectionView)
        recipeCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recipeCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            recipeCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            recipeCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            recipeCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
    }
    
    private func showLoadingAnimation() {
        view.addSubview(blurEffectView)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: recipeCollectionView.topAnchor),
            blurEffectView.centerXAnchor.constraint(equalTo: recipeCollectionView.centerXAnchor),
            blurEffectView.widthAnchor.constraint(equalToConstant: recipeCollectionView.frame.width),
            blurEffectView.bottomAnchor.constraint(equalTo: recipeCollectionView.bottomAnchor)
        ])
        
        view.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            spinner.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
        
        spinner.startAnimating()
        
    }
    
    private func removeLoadingAnimation() {
        self.spinner.removeFromSuperview()
        self.blurEffectView.removeFromSuperview()
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
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        guard let query = searchBar.text else { return }
        //        showLoadingAnimation()
        
        SpoonacularAPIClient.manager.getRecipes(query: query) { (result) in
            
            //            self.removeLoadingAnimation()
            DispatchQueue.main.async {
                switch result {
                    case .success(let recipes):
                        guard !recipes.isEmpty else {
                            self.showNoResultsAlert()
                            return
                        }
                        self.recipes = recipes
                    case .failure(let error):
                        print(error)
                }
            }
        }
        
        if recipes.count > 0 {
            recipeCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
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
//        let detailVC = DetailVC()
//        detailVC.recipe = recipes[indexPath.row]
//        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
}


