//
//  RouteTimes.swift
//  Time2Leave
//
//  Created by André Brinkop on 01.01.17.
//  Copyright © 2017 André Brinkop. All rights reserved.
//

import Foundation

struct RouteTimes {
    var departureTime: Date
    var arrivalTime: Date
    var travelTimeInSeconds: Int
    
    init(departureTime: Date, arrivalTime: Date, travelTimeInSeconds: Int) {
        self.departureTime = departureTime
        self.arrivalTime = arrivalTime
        self.travelTimeInSeconds = travelTimeInSeconds
    }
    
    init(departureTime: Date, travelTimeInSeconds: Int) {
        self.init(departureTime: departureTime, arrivalTime: departureTime.addingTimeInterval(TimeInterval(travelTimeInSeconds)), travelTimeInSeconds: travelTimeInSeconds)
    }
    
    init(arrivalTime: Date, travelTimeInSeconds: Int) {
        self.init(departureTime: arrivalTime.addingTimeInterval(TimeInterval(-travelTimeInSeconds)), arrivalTime: arrivalTime, travelTimeInSeconds: travelTimeInSeconds)
    }
    
    init(time: Date, tripDepartureArrivalType: TripDepartureArrivalType, travelTimeInSeconds: Int) {
        if tripDepartureArrivalType == .departure {
            self.init(departureTime: time, arrivalTime: time.addingTimeInterval(TimeInterval(travelTimeInSeconds)), travelTimeInSeconds: travelTimeInSeconds)
        } else {
            self.init(departureTime: time.addingTimeInterval(TimeInterval(-travelTimeInSeconds)), arrivalTime: time, travelTimeInSeconds: travelTimeInSeconds)
        }
    }
}
