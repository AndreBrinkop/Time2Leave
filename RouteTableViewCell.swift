//
//  RouteTableViewCell.swift
//  Time2Leave
//
//  Created by André Brinkop on 02.01.17.
//  Copyright © 2017 André Brinkop. All rights reserved.
//

import UIKit

class RouteTableViewCell: UITableViewCell {

    @IBOutlet var departureTimeLabel: UILabel!
    @IBOutlet var arrivalTimeLabel: UILabel!
    @IBOutlet var summaryLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    
    private(set) var route: Route?
    
    func initialize(route: Route) {
        self.route = route
        
        let timeStrings = route.times.humanReadable
        departureTimeLabel.text = timeStrings.0
        arrivalTimeLabel.text = timeStrings.1
        durationLabel.text = timeStrings.2
        
        summaryLabel.text = route.summary
    }
}
