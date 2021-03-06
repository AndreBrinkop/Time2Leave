//
//  AppDelegate.swift
//  Time2Leave
//
//  Created by André Brinkop on 24.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        window?.tintColor = Color.defaultColor
    }

    func applicationWillTerminate(_ application: UIApplication) {
        saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "Time2Leave")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                self.showErrorMessage(title: "Could not load persistent Store", message: error.localizedDescription)
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                self.showErrorMessage(title: "Could not save data", message: nserror.localizedDescription)
            }
        }
    }
    
    // MARK: Show error message
    
    private var currentlyShowingError: Bool = false
    func showErrorMessage(title: String, message: String? = nil) {
        // Don't flood the user with error messages
        if currentlyShowingError {
            return
        }
        
        currentlyShowingError = true
        DispatchQueue.main.async {
            let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: {action in
                self.currentlyShowingError = false
            }))
            self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler( [.alert, .sound])
    }
    
}

