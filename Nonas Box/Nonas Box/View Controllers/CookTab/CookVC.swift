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
    
    
    //MARK: - Properties
    var recipes: [RecipeDetails] = [] {
        didSet {
            recipesCollectionView.reloadData()
        }
    }
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        navigationController?.navigationBar.isHidden = true
        overrideUserInterfaceStyle = .dark
        configureBackgroundColor()
        addSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadBookmarkedRecipes()
    }
    
    
    //MARK: - Private Methods
    private func configureBackgroundColor() {
        let gradientBackgroundLayer = CAGradientLayer()
        gradientBackgroundLayer.colors = [#colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1).cgColor, UIColor.white.cgColor]
        gradientBackgroundLayer.frame = view.bounds
        view.layer.insertSublayer(gradientBackgroundLayer, at: 0)
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
    
    private func loadBookmarkedRecipes() {
        do {
            recipes = try Spoonacular_PersistenceHelper.manager.getSavedRecipes()
        } catch {
            print(error)
        }
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
        present(recipeDetailVC, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width * 0.9, height: view.frame.height / 5)
    }
    
}
