//
//  RecipeDetailVC.swift
//  Nonas Box
//
//  Created by Jason Ruan on 7/19/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Properties
    private var recipeDetails: RecipeDetails? {
        didSet {
            stepByStepInstructionsTableView.reloadData()
        }
    }
    
    private var measurementSystem: MeasurementSystem = .usa {
        didSet {
            guard let numIngredients = recipeDetails?.extendedIngredients.count else { return }
            let indexPaths = (0..<numIngredients).map { IndexPath(row: $0, section: 0) }
            stepByStepInstructionsTableView.reloadRows(at: indexPaths, with: .automatic)
        }
    }
    
    
    
    // MARK: - Private Constraint Variables
    
    private lazy var expandedViewConstraints: [NSLayoutConstraint] = {
        [recipeImageView.topAnchor.constraint(equalTo: view.topAnchor),
         recipeImageView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.4),
         recipeImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
         recipeBlurbInfoLabel.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.15),
         recipeBlurbInfoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
         recipeBlurbInfoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
         recipeBlurbInfoLabel.topAnchor.constraint(equalTo: recipeImageView.bottomAnchor),
         buttonStackView.topAnchor.constraint(equalTo: recipeBlurbInfoLabel.bottomAnchor, constant: 15),
         buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ]
    }()
    
    private lazy var collapsedViewConstraints: [NSLayoutConstraint] = {
        [recipeBlurbInfoLabel.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.2),
         recipeBlurbInfoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
         recipeImageView.leadingAnchor.constraint(equalTo: view.centerXAnchor),
         recipeImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
         recipeBlurbInfoLabel.trailingAnchor.constraint(equalTo: recipeImageView.leadingAnchor, constant: -5),
         recipeBlurbInfoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
         buttonStackView.topAnchor.constraint(equalTo: recipeBlurbInfoLabel.bottomAnchor, constant: 15),
         buttonStackView.centerXAnchor.constraint(equalTo: recipeBlurbInfoLabel.centerXAnchor),
         recipeImageView.bottomAnchor.constraint(equalTo: buttonStackView.bottomAnchor)
        ]
    }()
    
    
    // MARK: - UI Objects
    private lazy var backgroundImageView: UIImageView = { return BackgroundImageView(frame: view.bounds) }()
    private lazy var recipeBlurbInfoLabel: RecipeBlurbLabel = { return RecipeBlurbLabel() }()
    
    private lazy var recipeImageView: UIImageView = {
        let iv = UIImageView(frame: view.bounds)
        iv.layer.cornerRadius = 20
        iv.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private lazy var buttonStackView: ButtonStackView = {
        let sv = ButtonStackView(frame: .zero)
        sv.bookmarkButton.addTarget(self, action: #selector(updateBookmarkStatus), for: .touchUpInside)
        sv.weblinkButton.addTarget(self, action: #selector(openSourceLink), for: .touchUpInside)
        return sv
    }()
    
    private lazy var stepByStepInstructionsTableView: StepByStepInstructionsTableView = {
        let steptv = StepByStepInstructionsTableView(frame: .zero)
        steptv.tableView.showsVerticalScrollIndicator = false
        steptv.tableView.dataSource = self
        steptv.tableView.delegate = self
        return steptv
    }()
    
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        setUpViews()
        guard let recipeDetails = recipeDetails else { return }
        configureViews(forRecipeDetails: recipeDetails)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
        configureNavigationBarForTranslucence()
        if let recipeID = recipeDetails?.id {
            checkIfRecipeIsBookmarked(id: recipeID)
        }
    }
    
    
    //MARK: - Private Functions
    private func loadRecipeDetails(recipeID: Int) {
        showLoadingScreen(blockBackgroundViews: true)
        SpoonacularAPIClient.manager.getRecipeDetails(recipeID: recipeID) { [weak self] (result) in
            switch result {
            case .failure(let error):
                self?.showAlert(message: "Could not get step by step instructions for the selected recipe.\nError:\(error.localizedDescription)")
            case .success(let recipeDetails):
                self?.recipeDetails = recipeDetails
                self?.configureViews(forRecipeDetails: recipeDetails)
            }
        }
    }
    
    private func loadImage(recipeDetails: RecipeDetails) {
        guard let imageURL = recipeDetails.imageURL  else {
            backgroundImageView.image = nil
            recipeImageView.image = UIImage(systemName: .xmarkRectangleFill)
            removeLoadingScreen()
            return
        }
        
        recipeImageView.kf.setImage(with: imageURL) { [weak self] result in
            switch result {
            case .success(let retrievedImageResult):
                self?.backgroundImageView.image = retrievedImageResult.image
            case .failure(let error):
                self?.recipeImageView.image = UIImage(systemName: .xmarkRectangleFill)
                print(error)
            }
            self?.removeLoadingScreen()
        }
        
    }
    
    private func configureViews(forRecipeDetails recipeDetails: RecipeDetails) {
        loadImage(recipeDetails: recipeDetails)
        checkIfRecipeIsBookmarked(id: recipeDetails.id)
        recipeBlurbInfoLabel.configureAttributedText(title: recipeDetails.title, servings: recipeDetails.servings, readyInMinutes: recipeDetails.readyInMinutes)
        stepByStepInstructionsTableView.numIngredients = recipeDetails.extendedIngredients.count
    }
    
    private func checkIfRecipeIsBookmarked(id: Int) {
        do {
            let isBookmarked = try Spoonacular_PersistenceHelper.manager.checkIsSaved(forRecipeID: id)
            buttonStackView.bookmarkButton.setImage(isBookmarked ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark"), for: .normal)
        } catch {
            print(error)
        }
    }
    
    
    // MARK: - Obj-C Functions
    @objc private func updateBookmarkStatus() {
        guard let recipeDetails = recipeDetails else { return }
        do {
            if try Spoonacular_PersistenceHelper.manager.getSavedRecipesDictionary(from: .collection)[recipeDetails.id.description] != nil {
                try Spoonacular_PersistenceHelper.manager.delete(recipeID: recipeDetails.id, persistenceStorage: .collection)
                buttonStackView.bookmarkButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
            } else {
                try Spoonacular_PersistenceHelper.manager.save(recipeID: recipeDetails.id, recipeDetails: recipeDetails, persistenceStorage: .collection)
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
        view.addSubview(buttonStackView)
        view.addSubview(recipeBlurbInfoLabel)
        view.addSubview(stepByStepInstructionsTableView)
        
        recipeImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recipeImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ] + expandedViewConstraints)
        
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonStackView.heightAnchor.constraint(equalToConstant: 25)
        ])
        
        recipeBlurbInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        stepByStepInstructionsTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stepByStepInstructionsTableView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 15),
            stepByStepInstructionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            stepByStepInstructionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            stepByStepInstructionsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

//MARK: - TableView Methods
extension RecipeDetailVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let recipeDetails = recipeDetails else { return 0 }
        return 1 + recipeDetails.numOfSectionsOfInstructions
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
            guard let ingredientCell = tableView.dequeueReusableCell(withIdentifier: IngredientTableViewCell.reuseIdentifier,
                                                                     for: indexPath) as? IngredientTableViewCell
            else { return UITableViewCell() }
            ingredientCell.measurementSystem = measurementSystem
            ingredientCell.ingredient = ingredients[indexPath.row]
            ingredientCell.delegate = self
            return ingredientCell
            
        case 1...analyzedInstructions.count:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: StepByStepInstructionTableViewCell.identifier,
                                                           for: indexPath) as? StepByStepInstructionTableViewCell
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section ==  0 {
            let headerView = IngredientTableViewHeaderView(reuseIdentifier: IngredientTableViewHeaderView.reuseIdentifier)
            headerView.delegate = self
            return headerView
        }
        return nil
    }
    
}


// MARK: - ScrollView Methods
extension RecipeDetailVC {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y == 0 {
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
                NSLayoutConstraint.deactivate(self.collapsedViewConstraints)
                NSLayoutConstraint.activate(self.expandedViewConstraints)
                self.recipeImageView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                self.view.layoutIfNeeded()
            }, completion: nil)
            
            navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = false }
            
        } else {
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
                NSLayoutConstraint.deactivate(self.expandedViewConstraints)
                NSLayoutConstraint.activate(self.collapsedViewConstraints)
                self.recipeImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
                self.view.layoutIfNeeded()
            }, completion: nil)
            
            navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = true }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        updateSegmentedControlIndexWithSection()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateSegmentedControlIndexWithSection()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
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

extension RecipeDetailVC: TogglableMeasurementSystem {
    func useAmericanMeasurementSystem() {
        measurementSystem = .usa
    }
    
    func useMetricSystem() {
        measurementSystem = .metric
    }
}

extension RecipeDetailVC: AlertMessengerDelegate {
    func showAutoDismissingAlert(title: String?, message: String) {
        showAlertWithAutoDismiss(title: title, message: message)
    }
}
