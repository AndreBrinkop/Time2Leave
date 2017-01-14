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
    @IBOutlet var continueButton: CustomButton!
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tripDatePicker.minimumDate = Date()
        currentPositionLabel.text = TripDetails.shared.destination!.description
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
        let tripType = getTripType(index: tripTypeSegmentedControl.selectedSegmentIndex)
        let tripDepartureArrivalType = TripDepartureArrivalType(rawValue: departureArrivalSegmentedControl.selectedSegmentIndex)!
        let tripTime = max(tripDatePicker.date, Date())
        TripDetails.shared.setTripTypeAndTimeInformation(tripType: tripType, tripDepartureArrivalType: tripDepartureArrivalType, tripTime: tripTime)
        
        continueButton.startSpinning()
        navigationItem.setHidesBackButton(true, animated: true)
        
        GoogleDirectionsClient.findRoutes(tripDetails: TripDetails.shared) { routes, error in
            self.continueButton.stopSpinning()
            self.navigationItem.setHidesBackButton(false, animated: true)
            
            let noRoutesFoundTitle = "No Search Result Found"
            guard let routes = routes, error == nil else {
                self.displayInfoAlert(title: noRoutesFoundTitle, message: error!.localizedDescription)
                return
            }

            guard !routes.isEmpty else {
                self.displayInfoAlert(title: noRoutesFoundTitle, message: "Please adjust your search parameters!")
                return
            }
            
            TripDetails.shared.setRoutes(routes)
            
            guard routes.count > 1 else {
                // Skip RoutesView
                let routeDetailViewController = self.storyboard!.instantiateViewController(withIdentifier: "RouteDetailViewController")
                TripDetails.shared.setSelectedRoute(routes.first!)
                self.navigationController?.pushViewController(routeDetailViewController, animated: true)
                return
            }

            self.performSegue(withIdentifier: "showRoutes", sender: self)
        }
    }
    
    // MARK: - Helper Methods
    
    private func getTripType(index: Int) -> TripType {
        switch index {
        case 0:
            return TripType.car
        case 1:
            return TripType.subway
        case 2:
            return TripType.bike
        case 3:
            return TripType.walk
        default:
            return TripType.car
        }
    }
}
