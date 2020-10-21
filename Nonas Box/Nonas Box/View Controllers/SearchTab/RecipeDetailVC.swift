//
//  RecipeDetailVC.swift
//  Nonas Box
//
//  Created by Jason Ruan on 7/19/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import AVFoundation
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
    private let synthesizer = AVSpeechSynthesizer()
    
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
    
    
    // MARK: - UI Objects
    lazy var backgroundImageView: UIImageView = {
        let iv = UIImageView(frame: view.bounds)
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    lazy var recipeImageView: UIImageView = {
        let iv = UIImageView(frame: view.bounds)
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
        tv.backgroundColor = .clear
        tv.dataSource = self
        tv.delegate = self
        tv.register(StepByStepInstructionTableViewCell.self, forCellReuseIdentifier: "stepByStepInstructionCell")
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "ingredientCell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    lazy var blurEffectView: UIVisualEffectView = {
        let blurEffectView = UIVisualEffectView()
        switch traitCollection.userInterfaceStyle {
            case .light:
                blurEffectView.effect = UIBlurEffect(style: .systemThinMaterialLight)
            case .dark:
                blurEffectView.effect = UIBlurEffect(style: .dark)
            default:
                return blurEffectView
        }
        return blurEffectView
    }()
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = false
        addSubviews()
        loadRecipeDetails(recipe: self.recipe)
        configureAVAudioSession()
        //        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.expandRecipeImage))
        //        recipeImageView.isUserInteractionEnabled = true
        //        recipeImageView.addGestureRecognizer(gestureRecognizer)
    }
    
    //MARK: - Private Functions
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
                    self.stepByStepInstructions = recipeDetails.analyzedInstructions?.reduce(into: [], { (totalSteps, step) in
                        totalSteps += step.steps ?? []
                    })
                    self.ingredients = recipeDetails.extendedIngredients
            }
        }
    }
    
    private func configureAVAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
    }
    
}


// MARK: - Private Constraints
extension RecipeDetailVC {
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "stepByStepInstructionCell", for: indexPath) as? StepByStepInstructionTableViewCell else { return UITableViewCell() }
        
        switch indexPath.section {
            case 0:
                guard let ingredient = ingredients?[indexPath.row],
                      let ingredientName = ingredient.name?.capitalized,
                      let ingredientMeasurements = ingredient.measures.us.shortHandMeasurement
                else { return cell }
                let ingredientCell = tableView.dequeueReusableCell(withIdentifier: "ingredientCell", for: indexPath)
                ingredientCell.backgroundColor = .clear
                ingredientCell.selectionStyle = .none
                ingredientCell.textLabel?.text = "\(ingredientMeasurements) \(ingredientName)"
                return ingredientCell
            case 1:
                guard let step = stepByStepInstructions?[indexPath.row] else { return cell }
                cell.step = step
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        if let stepInstructionString = stepByStepInstructions?[indexPath.row].step {
            let utterance = AVSpeechUtterance(string: "Step \(indexPath.row + 1), \(stepInstructionString)")
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            synthesizer.speak(utterance)
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}
