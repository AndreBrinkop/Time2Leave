//
//  GoogleDirectionsClient.swift
//  Time2Leave
//
//  Created by André Brinkop on 29.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation
import CoreLocation

class GoogleDirectionsClient {
    
    public static func findRoutes( completionHandler: @escaping (_ routes: [Any]?, _ error: Error?) -> Void) {
        
        // TODO: Dummy data
        let origin = "53.540295,9.996468"
        let destination = parameterValues.placeIdPrefix + "ChIJEbr9hmNwsEcR4FyslG2sJQQ"
        
        let requestParameters = [
            parameterKeys.origin : origin,
            parameterKeys.destination : destination,
            parameterKeys.apiKey : parameterValues.apiKey,
            parameterKeys.mode : "driving",
            parameterKeys.language : Constants.apiConstants.language,
            //parameterKeys.arrivalTime,
            //parameterKeys.departureTime
            //parameterKeys.trafficModel : parameterValues.trafficModelBestGuess
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
            
            let routes = [Any]()
            
            // GUARD: Any results
            guard status != jsonResponseValues.noResultsStatus else {
                completionHandler(routes, nil)
                return
            }
            
            // GUARD: Response status ok
            guard status == jsonResponseValues.okStatus else {
                completionHandler(nil, apiError)
                return
            }
            
            // TODO: Use parsed respone
        }
    }
}
