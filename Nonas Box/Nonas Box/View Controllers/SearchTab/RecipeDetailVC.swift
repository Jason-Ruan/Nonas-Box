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
    init(recipeID: Int) {
        super.init(nibName: nil, bundle: nil)
        loadRecipeDetails(recipeID: recipeID)
    }
    
    init(recipeDetails: RecipeDetails) {
        super.init(nibName: nil, bundle: nil)
        self.recipeDetails = recipeDetails
        addCloseButton()
        loadImage(recipeDetails: recipeDetails)
        recipeBlurbInfoLabel.configureAttributedText(title: recipeDetails.title, servings: recipeDetails.servings, readyInMinutes: recipeDetails.readyInMinutes)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Properties
    private let synthesizer = AVSpeechSynthesizer()
    
    private var selectedCellIndexPath: IndexPath? {
        willSet {
            guard let selectedCellIndexPath = selectedCellIndexPath else { return }
            resetColorOfReadText(selectedCellIndexPath: selectedCellIndexPath)
        }
    }
    
    private var recipeDetails: RecipeDetails? {
        didSet {
            guard let recipeDetails = recipeDetails else { return }
            loadImage(recipeDetails: recipeDetails)
            recipeBlurbInfoLabel.configureAttributedText(title: recipeDetails.title, servings: recipeDetails.servings, readyInMinutes: recipeDetails.readyInMinutes)
            stepByStepInstructionsTableView.tableView.reloadData()
        }
    }
    
    
    // MARK: - Private Constraint Variables
    
    private lazy var recipeImageViewExpandedConstraints: [NSLayoutConstraint] = {
        [self.recipeImageView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.4),
         self.recipeImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)]
    }()
    
    private lazy var recipeImageViewCollapsedConstraints: [NSLayoutConstraint] = {
        [self.recipeImageView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.2),
         self.recipeImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)]
    }()
    
    
    // MARK: - UI Objects
    lazy var backgroundImageView: UIImageView = {
        let iv = UIImageView(frame: view.bounds)
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    lazy var recipeImageView: UIImageView = {
        let iv = UIImageView(frame: view.bounds)
        iv.clipsToBounds = true
        iv.layer.borderWidth = 1
        iv.layer.borderColor = UIColor.lightGray.cgColor
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    lazy var recipeBlurbInfoLabel: RecipeBlurbLabel = {
        let label = RecipeBlurbLabel()
        return label
    }()
    
    lazy var buttonStackView: UIStackView = {
        let bookmarkButton = UIButton(type: .system)
        bookmarkButton.setImage(checkIfRecipeIsBookmarked(id: recipeDetails?.id ?? 0) ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark"), for: .normal)
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
        
        return sv
    }()
    
    lazy var stepByStepInstructionsTableView: StepByStepInstructionsTableView = {
        let steptv = StepByStepInstructionsTableView(frame: .zero)
        steptv.tableView.dataSource = self
        steptv.tableView.delegate = self
        return steptv
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
    
    lazy var closeVCButton: UIButton = {
        let button = UIButton(type: .close)
        button.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        return button
    }()
    
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = false
        setUpViews()
        synthesizer.delegate = self
        configureAVAudioSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
    
    
    //MARK: - Private Functions
    private func loadRecipeDetails(recipeID: Int) {
        SpoonacularAPIClient.manager.getRecipeDetails(recipeID: recipeID) { [weak self] (result) in
            switch result {
                case .failure(let error):
                    self?.showAlert(message: "Could not get step by step instructions for the selected recipe.\nError:\(error.localizedDescription)")
                case .success(let recipeDetails):
                    self?.recipeDetails = recipeDetails
                    self?.loadImage(recipeDetails: recipeDetails)
                    self?.recipeBlurbInfoLabel.configureAttributedText(title: recipeDetails.title, servings: recipeDetails.servings, readyInMinutes: recipeDetails.readyInMinutes)
            }
        }
    }
    
    private func loadImage(recipeDetails: RecipeDetails) {
        guard let imageURL = recipeDetails.imageURL  else { return }
        ImageHelper.shared.getImage(urls: [imageURL]) { [weak self] (result) in
            switch result {
                case .failure(let error):
                    print(error)
                    self?.backgroundImageView.image = nil
                    self?.recipeImageView.image = UIImage(systemName: "xmark.rectangle.fill")!
                case .success(let image):
                    self?.backgroundImageView.image = image
                    self?.recipeImageView.image = image
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
    
    private func resetColorOfReadText(selectedCellIndexPath: IndexPath) {
        // Purpose is to reset the color of text in previous selected cell being read by voice over.
        guard let cell = stepByStepInstructionsTableView.tableView.cellForRow(at: selectedCellIndexPath) as? StepByStepInstructionTableViewCell,
              let steps = recipeDetails?.analyzedInstructions?[selectedCellIndexPath.section - 1].steps
        else { return }
        
        cell.stepInstructionLabel.attributedText = NSAttributedString(string: steps[selectedCellIndexPath.row].instruction ?? "")
    }
    
    
    // MARK: - Obj-C Functions
    @objc private func updateBookmarkStatus() {
        guard let bookmarkButton = buttonStackView.arrangedSubviews.first as? UIButton, let recipeID = recipeDetails?.id, let recipeTitle = recipeDetails?.title else { return }
        
        if var bookmarkedRecipes = UserDefaults.standard.value(forKey: "bookmarkedRecipes") as? [String : String] {
            // Adds recipe to bookmarkedRecipes
            if bookmarkedRecipes[recipeID.description] == nil {
                bookmarkedRecipes[recipeID.description] = recipeTitle
                UserDefaults.standard.set(bookmarkedRecipes, forKey: "bookmarkedRecipes")
                bookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
                // Removes recipe from bookmarkedRecipes
            } else {
                bookmarkedRecipes.removeValue(forKey: recipeID.description)
                UserDefaults.standard.set(bookmarkedRecipes, forKey: "bookmarkedRecipes")
                bookmarkButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
            }
        } else {
            // Initializes bookmarkedRecipes and adds recipe to it
            var bookmarkedRecipes = [String : String]()
            bookmarkedRecipes[recipeID.description] = recipeTitle
            UserDefaults.standard.set(bookmarkedRecipes, forKey: "bookmarkedRecipes")
            bookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        }
    }
    
    @objc private func openSourceLink() {
        guard let recipeSourceURL = recipeDetails?.sourceUrl else { return }
        let safariViewController = SFSafariViewController(url: recipeSourceURL)
        present(safariViewController, animated: true)
    }
    
    @objc private func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
    
    
}


// MARK: - Private Constraints
extension RecipeDetailVC {
    private func setUpViews() {
        view.addSubview(backgroundImageView)
        backgroundImageView.addSubview(blurEffectView)
        blurEffectView.frame = backgroundImageView.bounds
        
        view.addSubview(recipeImageView)
        recipeImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recipeImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            recipeImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ] + recipeImageViewExpandedConstraints)
        
        view.addSubview(recipeBlurbInfoLabel)
        recipeBlurbInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recipeBlurbInfoLabel.topAnchor.constraint(equalTo: recipeImageView.topAnchor, constant: 5),
            recipeBlurbInfoLabel.bottomAnchor.constraint(equalTo: recipeImageView.bottomAnchor),
            recipeBlurbInfoLabel.trailingAnchor.constraint(equalTo: recipeImageView.leadingAnchor),
            recipeBlurbInfoLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        ])
        
        view.addSubview(buttonStackView)
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: recipeImageView.bottomAnchor, constant: 5),
            buttonStackView.centerXAnchor.constraint(equalTo: recipeImageView.centerXAnchor),
            buttonStackView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.05)
        ])
        
        view.addSubview(stepByStepInstructionsTableView)
        stepByStepInstructionsTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stepByStepInstructionsTableView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 20),
            stepByStepInstructionsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stepByStepInstructionsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            stepByStepInstructionsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func addCloseButton() {
        view.addSubview(closeVCButton)
        closeVCButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeVCButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            closeVCButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            closeVCButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05),
            closeVCButton.widthAnchor.constraint(equalTo: closeVCButton.heightAnchor)
        ])
    }
}

