//
//  TripDataViewController.swift
//  Time2Leave
//
//  Created by André Brinkop on 28.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import UIKit
import CoreLocation

class TripDataViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet var tripTypeSegmentedControl: UISegmentedControl!
    @IBOutlet var departureArrivalSegmentedControl: UISegmentedControl!
    @IBOutlet var tripDatePicker: UIDatePicker!
    @IBOutlet var currentPositionLabel: UILabel!
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tripDatePicker.minimumDate = Date()
        currentPositionLabel.text = TripDetails.destination!.description
    }
    
    // MARK: - Actions

    @IBAction func setTripDatePickerToSpecificTime(_ sender: UIButton) {
        var offsetFromCurrentTime: TimeInterval?
        
        switch sender.tag {
        case 0: // now
            offsetFromCurrentTime = 0.0
        case 1: // in 15 minutes
            offsetFromCurrentTime = 60.0 * 15.0
        case 2: // in 1 hour
            offsetFromCurrentTime = 60.0 * 60.0
        default:
            return
        }
        
        let newDate = Date().addingTimeInterval(offsetFromCurrentTime!)
        tripDatePicker.setDate(newDate, animated: true)
    }
    
    @IBAction func continueButtonClicked(_ sender: Any) {
        let tripType = tripTypeSegmentedControl.selectedSegmentIndex
        let tripDepartureArrival = departureArrivalSegmentedControl.selectedSegmentIndex
        let tripDate = tripDatePicker.date
        
        // TODO: Start route search
        print(tripType, tripDepartureArrival, tripDate)
    }
}
