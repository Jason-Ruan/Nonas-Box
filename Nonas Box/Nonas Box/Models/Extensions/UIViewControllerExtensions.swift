//
//  UIViewControllerExtensions.swift
//  Nonas Box
//
//  Created by Jason Ruan on 8/8/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

// MARK: - UIViewController Extensions
public extension UIViewController {
    
    // MARK: - Properties
    
    // MARK: - Functions
    func showAlert(message: String) {
        let ac = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(ac, animated: true, completion: nil)
    }
    
    func showAlertWithAction(title: String, message: String, withAction: UIAlertAction) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(withAction)
        present(ac, animated: true, completion: nil)
    }
    
    func showAlertWithAutoDismiss(title: String?, message: String?) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        present(ac, animated: true) {
            sleep(UInt32.min)
            ac.dismiss(animated: true, completion: nil)
        }
    }
    
    func showLoadingScreen(blockBackgroundViews: Bool) {
        view.addSubview(LoadingScreenView(frame: view.bounds, blockBackgroundViews: blockBackgroundViews))
    }
    
    func removeLoadingScreen() {
        for subview in view.subviews where subview is LoadingScreenView {
            subview.removeFromSuperview()
        }
    }
    
    func configureNavigationBarForTranslucence() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
}
