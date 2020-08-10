//
//  UIViewControllerExtensions.swift
//  Nonas Box
//
//  Created by Jason Ruan on 8/8/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

//MARK: - UIViewController Extensions

public extension UIViewController {
    
    func showAlert(message: String) {
        let ac = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(ac, animated: true, completion: nil)
    }
    
}
