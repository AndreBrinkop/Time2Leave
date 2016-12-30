//
//  TripDetails.swift
//  Time2Leave
//
//  Created by André Brinkop on 28.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation
import CoreLocation

struct TripDetails {
    private(set) static var originCoordinates: CLLocationCoordinate2D?
    private(set) static var destination: Location?
    
    private(set) static var route: Route?
    
    static func setOriginAndDestination(originCoordinates: CLLocationCoordinate2D, destination: Location) {
        TripDetails.originCoordinates = originCoordinates
        TripDetails.destination = destination
    }
    
    static func setRoute(_ route: Route) {
        TripDetails.route = route
    }
}
