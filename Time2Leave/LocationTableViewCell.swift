//
//  LocationTableViewCell.swift
//  Time2Leave
//
//  Created by André Brinkop on 26.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import UIKit
import CoreData

class LocationTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet private var locationLabel: UILabel!
    @IBOutlet private var favoriteButton: UIButton!
    var destinationViewController: DestinationViewController!
    
    private(set) var location: Location!
    private let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var isFavorite: Bool {
        get {
            return favoriteButton.imageView?.image == #imageLiteral(resourceName: "filledStar")
        }
        set(newValue) {
            if newValue == isFavorite {
                return
            }
            favoriteButton.setImage(newValue ? #imageLiteral(resourceName: "filledStar") : #imageLiteral(resourceName: "emptyStar"), for: .normal)
        }
    }
    
    // MARK: - Configuration
    
    func setLocation(_ location: Location?, isFavorite: Bool = false) {
        guard let location = location else {
            locationLabel.text = ""
            return
        }
        
        self.location = location
        locationLabel.text = location.description
        self.isFavorite = isFavorite
    }
    
    // MARK: - IBActions

    @IBAction func favoriteButtonClicked(_ sender: Any) {
        destinationViewController.toggleFavorite(location: location)
    }
}
