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
            stepByStepInstructionsTableView.tableView.reloadData()
        }
    }
    
    private var preferredMeasurementSystem: MeasurementSystem = .usa {
        didSet {
            stepByStepInstructionsTableView.tableView.reloadData()
        }
    }
    
    
    // MARK: - Private Constraint Variables
    
    private lazy var expandedViewConstraints: [NSLayoutConstraint] = {
        [self.recipeBlurbInfoLabel.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.4),
         self.buttonStackView.centerXAnchor.constraint(equalTo: recipeImageView.centerXAnchor),
         self.recipeImageView.bottomAnchor.constraint(equalTo: recipeBlurbInfoLabel.bottomAnchor),
         self.recipeImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)]
    }()
    
    private lazy var collapsedViewConstraints: [NSLayoutConstraint] = {
        [self.recipeBlurbInfoLabel.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.1),
         self.buttonStackView.leadingAnchor.constraint(equalTo: recipeBlurbInfoLabel.leadingAnchor),
         self.buttonStackView.trailingAnchor.constraint(equalTo: recipeBlurbInfoLabel.trailingAnchor),
         self.recipeImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 25),
         self.recipeImageView.bottomAnchor.constraint(equalTo: buttonStackView.bottomAnchor)]
    }()
    
    
    // MARK: - UI Objects
    private lazy var backgroundImageView: UIImageView = { return BackgroundImageView(frame: view.bounds) }()
    private lazy var recipeBlurbInfoLabel: RecipeBlurbLabel = { return RecipeBlurbLabel() }()
    
    private lazy var recipeImageView: UIImageView = {
        let iv = UIImageView(frame: view.bounds)
        iv.layer.cornerRadius = 15
        iv.layer.maskedCorners = []
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private lazy var buttonStackView: ButtonStackView = {
        let sv = ButtonStackView(frame: .zero)
        sv.bookmarkButton.setImage(checkIfRecipeIsBookmarked(id: recipeDetails?.id ?? 0) ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark"), for: .normal)
        sv.bookmarkButton.addTarget(self, action: #selector(updateBookmarkStatus), for: .touchUpInside)
        sv.weblinkButton.addTarget(self, action: #selector(openSourceLink), for: .touchUpInside)
        return sv
    }()
    
    private lazy var stepByStepInstructionsTableView: StepByStepInstructionsTableView = {
        let steptv = StepByStepInstructionsTableView(frame: .zero)
        steptv.tableView.dataSource = self
        steptv.tableView.delegate = self
        return steptv
    }()
    
    private lazy var closeVCButton: UIButton = {
        let button = UIButton(type: .close)
        button.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        return button
    }()
    
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        setUpViews()
        synthesizer.delegate = self
        configureAVAudioSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    
    //MARK: - Private Functions
    private func loadRecipeDetails(recipeID: Int) {
        showLoadingScreen()
        SpoonacularAPIClient.manager.getRecipeDetails(recipeID: recipeID) { [weak self] (result) in
            switch result {
                case .failure(let error):
                    self?.showAlert(message: "Could not get step by step instructions for the selected recipe.\nError:\(error.localizedDescription)")
                case .success(let recipeDetails):
                    self?.title = recipeDetails.title
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
                    self?.removeLoadingScreen()
                    self?.configureNavigationBarForTranslucence()
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
        do {
            return try Spoonacular_PersistenceHelper.manager.checkIsSaved(forRecipeID: id)
        } catch {
            print(error)
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
        guard let recipeDetails = recipeDetails else { return }
        do {
            if try Spoonacular_PersistenceHelper.manager.getSavedRecipesDictionary()[recipeDetails.id.description] != nil {
                try Spoonacular_PersistenceHelper.manager.delete(recipeID: recipeDetails.id)
                buttonStackView.bookmarkButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
            } else {
                try Spoonacular_PersistenceHelper.manager.save(recipeID: recipeDetails.id, recipeDetails: recipeDetails)
                buttonStackView.bookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
            }
        } catch {
            print(error)
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
        view.addSubview(recipeImageView)
        view.addSubview(recipeBlurbInfoLabel)
        view.addSubview(buttonStackView)
        view.addSubview(stepByStepInstructionsTableView)
        
        recipeImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recipeImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            recipeImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ] + expandedViewConstraints)
        
        recipeBlurbInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recipeBlurbInfoLabel.topAnchor.constraint(equalTo: recipeImageView.topAnchor, constant: 5),
            recipeBlurbInfoLabel.trailingAnchor.constraint(equalTo: recipeImageView.leadingAnchor),
            recipeBlurbInfoLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        ])
        
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: recipeBlurbInfoLabel.bottomAnchor, constant: 5),
            buttonStackView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.05)
        ])
        
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
                      let ingredientMeasurements = preferredMeasurementSystem == .usa ? ingredients[indexPath.row].measures.us.shortHandMeasurement : ingredients[indexPath.row].measures.metric.shortHandMeasurement
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
        if indexPath.section == 0 {
            preferredMeasurementSystem = preferredMeasurementSystem == .usa ? .metric : .usa
            
        } else {
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
    }
    
}


// MARK: - ScrollView Methods
extension RecipeDetailVC {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y == 0 {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                NSLayoutConstraint.deactivate(self.collapsedViewConstraints)
                NSLayoutConstraint.activate(self.expandedViewConstraints)
                self.title = self.recipeDetails?.title
                self.recipeImageView.layer.maskedCorners = []
                self.view.layoutIfNeeded()
            }, completion: nil)
            
        } else {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                NSLayoutConstraint.deactivate(self.expandedViewConstraints)
                NSLayoutConstraint.activate(self.collapsedViewConstraints)
                self.title = nil
                self.recipeImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        updateSegmentedControlIndexWithSection()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateSegmentedControlIndexWithSection()
    }
    
    private func updateSegmentedControlIndexWithSection() {
        let visiblerows = stepByStepInstructionsTableView.tableView.indexPathsForVisibleRows
        if let lastIndex = visiblerows?.last {
            stepByStepInstructionsTableView.underlinedSegmentedControl.segmentedControl.selectedSegmentIndex = lastIndex.section > 0 ? 1 : 0
            stepByStepInstructionsTableView.underlinedSegmentedControl.index = lastIndex.section > 0 ? 1 : 0
        }
    }
}


// MARK: - AVSpeechSynthesizer Delegate Methods
extension RecipeDetailVC: AVSpeechSynthesizerDelegate {
    // Highlights just the word(s) being spoken in text
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        guard let selectedCell = getSelectedTableViewCell() else { return }
        let mutableAttributeString = NSMutableAttributedString(string: utterance.speechString)
        mutableAttributeString.addAttribute(.foregroundColor,
                                            value: selectedCell.stepNumberLabel.textColor ?? UIColor.yellow,
                                            range: characterRange)
        selectedCell.stepInstructionLabel.attributedText = mutableAttributeString
        
    }
    
    // Resets the color of the selected cell's label when finished speaking
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        guard let selectedCell = getSelectedTableViewCell() else { return }
        selectedCell.stepInstructionLabel.attributedText = NSAttributedString(string: utterance.speechString)
    }
    
    private func getSelectedTableViewCell() -> StepByStepInstructionTableViewCell? {
        guard let indexPath = selectedCellIndexPath,
              let selectedCell = stepByStepInstructionsTableView.tableView.cellForRow(at: indexPath) as? StepByStepInstructionTableViewCell else { return nil }
        return selectedCell
    }
    
}


fileprivate enum MeasurementSystem {
    case usa
    case metric
}
