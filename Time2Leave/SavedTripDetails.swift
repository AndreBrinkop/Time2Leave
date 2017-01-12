//
//  SavedTripDetails.swift
//  Time2Leave
//
//  Created by André Brinkop on 10.01.17.
//  Copyright © 2017 André Brinkop. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension SavedTripDetails {
    
    // MARK: - Properties
    
    var appDelegate: AppDelegate {
        get {
            return UIApplication.shared.delegate as! AppDelegate
        }
    }
    /*
    var location: Location! {
        return Location(description: locationDescription!, id: locationId!)
    }*/
    
    // MARK: - Initialization
    
    convenience init(context: NSManagedObjectContext, tripDetails: TripDetails) {
        guard let entity = NSEntityDescription.entity(forEntityName: "SavedTripDetails", in: context) else {
            fatalError("Unable to find Entity name!")
        }
        
        self.init(entity: entity, insertInto: context)
        
        destinationDescription = tripDetails.destination?.description
        destinationId = tripDetails.destination?.id
        
        originLatitude = tripDetails.originCoordinates!.latitude
        originLongitude = tripDetails.originCoordinates!.longitude
        
        // Selected Route
        let route = tripDetails.selectedRoute!
        routeCopyrights = route.copyrights
        routePolylineBoundsCenterLatitude = route.polylineBounds.center.latitude
        routePolylineBoundsCenterLongitude = route.polylineBounds.center.longitude
        routePolylineBoundsSpanLatitudeDelta = route.polylineBounds.span.latitudeDelta
        routePolylineBoundsSpanLongitudeDelta = route.polylineBounds.span.longitudeDelta
        routePolylineString = route.polylineString
        routeSummary = route.summary
        routeTimesArrival = route.times.arrivalTime as NSDate?
        routeTimesDeparture = route.times.departureTime as NSDate?
        routeWarnings = route.warnings as NSObject?
        
        tripType = tripDetails.tripType?.rawValue
        
        reminderDate = tripDetails.reminderDate as NSDate?
        
        appDelegate.saveContext()
    }
    
    // MARK: - Deletion
    
    public func delete(context: NSManagedObjectContext) {
        context.delete(self)
        appDelegate.saveContext()
    }
    
}
