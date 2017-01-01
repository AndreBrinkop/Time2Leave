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
    
    public static func findRoutes(tripDetails: TripDetails, completionHandler: @escaping (_ routes: [Route]?, _ error: Error?) -> Void) {
        let origin = tripDetails.originCoordinatesString!
        let destination = parameterValues.placeIdPrefix + tripDetails.destination!.id
        let mode = tripDetails.tripType!.rawValue
        let time = Int(tripDetails.tripTime!.timeIntervalSince1970)
        
        var parameterKeysTime = parameterKeys.departureTime

        // only use arrival time if the trip type is subway (api specification)
        if tripDetails.tripDepartureArrivalType! == .arrival && tripDetails.tripType! == .subway {
            parameterKeysTime = parameterKeys.arrivalTime
        }
        
        let requestParameters = [
            parameterKeys.origin : origin,
            parameterKeys.destination : destination,
            parameterKeys.alternatives : parameterValues.returnAlternatives,
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
            
            completionHandler(parseRoutesArray(routesArray, tripDetails: tripDetails), nil)
        }
    }
    
    private static func parseRoutesArray(_ routesArray: [AnyObject], tripDetails: TripDetails) -> [Route] {
        var routes = [Route]()

        for route in routesArray {
            guard let routeObject = route as? [String : AnyObject] else {
                break
            }
            guard let summary = routeObject[jsonResponseKeys.summary] as? String else {
                break
            }
            guard let copyrights = routeObject[jsonResponseKeys.copyrights] as? String else {
                break
            }
            guard let warnings = routeObject[jsonResponseKeys.warnings] as? [String] else {
                break
            }
            guard let bounds = routeObject[jsonResponseKeys.bounds] as? [String : AnyObject],
                let northeastBoundObject = bounds[jsonResponseKeys.northeastBound] as? [String : AnyObject],
                let northeastBoundLat = northeastBoundObject[jsonResponseKeys.latitude] as? Double,
                let northeastBoundLong = northeastBoundObject[jsonResponseKeys.longitude] as? Double,
                let southwestBoundObject = bounds[jsonResponseKeys.southwestBound] as? [String : AnyObject],
                let southwestBoundLat = southwestBoundObject[jsonResponseKeys.latitude] as? Double,
                let southwestBoundLong = southwestBoundObject[jsonResponseKeys.longitude] as? Double else {
                    break
            }
            
            let northeastBound = CLLocationCoordinate2D(latitude: northeastBoundLat, longitude: northeastBoundLong)
            let southwestBound = CLLocationCoordinate2D(latitude: southwestBoundLat, longitude: southwestBoundLong)
            
            guard let overview = routeObject[jsonResponseKeys.overview] as? [String : AnyObject],
                let polyline = overview[jsonResponseKeys.polyline] as? String,
                let polylineCoordinates = Polyline.init(encodedPolyline: polyline).coordinates else {
                    break
            }
            guard let leg = (routeObject[jsonResponseKeys.legs] as? [AnyObject])?.first,
                let durationObject = leg[jsonResponseKeys.duration] as? [String : AnyObject],
                let durationValue = durationObject[jsonResponseKeys.value] as? Int else {
                    break
            }
            
            let routeTimes: RouteTimes?
            let polylineBounds = createCoordinateRegion(firstBound: northeastBound, secondBound: southwestBound)
            
            if tripDetails.tripType! == .subway {
                guard let departureTimeObject = leg[jsonResponseKeys.departureTime] as? [String : AnyObject],
                    let departureTimeStamp = departureTimeObject[jsonResponseKeys.value] as? Int else {
                        break
                }
                guard let arrivalTimeObject = leg[jsonResponseKeys.arrivalTime] as? [String : AnyObject],
                    let arrivalTimeStamp = arrivalTimeObject[jsonResponseKeys.value] as? Int else {
                        break
                }
                
                let timeIntervalFromGMT = TimeInterval(NSTimeZone.local.secondsFromGMT())
                let departureTime = Date(timeIntervalSince1970: TimeInterval(departureTimeStamp)).addingTimeInterval(timeIntervalFromGMT)
                let arrivalTime = Date(timeIntervalSince1970: TimeInterval(arrivalTimeStamp)).addingTimeInterval(timeIntervalFromGMT)

                routeTimes = RouteTimes(departureTime: departureTime, arrivalTime: arrivalTime, travelTimeInSeconds: durationValue)
            } else {
                routeTimes = RouteTimes(time: tripDetails.tripTime!, tripDepartureArrivalType: tripDetails.tripDepartureArrivalType!, travelTimeInSeconds: durationValue)
            }
                 routes.append(Route(summary: summary, copyrights: copyrights, warning: warnings, times: routeTimes!, polylineCoordinates: polylineCoordinates, polylineBounds: polylineBounds))
        }
        
        return routes
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
