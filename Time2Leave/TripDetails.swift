//
//  TripDetails.swift
//  Time2Leave
//
//  Created by André Brinkop on 28.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation
import CoreLocation

class TripDetails {
    
    private init() { }
    
    // MARK: - Properties
    
    private(set) var originCoordinates: CLLocationCoordinate2D?
    var originCoordinatesString: String? {
        if originCoordinates == nil { return nil }
        return "\(originCoordinates!.latitude),\(originCoordinates!.longitude)"
    }
    
    private(set) var destination: Location?
    
    private(set) var tripType: TripType?
    private(set) var tripDepartureArrivalType: TripDepartureArrivalType?
    private(set) var tripTime: Date?
    
    private(set) var routes: [Route]?
    
    // MARK: Shared Instance
    
    static var shared: TripDetails {
        get {
            struct Singleton {
                static var sharedInstance = TripDetails()
            }
            return Singleton.sharedInstance
        }
    }
    
    func setOriginAndDestination(originCoordinates: CLLocationCoordinate2D, destination: Location) {
        self.originCoordinates = originCoordinates
        self.destination = destination
    }
    
    func setTripTypeAndTimeInformation(tripType: TripType, tripDepartureArrivalType: TripDepartureArrivalType, tripTime: Date) {
        self.tripType = tripType
        self.tripDepartureArrivalType = tripDepartureArrivalType
        self.tripTime = tripTime
    }
    
    func setRoutes(_ routes: [Route]) {
        self.routes = routes
    }
}
