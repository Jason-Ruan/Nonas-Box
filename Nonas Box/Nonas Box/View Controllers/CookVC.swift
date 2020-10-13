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
    
    
    //MARK: - Properties
    var recipesInProgress: [RecipeDetails] = []
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    //MARK: - Methods
    
}


// MARK: - CollectionView Methods
extension CookVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipesInProgress.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cookingCell", for: indexPath) as? CookingCollectionViewCell else { return UICollectionViewCell() }
        cell.recipe = recipesInProgress[indexPath.row]
        return cell
    }
    
    
}
