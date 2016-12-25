//
//  GooglePlacesClient.swift
//  Time2Leave
//
//  Created by André Brinkop on 25.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation
import CoreLocation

class GooglePlacesClient {
    
    public static func autocomplete(input: String, location: CLLocationCoordinate2D, completionHandler: @escaping (_ locations: [Location]?, _ error: Error?) -> Void) {
        
        let searchRadius: String = String(Int(Constants.locationAutocomplete.searchRadiusInKilometers * 1000.0))
        
        let searchLocation: String = "\(location.latitude),\(location.longitude)"
        
        let requestParameters = [
            parameterKeys.input : input,
            parameterKeys.apiKey : parameterValues.apiKey,
            parameterKeys.location : searchLocation,
            parameterKeys.radius : searchRadius,
            parameterKeys.language : Constants.locationAutocomplete.language
        ]
        
        let url = buildUrl(method: methods.autocomplete, requestParameters: requestParameters)
        
        HTTPClient.getRequest(url: url, headerFields: nil) { data, error in
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
            
            // GUARD: Response status
            guard let status = parsedData[jsonResponseKeys.status] as? String, status == jsonResponseValues.okStatus else {
                completionHandler(nil, HTTPClient.createError(domain: "GooglePlacesClient", error: errorMessages.apiError))
                return
            }
            
            guard let predictions = parsedData[jsonResponseKeys.predictions] as? [AnyObject] else {
                completionHandler(nil, HTTPClient.createError(domain: "GooglePlacesClient", error: errorMessages.apiError))
                return
            }
            
            var locations = [Location]()
            
            for prediction in predictions {

                guard let description = prediction[jsonResponseKeys.description] as? String else {
                    completionHandler(nil, HTTPClient.createError(domain: "GooglePlacesClient", error: errorMessages.apiError))
                    return
                }
                
                guard let placeId = prediction[jsonResponseKeys.placeId] as? String else {
                    completionHandler(nil, HTTPClient.createError(domain: "GooglePlacesClient", error: errorMessages.apiError))
                    return
                }
                
                locations.append(Location(description: description, id: placeId))
            }
            
            completionHandler(locations, nil)
        }
    }
    
    private static func buildUrl(method: String, requestParameters: [String : Any]) -> URL {
        var components = URLComponents()
        components.scheme = urlComponents.scheme
        components.host = urlComponents.host
        
        let path = String(format: "%@%@/%@", urlComponents.path, method, urlComponents.output)
        components.path = path
        
        components.queryItems = [URLQueryItem]()
        for (name, value) in requestParameters {
            components.queryItems?.append(URLQueryItem(name: name, value: "\(value)"))
        }
        
        return components.url!
    }
}
