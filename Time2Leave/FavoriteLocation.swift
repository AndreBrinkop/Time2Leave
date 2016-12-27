//
//  FavoriteLocation.swift
//  Time2Leave
//
//  Created by André Brinkop on 26.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension FavoriteLocation {
    
    // MARK: Properties
    
    var appDelegate: AppDelegate {
        get {
            return UIApplication.shared.delegate as! AppDelegate
        }
    }
    
    var location: Location! {
        return Location(description: locationDescription!, id: locationId!)
    }
    
    // MARK: Initialization
    
    convenience init(context: NSManagedObjectContext, location: Location) {
        guard let entity = NSEntityDescription.entity(forEntityName: "FavoriteLocation", in: context) else {
            fatalError("Unable to find Entity name!")
        }
        
        self.init(entity: entity, insertInto: context)
        
        locationDescription = location.description
        locationId = location.id
        
        appDelegate.saveContext()
    }
    
    // MARK: Deletion
    
    public func delete(context: NSManagedObjectContext) {
        context.delete(self)
        appDelegate.saveContext()
    }
    
}
