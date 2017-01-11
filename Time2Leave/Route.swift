//
//  Route.swift
//  Time2Leave
//
//  Created by André Brinkop on 30.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation
import CoreLocation
import Polyline
import MapKit

struct Route {
    
    // MARK: - Properties
    
    var summary: String
    var copyrights: String?
    var warnings: [String]?
    
    var times: RouteTimes
    
    var polylineCoordinates: [CLLocationCoordinate2D]
    var polylineBounds: MKCoordinateRegion
    
    // MARK: - Computed Properties
    
    var warningsString: String {
        var warningsString = ""
        guard let warnings = warnings else {
            return warningsString
        }
        for warning in warnings {
            if warning != warnings.first {
                warningsString += ", "
            }
            warningsString += warning
        }
        return warningsString
    }
    
    var polylineString: String {
        return Polyline.init(coordinates: polylineCoordinates).encodedPolyline
    }
    


}
