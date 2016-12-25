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
    
    public static func autocomplete(input: String, location: CLLocationCoordinate2D, completionHandler: @escaping (_ locations: [String]?, _ error: Error?) -> Void) {
        
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
            guard let data = data, error == nil else {
                completionHandler(nil, error)
                return
            }
            
            let parsedResult = HTTPClient.parseData(data: data)
            
            print(parsedResult.parsedData!)
            // TODO: Use parsed Data to extract locations
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
