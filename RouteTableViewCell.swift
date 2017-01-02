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
        
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.none
        formatter.timeStyle = .short
        
        let times = route.times
        departureTimeLabel.text = formatter.string(from: times.departureTime)
        arrivalTimeLabel.text = formatter.string(from: times.arrivalTime)
        
        durationLabel.text = times.travelTimeHumanReadable
        summaryLabel.text = route.summary
    }
}
