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
    @IBOutlet var datePickerButtons: [CustomButton]!
    
    @IBOutlet var reminderNotAvailableContainer: UIView!
    @IBOutlet var reminderNotAvailableLabel: UILabel!
    
    // MARK: - Properties
    
    var route: Route {
        return TripDetails.shared.selectedRoute!
    }
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        reminderDatePicker.minimumDate = Date().addingTimeInterval(60.0)
        reminderDatePicker.maximumDate = route.times.departureTime
        
        // Set Date Picker Buttons Enabled State
        for datePickerButton in datePickerButtons {
            guard let timeOffset = getTimeOffsetForDatePickerButton(button: datePickerButton) else {
                break
            }
            
            if Date() >= route.times.departureTime.addingTimeInterval(-timeOffset) {
                datePickerButton.isEnabled = false
            }
        }
        
        initializeReminderNotAvailableView()
    }
    
    private func initializeReminderNotAvailableView() {
        if reminderDatePicker.minimumDate!.addingTimeInterval(Constants.userInterface.secondsToDepartureForReminderToBecomeAvailable) >= reminderDatePicker.maximumDate! {
            reminderNotAvailableContainer.isHidden = false
            reminderNotAvailableLabel.text = "To set a reminder the current time must be at least \(Int(Constants.userInterface.secondsToDepartureForReminderToBecomeAvailable / 60.0)) minutes before the departure time"
        }
    }
    
    // MARK: - Actions
    
    @IBAction func setReminderDatePickerToSpecificTime(_ sender: UIButton) {
        guard let absOffsetFromDepartureTime = getTimeOffsetForDatePickerButton(button: sender) else {
            return
        }
        
        let newDate = route.times.departureTime.addingTimeInterval(-absOffsetFromDepartureTime)
        reminderDatePicker.setDate(newDate, animated: true)
    }
    
    @IBAction func setReminderButtonClicked(_ sender: CustomButton) {
        // TODO
    }
    
    @IBAction func displayDirectionsInGoogleMaps(_ sender: Any) {
        GoogleDirectionsClient.displayDirectionsInGoogleMaps(originCoordinatesString: TripDetails.shared.originCoordinatesString!, destination: TripDetails.shared.destination!, tripType: TripDetails.shared.tripType!)
    }
    
    // MARK: - Helper methods
    
    private func getTimeOffsetForDatePickerButton(button: UIButton) -> TimeInterval? {
        switch button.tag {
        case 0: // 5min before
            return 60.0 * 5.0
        case 1: // 15min before
            return 60.0 * 15.0
        case 2: // 30min before
            return 60.0 * 30.0
        default:
            return nil
        }
    }
}
