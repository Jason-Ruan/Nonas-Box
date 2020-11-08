//
//  RecipeDetailVC.swift
//  Nonas Box
//
//  Created by Jason Ruan on 7/19/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import AVFoundation
import SafariServices
import UIKit

class RecipeDetailVC: UIViewController {
    
    //MARK: - VC Initializer
    required init(recipe: Recipe) {
        super.init(nibName: nil, bundle: nil)
        self.recipe = recipe
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Properties
    private let synthesizer = AVSpeechSynthesizer()
    
    private var selectedCellIndexPath: IndexPath? {
        willSet {
            // Purpose is to reset the color of text in previous selected cell being read by voice over.
            guard let selectedCellIndexPath = selectedCellIndexPath,
                  let cell = stepByStepInstructionsTableView.cellForRow(at: selectedCellIndexPath) as? StepByStepInstructionTableViewCell,
                  let stepByStepInstructions = stepByStepInstructions else { return }
            
            cell.stepInstructionLabel.attributedText = NSAttributedString(string: stepByStepInstructions[selectedCellIndexPath.row].instruction ?? "")
        }
    }
    
    private var recipe: Recipe!
    private var recipeDetails: RecipeDetails?
    
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
    
    
    // MARK: - Private Constraint Variables
    
    private lazy var recipeImageViewExpandedHeightAnchor: NSLayoutConstraint = {
        self.recipeImageView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.4)
    }()
    
    private lazy var recipeImageViewExpandedLeadingAnchor: NSLayoutConstraint = {
        self.recipeImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
    }()
    
