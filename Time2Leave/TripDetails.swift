//
//  TripDetails.swift
//  Time2Leave
//
//  Created by André Brinkop on 28.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreData
import Polyline
import MapKit

class TripDetails {
    
    private init() {
        loadTripDetails()
    }
    
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
    private(set) var selectedRoute: Route?
    
    private(set) var reminderInformationText: String?
    private(set) var reminderDate: Date?
    
    // MARK: - Shared Instance
    
    static var shared: TripDetails {
        get {
            struct Singleton {
                static var sharedInstance = TripDetails()
            }
            return Singleton.sharedInstance
        }
    }
    
    // MARK: - Model Setters
    
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
    
    func setSelectedRoute(_ route: Route) {
        self.selectedRoute = route
    }
    
    func setReminder(reminderDate: Date, reminderInformationText: String) {
        self.reminderDate = reminderDate
        self.reminderInformationText = reminderInformationText
    }
    
    func clearReminder() {
        self.reminderDate = nil
        self.reminderInformationText = nil
    }
    
    // MARK: - Persistent Saving
    
    func saveTripDetails() {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let _ = SavedTripDetails(context: context, tripDetails: self)
        appDelegate.saveContext()
    }
    
    func loadTripDetails() {
        guard let savedTripDetails = getSavedTripDetails() else {
            return
        }
        
        setTripDetails(loadedTripDetails: savedTripDetails)
    }
    
    func deleteTripDetails() {
        guard let savedTripDetails = getSavedTripDetails() else {
            return
        }
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        context.delete(savedTripDetails)
        appDelegate.saveContext()
    }
    
    private func getSavedTripDetails() -> SavedTripDetails? {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return nil
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<SavedTripDetails> = SavedTripDetails.fetchRequest()
        
        do {
            guard let loadedTripDetails = (try context.fetch(request)).first else {
                return nil
            }
            return loadedTripDetails
        } catch {
            return nil
        }
    }
    
    func setTripDetails(loadedTripDetails: SavedTripDetails) {
        let originCoordinates = CLLocationCoordinate2D(latitude: loadedTripDetails.originLatitude, longitude: loadedTripDetails.originLongitude)
        let destination = Location(description: loadedTripDetails.destinationDescription!, id: loadedTripDetails.destinationId!)
        setOriginAndDestination(originCoordinates: originCoordinates, destination: destination)
        
        tripType = TripType(rawValue: loadedTripDetails.tripType!)
        
        let routeTimes = RouteTimes(departureTime: loadedTripDetails.routeTimesDeparture as! Date, arrivalTime: loadedTripDetails.routeTimesArrival as! Date)
        let polylineCoordinates = Polyline.init(encodedPolyline: loadedTripDetails.routePolylineString!).coordinates!
        
        let polylineBoundsCenterCoordinate = CLLocationCoordinate2D(latitude: loadedTripDetails.routePolylineBoundsCenterLatitude, longitude: loadedTripDetails.routePolylineBoundsCenterLongitude)
        let polylineBoundsCenterCoordinateSpan = MKCoordinateSpan(latitudeDelta: loadedTripDetails.routePolylineBoundsSpanLatitudeDelta, longitudeDelta: loadedTripDetails.routePolylineBoundsSpanLongitudeDelta)
        let polylineBounds = MKCoordinateRegion(center: polylineBoundsCenterCoordinate, span: polylineBoundsCenterCoordinateSpan)
        
        let route = Route(summary: loadedTripDetails.routeSummary!, copyrights: loadedTripDetails.routeCopyrights, warnings: loadedTripDetails.routeWarnings as! [String]?, times: routeTimes, polylineCoordinates: polylineCoordinates, polylineBounds: polylineBounds)
        
        setSelectedRoute(route)
        setReminder(reminderDate: loadedTripDetails.reminderDate as! Date, reminderInformationText: loadedTripDetails.reminderInformationText!)
    }
}
