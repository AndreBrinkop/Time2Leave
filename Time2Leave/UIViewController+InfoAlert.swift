//
//  UIViewController+InfoAlert.swift
//  Time2Leave
//
//  Created by André Brinkop on 14.01.17.
//  Copyright © 2017 André Brinkop. All rights reserved.
//

import UIKit

extension UIViewController {
    
    public func displayInfoAlert(title: String, message: String) {
        let notificationsNotAvailableAlert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        notificationsNotAvailableAlert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        
        DispatchQueue.main.async {
            self.present(notificationsNotAvailableAlert, animated: true)
        }
    }
    
}