    private lazy var recipeImageViewCollapsedHeightAnchor: NSLayoutConstraint = {
        self.recipeImageView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.2)
    }()
    
    private lazy var recipeImageViewCollapsedLeadingAnchor: NSLayoutConstraint = {
        self.recipeImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
    }()
    
    
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
    
    lazy var recipeSummaryInfo: UILabel = {
       let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        
        let recipeTitle = NSAttributedString(string: "\(recipe.title ?? "placeholder title")\n", attributes: [.font : UIFont.systemFont(ofSize: 21, weight: .bold)])
        let recipeServings = NSAttributedString(string: "\nServings: \(recipe.servings ?? 1)", attributes: [.font : UIFont.systemFont(ofSize: 14, weight: .light)])
        let recipeTime = NSAttributedString(string: "\nTime: \(recipe.readyInMinutes ?? 1) minutes", attributes: [.font : UIFont.systemFont(ofSize: 14, weight: .medium)])

        let summaryAttributedString = NSMutableAttributedString()
        summaryAttributedString.append(recipeTitle)
        summaryAttributedString.append(recipeServings)
        summaryAttributedString.append(recipeTime)
        
        label.attributedText = summaryAttributedString
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var buttonStackView: UIStackView = {
        let bookmarkButton = UIButton(type: .system)
        bookmarkButton.setImage(checkIfRecipeIsBookmarked(id: recipe.id) ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark"), for: .normal)
        bookmarkButton.tintColor = .systemRed
        bookmarkButton.setTitle("Bookmark", for: .normal)
        bookmarkButton.addTarget(self, action: #selector(updateBookmarkStatus), for: .touchUpInside)
        
        let webLinkButton = UIButton(type: .system)
        webLinkButton.setImage(UIImage(systemName: "safari.fill"), for: .normal)
        webLinkButton.setTitle("Source", for: .normal)
        webLinkButton.addTarget(self, action: #selector(openSourceLink), for: .touchUpInside)
        
        let sv = UIStackView(arrangedSubviews: [bookmarkButton, webLinkButton])
        sv.axis = .horizontal
        sv.alignment = .fill
        sv.distribution = .fillEqually
        sv.spacing = 25
        
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    lazy var stepByStepInstructionsTableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.backgroundColor = .clear
        tv.dataSource = self
        tv.delegate = self
        tv.bounces = false
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
        title = recipe.title
        self.navigationController?.navigationBar.isHidden = false
        synthesizer.delegate = self
        addSubviews()
        loadRecipeDetails(recipe: self.recipe)
        configureAVAudioSession()
        //        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.expandRecipeImage))
        //        recipeImageView.isUserInteractionEnabled = true
        //        recipeImageView.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
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
    
    private func checkIfRecipeIsBookmarked(id: Int) -> Bool {
        // For bookmarkedImageView.isHidden
        if let bookmarkedRecipes = UserDefaults.standard.object(forKey: "bookmarkedRecipes") as? [String : String] {
            return bookmarkedRecipes[id.description] != nil
        } else {
            return false
        }
    }
    
    
    // MARK: - Obj-C Functions
    @objc private func updateBookmarkStatus() {
        guard let bookmarkButton = buttonStackView.arrangedSubviews.first as? UIButton else { return }
        if var bookmarkedRecipes = UserDefaults.standard.value(forKey: "bookmarkedRecipes") as? [String : String] {
            // Adds recipe to bookmarkedRecipes
            if bookmarkedRecipes[recipe.id.description] == nil {
                bookmarkedRecipes[recipe.id.description] = recipe.title
                UserDefaults.standard.set(bookmarkedRecipes, forKey: "bookmarkedRecipes")
                bookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
            // Removes recipe from bookmarkedRecipes
            } else {
                bookmarkedRecipes.removeValue(forKey: recipe.id.description)
                UserDefaults.standard.set(bookmarkedRecipes, forKey: "bookmarkedRecipes")
                bookmarkButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
            }
        } else {
            // Initializes bookmarkedRecipes and adds recipe to it
            var bookmarkedRecipes = [String : String]()
            bookmarkedRecipes[recipe.id.description] = recipe.title ?? "place_holder_title"
            UserDefaults.standard.set(bookmarkedRecipes, forKey: "bookmarkedRecipes")
            bookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        }
    }
    
    @objc private func openSourceLink() {
        guard let recipeSourceURL = recipeDetails?.sourceUrl else { return }
        let safariViewController = SFSafariViewController(url: recipeSourceURL)
        present(safariViewController, animated: true)
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
            recipeImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            recipeImageViewExpandedHeightAnchor,
            recipeImageViewExpandedLeadingAnchor
        ])
        
        view.addSubview(recipeSummaryInfo)
        NSLayoutConstraint.activate([
            recipeSummaryInfo.topAnchor.constraint(equalTo: recipeImageView.topAnchor, constant: 5),
            recipeSummaryInfo.bottomAnchor.constraint(equalTo: recipeImageView.bottomAnchor),
            recipeSummaryInfo.trailingAnchor.constraint(equalTo: recipeImageView.leadingAnchor),
            recipeSummaryInfo.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        ])
        
        view.addSubview(buttonStackView)
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: recipeImageView.bottomAnchor, constant: 5),
            buttonStackView.centerXAnchor.constraint(equalTo: recipeImageView.centerXAnchor),
            buttonStackView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.05)
        ])
        
        view.addSubview(stepByStepInstructionsTableView)
        NSLayoutConstraint.activate([
            stepByStepInstructionsTableView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 20),
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
        
        if let stepInstructionString = stepByStepInstructions?[indexPath.row].instruction {
            selectedCellIndexPath = indexPath
            let utterance = AVSpeechUtterance(string: stepInstructionString)
            utterance.rate = 0.45
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            synthesizer.speak(utterance)
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (0...20).contains(scrollView.contentOffset.y) {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                self.recipeImageViewCollapsedHeightAnchor.isActive = false
                self.recipeImageViewCollapsedLeadingAnchor.isActive = false
                self.recipeImageViewExpandedHeightAnchor.isActive = true
                self.recipeImageViewExpandedLeadingAnchor.isActive = true
                self.view.layoutIfNeeded()
            }, completion: nil)
            
        } else {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                self.recipeImageViewExpandedHeightAnchor.isActive = false
                self.recipeImageViewExpandedLeadingAnchor.isActive = false
                self.recipeImageViewCollapsedHeightAnchor.isActive = true
                self.recipeImageViewCollapsedLeadingAnchor.isActive = true
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
}


// MARK: - TraitCollection Methods
extension RecipeDetailVC {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        switch traitCollection.userInterfaceStyle {
            case .light:
                blurEffectView.effect = UIBlurEffect(style: .systemThinMaterialLight)
            case .dark:
                blurEffectView.effect = UIBlurEffect(style: .dark)
            default:
                return
        }
    }
}


// MARK: - AVSpeechSynthesizer Delegate Methods
extension RecipeDetailVC: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        guard let indexPath = selectedCellIndexPath,
              let selectedCell = stepByStepInstructionsTableView.cellForRow(at: indexPath) as? StepByStepInstructionTableViewCell else { return }
        
        let mutableAttributeString = NSMutableAttributedString(string: utterance.speechString)
        mutableAttributeString.addAttribute(.foregroundColor,
                                            value: selectedCell.stepNumberLabel.textColor ?? UIColor.yellow,
                                            range: characterRange)
        selectedCell.stepInstructionLabel.attributedText = mutableAttributeString
        
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        guard let indexPath = selectedCellIndexPath,
              let selectedCell = stepByStepInstructionsTableView.cellForRow(at: indexPath) as? StepByStepInstructionTableViewCell else { return }
        
        selectedCell.stepInstructionLabel.attributedText = NSAttributedString(string: utterance.speechString)
    }
    
}
