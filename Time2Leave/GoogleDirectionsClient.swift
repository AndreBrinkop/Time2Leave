//
//  GoogleDirectionsClient.swift
//  Time2Leave
//
//  Created by André Brinkop on 29.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import Polyline

class GoogleDirectionsClient {
    
    public static func findRoutes(tripDetails: TripDetails, completionHandler: @escaping (_ route: Route?, _ error: Error?) -> Void) {
        let origin = tripDetails.originCoordinatesString!
        let destination = parameterValues.placeIdPrefix + tripDetails.destination!.id
        let mode = tripDetails.tripType!.rawValue
        let time = Int(tripDetails.tripTime!.timeIntervalSince1970)
        
        var parameterKeysTime = parameterKeys.arrivalTime

        if tripDetails.tripDepartureArrivalType! == .departure {
            parameterKeysTime = parameterKeys.departureTime
        }
        
        let requestParameters = [
            parameterKeys.origin : origin,
            parameterKeys.destination : destination,
            parameterKeys.apiKey : parameterValues.apiKey,
            parameterKeys.mode : mode,
            parameterKeys.language : Constants.apiConstants.language,
            parameterKeysTime : time,
        ] as [String : Any]
        
        let url = GoogleApiHelper.buildUrl(requestParameters: requestParameters, urlComponents: urlComponents)
        
        HTTPClient.getRequest(url: url, headerFields: nil) { data, error in
            let apiError = HTTPClient.createError(domain: "GoogleDirectionsClient", error: errorMessages.apiError)
            
            // GUARD: Network error
            guard let data = data, error == nil else {
                completionHandler(nil, error)
                return
            }
            
            let parsedResult = HTTPClient.parseData(data: data)
            
            // GUARD: Parsing error
            guard let parsedData = parsedResult.parsedData, parsedResult.error == nil else {
                completionHandler(nil, parsedResult.error)
                return
            }
                        
            guard let status = parsedData[jsonResponseKeys.status] as? String else {
                completionHandler(nil, apiError)
                return
            }
            
            // GUARD: Any results
            guard status != jsonResponseValues.noResultsStatus else {
                completionHandler(nil, nil)
                return
            }
            
            // GUARD: Response status ok
            guard status == jsonResponseValues.okStatus else {
                completionHandler(nil, apiError)
                return
            }
            
            guard let routesArray = parsedData[jsonResponseKeys.routes] as? [AnyObject] else {
                completionHandler(nil, apiError)
                return
            }
            
            guard let route = parseRoutesArray(routesArray) else {
                completionHandler(nil, apiError)
                return
            }
            
            completionHandler(route, nil)
        }
    }
    
    private static func parseRoutesArray(_ routesArray: [AnyObject]) -> Route? {
        // TODO: Consider using alternative routes
        let route = routesArray.first as! [String : AnyObject]
        
        guard let summary = route[jsonResponseKeys.summary] as? String else {
            return nil
        }
        
        guard let copyrights = route[jsonResponseKeys.copyrights] as? String else {
            return nil
        }
        
        guard let warnings = route[jsonResponseKeys.warnings] as? [String] else {
            return nil
        }
        
        guard let bounds = route[jsonResponseKeys.bounds] as? [String : AnyObject],
            let northeastBoundObject = bounds[jsonResponseKeys.northeastBound] as? [String : AnyObject],
            let northeastBoundLat = northeastBoundObject[jsonResponseKeys.latitude] as? Double,
            let northeastBoundLong = northeastBoundObject[jsonResponseKeys.longitude] as? Double,
            let southwestBoundObject = bounds[jsonResponseKeys.southwestBound] as? [String : AnyObject],
            let southwestBoundLat = southwestBoundObject[jsonResponseKeys.latitude] as? Double,
            let southwestBoundLong = southwestBoundObject[jsonResponseKeys.longitude] as? Double
            else {
                return nil
        }
        
        let northeastBound = CLLocationCoordinate2D(latitude: northeastBoundLat, longitude: northeastBoundLong)
        let southwestBound = CLLocationCoordinate2D(latitude: southwestBoundLat, longitude: southwestBoundLong)

        guard let overview = route[jsonResponseKeys.overview] as? [String : AnyObject],
            let polyline = overview[jsonResponseKeys.polyline] as? String,
            let polylineCoordinates = Polyline.init(encodedPolyline: polyline).coordinates
            else {
                return nil
        }
        
        // TODO: Parse and Calculate Departure and Arrival Time
        
        let polylineBounds = createCoordinateRegion(firstBound: northeastBound, secondBound: southwestBound)
        return Route(summary: summary, copyrights: copyrights, warning: warnings, polylineCoordinates: polylineCoordinates, polylineBounds: polylineBounds)
    }
    
    // MARK: - Helper methods
    
    private static func createCoordinateRegion(firstBound: CLLocationCoordinate2D, secondBound: CLLocationCoordinate2D) -> MKCoordinateRegion {
        let centerLat = (secondBound.latitude - firstBound.latitude) / 2.0 + firstBound.latitude
        let centerLong = (secondBound.longitude - firstBound.longitude) / 2.0 + firstBound.longitude
        let center = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLong)
        
        let deltaLat = abs(firstBound.latitude - secondBound.latitude) * Constants.userInterface.mapRegionSpanFactor
        let deltaLong = abs(firstBound.longitude - secondBound.longitude) * Constants.userInterface.mapRegionSpanFactor
        let span = MKCoordinateSpan(latitudeDelta: deltaLat, longitudeDelta: deltaLong)
        
        return MKCoordinateRegion(center: center, span: span)
    }
}
