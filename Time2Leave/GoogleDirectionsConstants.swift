//
//  GoogleDirectionsConstants.swift
//  Time2Leave
//
//  Created by André Brinkop on 29.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation

extension GoogleDirectionsClient {
    
    // MARK: URL Components
    
    static let urlComponents = [
        GoogleApiHelper.urlComponents.scheme : "https",
        GoogleApiHelper.urlComponents.host : "maps.googleapis.com",
        GoogleApiHelper.urlComponents.path : "/maps/api/directions/",
        GoogleApiHelper.urlComponents.output : "json"
    ]
    
    // MARK: ParameterKeys
    
    struct parameterKeys {
        static let apiKey = "key"
        static let origin = "origin"
        static let destination = "destination"
        
        static let mode = "mode"
        static let arrivalTime = "arrival_time" // in sec since 01.01.1970 UTC
        static let departureTime = "departue_time" // in sec since 01.01.1970 UTC
        static let trafficModel = "traffic_model"
        
        static let language = "language" // e.g. en
        
    }
    
    // MARK: ParameterValues
    
    struct parameterValues {
        static let jsonOutput = "json"
        static let apiKey = Constants.apiKeys.google
        static let placeIdPrefix = "place_id:"
        
        static let trafficModelBestGuess = "best_guess"
    }
    
    // MARK: JSONResponseKeys
    
    struct jsonResponseKeys {
        static let status = "status"
    }
    
    // MARK: JSONResponseValues
    
    struct jsonResponseValues {
        static let okStatus = "OK"
        static let noResultsStatus = "ZERO_RESULTS"
    }
    
    // MARK: Error Messages
    
    struct errorMessages {
        static let apiError = "An error occurred while using the GoogleDirections API."
    }
    
}
