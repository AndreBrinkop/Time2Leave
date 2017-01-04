//
//  RouteDetailViewController.swift
//  Time2Leave
//
//  Created by André Brinkop on 03.01.17.
//  Copyright © 2017 André Brinkop. All rights reserved.
//

import UIKit
import MapKit

class RouteDetailViewController: RouteMapViewController {

    // MARK: - IBOutlets
    
    @IBOutlet var tripTypeImageView: UIImageView!
    @IBOutlet var destinationLabel: UILabel!
    
    @IBOutlet var routeSummaryLabel: UILabel!
    @IBOutlet var departureTimeLabel: UILabel!
    @IBOutlet var arrivalTimeLabel: UILabel!
    @IBOutlet var tripDurationLabel: UILabel!
    @IBOutlet var routeWarningsLabel: UILabel!
    @IBOutlet var routeCopyrightLabel: UILabel!
    
    @IBOutlet var reminderDatePicker: UIDatePicker!
    
    // MARK: - Properties
    
    var route: Route {
        return TripDetails.shared.selectedRoute!
    }
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reminderDatePicker.minimumDate = Date()
        initializeUI()
    }
    
    private func initializeUI() {
        tripTypeImageView.image = TripDetails.shared.tripType?.image
        destinationLabel.text = TripDetails.shared.destination!.description
        
        showRouteOnMap(route)
        routeSummaryLabel.text = route.summary
        
        let timeStrings = route.times.humanReadable
        departureTimeLabel.text = timeStrings.0
        arrivalTimeLabel.text = timeStrings.1
        tripDurationLabel.text = timeStrings.2
        
        routeWarningsLabel.text = route.warningsString
        routeCopyrightLabel.text = route.copyrights
    }
    
    @IBAction func setReminderDatePickerToSpecificTime(_ sender: UIButton) {
        var absOffsetFromDepartureTime: TimeInterval?
        
        switch sender.tag {
        case 0: // 5min before
            absOffsetFromDepartureTime = 60.0 * 5.0
        case 1: // 15min before
            absOffsetFromDepartureTime = 60.0 * 15.0
        case 2: // 30min before
            absOffsetFromDepartureTime = 60.0 * 30.0
        default:
            return
        }
        
        let newDate = route.times.departureTime.addingTimeInterval(-absOffsetFromDepartureTime!)
        reminderDatePicker.setDate(newDate, animated: true)
    }
}
