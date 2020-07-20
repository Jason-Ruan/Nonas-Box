//
//  RecipeDetailVC.swift
//  Nonas Box
//
//  Created by Jason Ruan on 7/19/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

class RecipeDetailVC: UIViewController {
    //MARK: - Properties
    var recipe: Recipe? {
        didSet {
            print(self.recipe?.title)
        }
    }
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        view.backgroundColor = .systemYellow
    }
    
}
