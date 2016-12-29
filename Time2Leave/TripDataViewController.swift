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

    @IBOutlet var tripTypeSegmentedControl: UISegmentedControl!
    @IBOutlet var tripDatePicker: UIDatePicker!
    @IBOutlet var currentPositionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(TripDetails.destination!, TripDetails.originCoordinates!)
    }

}
