//
//  GooglePlacesConstants.swift
//  Time2Leave
//
//  Created by André Brinkop on 25.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation

extension GooglePlacesClient {
    
    // MARK: URL Components
    
    struct urlComponents {
        static let scheme = "https"
        static let host = "maps.googleapis.com"
        static let path = "/maps/api/place/"
        static let output = "json"
    }
    
    // MARK: Methods
    
    struct methods {
        static let autocomplete = "autocomplete"
    }
    
    // MARK: ParameterKeys
    
    struct parameterKeys {
        static let apiKey = "key"
        static let input = "input"
        
        static let location = "location" // as latitude,longitude
        static let radius = "radius" // in meters
        static let language = "language" // e.g. en
    }
    
    // MARK: ParameterValues
    
    struct parameterValues {
        static let autocompleteMethod = "autocomplete"
        static let jsonOutput = "json"
        
        static let apiKey = Constants.apiKeys.google

    }
    
    // MARK: JSONResponseKeys
    
    struct jsonResponseKeys {
        static let status = "status"
        static let predictions = "predictions"
        
        static let description = "description"
        static let placeId = "place_id"
    }
    
    // MARK: JSONResponseValues
    
    struct jsonResponseValues {
        static let okStatus = "OK"
    }
    
    // MARK: Error Messages
    
    struct errorMessages {
        static let apiError = "An error occurred while using the GooglePlaces API."
    }

}
