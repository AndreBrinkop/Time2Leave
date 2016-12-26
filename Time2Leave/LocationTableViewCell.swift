//
//  LocationTableViewCell.swift
//  Time2Leave
//
//  Created by André Brinkop on 26.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {

    // MARK: Properties
    
    @IBOutlet private var locationLabel: UILabel!
    @IBOutlet private var favoriteButton: UIButton!
    
    private var location: Location?
    
    private var isFavorite: Bool {
        get {
            return favoriteButton.imageView?.image == #imageLiteral(resourceName: "filledStar")
        }
        set(newValue) {
            favoriteButton.setImage(newValue ? #imageLiteral(resourceName: "filledStar") : #imageLiteral(resourceName: "emptyStar"), for: .normal)
        }
    }
    
    // MARK: Configuration
    
    func setLocation(_ location: Location?) {
        guard let location = location else {
            locationLabel.text = ""
            return
        }
        
        self.location = location
        locationLabel.text = location.description
    }
    
    // MARK: Click Action

    @IBAction func favoriteButtonClicked(_ sender: UIButton) {
        isFavorite = !isFavorite
    }
}
