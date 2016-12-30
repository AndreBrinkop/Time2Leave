//
//  GoogleDirectionsClient.swift
//  Time2Leave
//
//  Created by André Brinkop on 29.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation
import CoreLocation
import Polyline

class GoogleDirectionsClient {
    
    public static func findRoutes( completionHandler: @escaping (_ route: Route?, _ error: Error?) -> Void) {
        
        // TODO: Dummy data
        let origin = "53.540295,9.996468"
        let destination = parameterValues.placeIdPrefix + "ChIJEbr9hmNwsEcR4FyslG2sJQQ"
        let mode = "driving"
        let departureTime = Int(Date().timeIntervalSince1970)
        
        let requestParameters = [
            parameterKeys.origin : origin,
            parameterKeys.destination : destination,
            parameterKeys.apiKey : parameterValues.apiKey,
            parameterKeys.mode : mode,
            parameterKeys.language : Constants.apiConstants.language,
            //parameterKeys.arrivalTime,
            parameterKeys.departureTime : departureTime,
            parameterKeys.trafficModel : parameterValues.trafficModelBestGuess
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
            let northeastBound = bounds[jsonResponseKeys.northeastBound] as? [String : AnyObject],
            let northeastBoundLat = northeastBound[jsonResponseKeys.latitude] as? Double,
            let northeastBoundLong = northeastBound[jsonResponseKeys.longitude] as? Double,
            let southwestBound = bounds[jsonResponseKeys.southwestBound] as? [String : AnyObject],
            let southwestBoundLat = southwestBound[jsonResponseKeys.latitude] as? Double,
            let southwestBoundLong = southwestBound[jsonResponseKeys.longitude] as? Double
            else {
                return nil
        }
        
        // TODO: Use Bounds
        print(northeastBoundLat, northeastBoundLong, southwestBoundLat, southwestBoundLong)
        
        // TODO: Parse and Calculate Departure and Arrival Time
        
        guard let overview = route[jsonResponseKeys.overview] as? [String : AnyObject],
            let polyline = overview[jsonResponseKeys.polyline] as? String,
            let polylineCoordinates = Polyline.init(encodedPolyline: polyline).coordinates
            else {
                return nil
        }
        
        return Route(summary: summary, copyrights: copyrights, warning: warnings, polylineCoordinates: polylineCoordinates, polylineBounds: nil)
    }
}
