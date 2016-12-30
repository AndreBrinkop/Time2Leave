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
        guard !input.isEmpty else {
            completionHandler([Location](), nil)
            return
        }
        
        let searchRadius: String = String(Int(Constants.locationAutocomplete.searchRadiusInKilometers * 1000.0))
        let searchLocation: String = "\(location.latitude),\(location.longitude)"
        let requestParameters = [
            parameterKeys.input : input,
            parameterKeys.apiKey : parameterValues.apiKey,
            parameterKeys.location : searchLocation,
            parameterKeys.radius : searchRadius,
            parameterKeys.language : Constants.apiConstants.language
        ]
        
        let url = GoogleApiHelper.buildUrl(method: methods.autocomplete, requestParameters: requestParameters, urlComponents: urlComponents)
        
        HTTPClient.getRequest(url: url, headerFields: nil) { data, error in
            let apiError = HTTPClient.createError(domain: "GooglePlacesClient", error: errorMessages.apiError)
            
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
            
            var locations = [Location]()
            
            // GUARD: Any results
            guard status != jsonResponseValues.noResultsStatus else {
                completionHandler(locations, nil)
                return
            }
            // GUARD: Response status ok
            guard status == jsonResponseValues.okStatus else {
                completionHandler(nil, apiError)
                return
            }
            guard let predictions = parsedData[jsonResponseKeys.predictions] as? [AnyObject] else {
                completionHandler(nil, apiError)
                return
            }
            
            for prediction in predictions {
                guard let description = prediction[jsonResponseKeys.description] as? String else {
                    completionHandler(nil, apiError)
                    return
                }
                guard let placeId = prediction[jsonResponseKeys.placeId] as? String else {
                    completionHandler(nil, apiError)
                    return
                }
                
                locations.append(Location(description: description, id: placeId))
            }
            completionHandler(locations, nil)
        }
    }
}
