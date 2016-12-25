//
//  Constants.swift
//  Time2Leave
//
//  Created by André Brinkop on 25.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    
    // MARK: Location Autocomplete
    
    struct locationAutocomplete {
        static let language = "en"
        static let searchRadiusInKilometers = 150.0
    }
    
    // MARK: API Keys
    
    static let apiKeyPlistName = "ApiKeys"
    
    private struct apiKeyNames {
        static let google = "GOOGLE_API_KEY"
    }
    
    struct apiKeys {
        static let google = getAPIKey(apiKeyNames.google)
    }
}
