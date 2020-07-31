//
//  RecipeDetailVC.swift
//  Nonas Box
//
//  Created by Jason Ruan on 7/19/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

class RecipeDetailVC: UIViewController {
    
    //MARK: - VC Initializer
    init(recipe: Recipe) {
        super.init(nibName: nil, bundle: nil)
        self.recipe = recipe
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Properties
    private var recipe: Recipe?
    
    lazy var backgroundImageView: UIImageView = {
        let iv = UIImageView(frame: view.bounds)
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    lazy var recipeImageView: UIImageView = {
        let iv = UIImageView(frame: CGRect(x: view.frame.midX / 2, y: view.frame.midY / 3, width: view.frame.width / 2, height: view.frame.width / 2))
        iv.clipsToBounds = true
        iv.layer.cornerRadius = iv.frame.height / 2
        iv.layer.borderWidth = 5
        iv.layer.borderColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    lazy var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemThinMaterialLight)
        let blurEffectView = UIVisualEffectView()
        blurEffectView.effect = blurEffect
        return blurEffectView
    }()
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        self.navigationController?.navigationBar.isHidden = false
        addSubviews()
    }
    
    //MARK: - Private Functions
    private func addSubviews() {
        view.addSubview(recipeImageView)
        recipeImageView.addSubview(blurEffectView)
        blurEffectView.frame = recipeImageView.bounds
        if let imageURL = recipe?.imageURL {
            loadImage(recipeURL: imageURL)
        }
    }
    
    private func loadImage(recipeURL: URL) {
        ImageHelper.shared.getImage(url: (recipe?.imageURL!)!) { (result) in
            DispatchQueue.main.async {
                switch result {
                    case .success(let image):
                        self.recipeImageView.image = image
                    case .failure(let error):
                        print(error)
                }
            }
        }
    }
    
}
