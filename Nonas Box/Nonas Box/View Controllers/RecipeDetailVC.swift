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
    private var recipe: Recipe!
    private var stepByStepInstructions: [Step]? {
        didSet {
            stepByStepInstructionsTableView.reloadData()
        }
    }
    
    private var ingredients: [Ingredient]? {
        didSet {
            stepByStepInstructionsTableView.reloadData()
        }
    }
    
    lazy var backgroundImageView: UIImageView = {
        let iv = UIImageView(frame: view.bounds)
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    lazy var recipeImageView: UIImageView = {
        //        let iv = UIImageView(frame: CGRect(x: view.frame.midX / 2, y: view.frame.midY / 3, width: view.frame.width / 2, height: view.frame.width / 2))
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        iv.layer.cornerRadius = iv.frame.height / 2
        iv.layer.cornerRadius = 25
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    lazy var stepByStepInstructionsTableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.layer.cornerRadius = 15
        tv.dataSource = self
        tv.delegate = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "stepByStepInstructionsCell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    lazy var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemThinMaterialLight)
        let blurEffectView = UIVisualEffectView()
        blurEffectView.effect = blurEffect
        return blurEffectView
    }()
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = false
        addSubviews()
        loadRecipeDetails(recipe: self.recipe)
        //        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.expandRecipeImage))
        //        recipeImageView.isUserInteractionEnabled = true
        //        recipeImageView.addGestureRecognizer(gestureRecognizer)
    }
    
    //MARK: - Private Functions
    private func addSubviews() {
        view.addSubview(backgroundImageView)
        backgroundImageView.addSubview(blurEffectView)
        blurEffectView.frame = backgroundImageView.bounds
        loadImage(recipe: self.recipe)
        
        view.addSubview(recipeImageView)
        NSLayoutConstraint.activate([
            recipeImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            recipeImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            recipeImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            recipeImageView.heightAnchor.constraint(equalToConstant: view.safeAreaLayoutGuide.layoutFrame.height / 3)
        ])
        
        view.addSubview(stepByStepInstructionsTableView)
        NSLayoutConstraint.activate([
            stepByStepInstructionsTableView.topAnchor.constraint(equalTo: recipeImageView.bottomAnchor, constant: 20),
            stepByStepInstructionsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stepByStepInstructionsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            stepByStepInstructionsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func loadImage(recipe: Recipe) {
        SpoonacularAPIClient.manager.getImage(recipe: recipe) { (result) in
            switch result {
                case .failure(let error):
                    print(error)
                    self.backgroundImageView.image = nil
                    self.recipeImageView.image = UIImage(systemName: "xmark.rectangle.fill")!
                case .success(let image):
                    self.backgroundImageView.image = image
                    self.recipeImageView.image = image
            }
        }
    }
    
    private func loadRecipeDetails(recipe: Recipe) {
        SpoonacularAPIClient.manager.getRecipeDetails(recipeID: recipe.id) { (result) in
            switch result {
                case .failure(let error):
                    self.showAlert(message: "Could not get step by step instructions for \(recipe.title?.description ?? "this recipe").\nError:\(error.localizedDescription)")
                case .success(let recipeDetails):
                    self.stepByStepInstructions = recipeDetails.analyzedInstructions?.first?.steps
                    self.ingredients = recipeDetails.extendedIngredients
            }
        }
    }
    
}

//MARK: - TableView Methods
extension RecipeDetailVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return ingredients?.count ?? 0
            case 1:
                return stepByStepInstructions?.count ?? 0
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stepByStepInstructionsCell", for: indexPath)

        cell.textLabel?.numberOfLines = 0
        
        switch indexPath.section {
            case 0:
                guard let ingredient = ingredients?[indexPath.row],
                      let ingredientName = ingredient.name?.capitalized,
                      let ingredientMeasurements = ingredient.measures.us.shortHandMeasurement
                    else { return cell }
                cell.textLabel?.text = "\(ingredientMeasurements) \(ingredientName)"
            case 1:
                guard let stepInstruction = stepByStepInstructions?[indexPath.row] else { return cell }
                cell.textLabel?.text = stepInstruction.step
            default :
                print()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0:
                return "Ingredients"
            case 1:
                return "Directions"
            default:
                return nil
        }
        
    }
    
}
