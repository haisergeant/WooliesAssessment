//
//  AlertShowable.swift
//
//  Created by Hai Le Thanh.
//  Copyright © 2020 Hai Le Thanh. All rights reserved.
//
	

import UIKit

protocol AlertShowable {
    func showAlert(title: String,
                   message: String,
                   primaryButtonTitle: String,
                   primaryAction: @escaping (() -> Void),
                   secondaryButtonTitle: String?,
                   secondaryAction: (() -> Void)?)
}

extension UIViewController: AlertShowable {
    func showAlert(title: String,
                   message: String,
                   primaryButtonTitle: String,
                   primaryAction: @escaping (() -> Void),
                   secondaryButtonTitle: String? = nil,
                   secondaryAction: (() -> Void)? = nil) {
        
        let alertController = UIAlertController(title: "Error",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: primaryButtonTitle,
                                                style: .default) { (action) in
                                                    primaryAction()
        })
        if let secondaryButtonTitle = secondaryButtonTitle {
            alertController.addAction(UIAlertAction(title: secondaryButtonTitle,
                                                    style: .default) { (action) in
                                                        secondaryAction?()
            })
        }
        present(alertController, animated: true, completion: nil)
    }
}
