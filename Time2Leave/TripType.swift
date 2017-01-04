//
//  TripType.swift
//  Time2Leave
//
//  Created by André Brinkop on 31.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation
import UIKit

enum TripType : String {
    case car = "driving"
    case subway = "transit"
    case bike = "bicycling"
    case walk = "walking"
    
    var image: UIImage {
        switch self {
        case .car:
            return #imageLiteral(resourceName: "car")
        case .subway:
            return #imageLiteral(resourceName: "subway")
        case .bike:
            return #imageLiteral(resourceName: "bike")
        case .walk:
            return #imageLiteral(resourceName: "walk")
        }
    }
}
