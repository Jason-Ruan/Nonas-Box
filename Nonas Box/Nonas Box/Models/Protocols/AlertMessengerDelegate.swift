//
//  AlertMessengerDelegate.swift
//  Nonas Box
//
//  Created by Jason Ruan on 3/8/21.
//  Copyright © 2021 Jason Ruan. All rights reserved.
//

import Foundation

protocol AlertMessengerDelegate: AnyObject {
    func showAutoDismissingAlert(title: String?, message: String)
}