//MARK: - TableView Methods
extension RecipeDetailVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + (recipeDetails?.analyzedInstructions?.count ?? 1)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let ingredients = recipeDetails?.extendedIngredients, let analyzedInstructions = recipeDetails?.analyzedInstructions else { return 0 }
        switch section {
            case 0:
                return ingredients.count
            case 1...analyzedInstructions.count:
                return analyzedInstructions[section - 1].steps?.count ?? 0
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let ingredients = recipeDetails?.extendedIngredients,
              let analyzedInstructions = recipeDetails?.analyzedInstructions
        else { return UITableViewCell() }
        
        switch indexPath.section {
            case 0:
                guard let ingredientName = ingredients[indexPath.row].name?.capitalized,
                      let ingredientMeasurements = ingredients[indexPath.row].measures.us.shortHandMeasurement
                else { return UITableViewCell() }
                
                let ingredientCell = tableView.dequeueReusableCell(withIdentifier: "ingredientCell", for: indexPath)
                ingredientCell.backgroundColor = .clear
                ingredientCell.selectionStyle = .none
                ingredientCell.textLabel?.text = "\(ingredientMeasurements) \(ingredientName)"
                return ingredientCell
                
            case 1...analyzedInstructions.count:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: StepByStepInstructionTableViewCell.identifier, for: indexPath) as? StepByStepInstructionTableViewCell
                else { return UITableViewCell() }
                
                cell.step = analyzedInstructions[indexPath.section - 1].steps![indexPath.row]
                return cell
                
            default :
                print()
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let analyzedInstructions = recipeDetails?.analyzedInstructions else { return "placeholder_header"}
        switch section {
            case 0:
                return "Ingredients"
            case 1...analyzedInstructions.count:
                guard let instructionSectionName = analyzedInstructions[section - 1].name else { return "Directions"}
                return instructionSectionName.count > 0 ? instructionSectionName : "Directions"
            default:
                return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section > 0 else { return }
        
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        if let stepInstructionString = recipeDetails?.analyzedInstructions?[indexPath.section - 1].steps?[indexPath.row].instruction {
            selectedCellIndexPath = IndexPath(row: indexPath.row, section: indexPath.section)
            let utterance = AVSpeechUtterance(string: stepInstructionString)
            utterance.rate = 0.45
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            synthesizer.speak(utterance)
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    // MARK: - ScrollView Methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y == 0 {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                NSLayoutConstraint.deactivate(self.recipeImageViewCollapsedConstraints)
                NSLayoutConstraint.activate(self.recipeImageViewExpandedConstraints)
                self.view.layoutIfNeeded()
            }, completion: nil)
            
        } else {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                NSLayoutConstraint.deactivate(self.recipeImageViewExpandedConstraints)
                NSLayoutConstraint.activate(self.recipeImageViewCollapsedConstraints)
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let visiblerows = stepByStepInstructionsTableView.tableView.indexPathsForVisibleRows
        if let lastIndex = visiblerows?.last {
            stepByStepInstructionsTableView.underlinedSegmentedControl.segmentedControl.selectedSegmentIndex = lastIndex.section
            stepByStepInstructionsTableView.underlinedSegmentedControl.index = lastIndex.section
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visiblerows = stepByStepInstructionsTableView.tableView.indexPathsForVisibleRows
        if let lastIndex = visiblerows?.last {
            stepByStepInstructionsTableView.underlinedSegmentedControl.segmentedControl.selectedSegmentIndex = lastIndex.section
            stepByStepInstructionsTableView.underlinedSegmentedControl.index = lastIndex.section
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
