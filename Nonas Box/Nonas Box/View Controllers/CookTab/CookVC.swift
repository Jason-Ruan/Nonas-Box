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
    lazy var recipesInProgressCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: view.safeAreaLayoutGuide.layoutFrame.width * 0.9,
                                          height: view.safeAreaLayoutGuide.layoutFrame.height / CGFloat(recipesInProgress.count))
        let cv = UICollectionView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: layout)
        cv.register(CookingCollectionViewCell.self, forCellWithReuseIdentifier: "cookingCell")
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    
    //MARK: - Properties
    var recipesInProgress: [RecipeDetails] = []
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        view.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
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
