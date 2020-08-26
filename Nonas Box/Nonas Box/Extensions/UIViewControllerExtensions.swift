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
    
    func showAlertWithAction(title: String, message: String, withAction: UIAlertAction) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(withAction)
        present(ac, animated: true, completion: nil)
    }
    
}
