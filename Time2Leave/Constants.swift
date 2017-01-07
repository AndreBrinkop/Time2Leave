//
//  Constants.swift
//  Time2Leave
//
//  Created by André Brinkop on 25.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

struct Constants {
    
    // MARK: Location
    
    struct userLocation {
        static let accuracy = kCLLocationAccuracyNearestTenMeters
        static let validInSeconds = 60.0 * 2.5
    }
    
    struct locationAutocomplete {
        static let searchRadiusInKilometers = 150.0
    }
    
    struct apiConstants {
        static let language = "en"
    }
    
    // MARK: UI
    
    struct userInterface {
        static let mapRegionSpanFactor = 1.25
        static let secondsToDepartureForReminderToBecomeAvailable = 60.0 * 3.0
    }
    
    // MARK: API Keys
    
    static let apiKeyPlistName = "ApiKeys"
    
    private struct apiKeyNames {
        static let google = "GOOGLE_API_KEY"
    }
    
    struct apiKeys {
        static let google = getAPIKey(apiKeyNames.google)
    }
    
    // MARK: User Defaults
    
    struct userDefaults {
        static let userLocationLatitude = "USER_LOCATION_LATITUDE"
        static let userLocationLongitude = "USER_LOCATION_LONGITUDE"
        static let userLocationTimestamp = "USER_LOCATION_TIMESTAMP"
    }
}
