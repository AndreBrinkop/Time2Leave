//
//  RouteTimes.swift
//  Time2Leave
//
//  Created by André Brinkop on 01.01.17.
//  Copyright © 2017 André Brinkop. All rights reserved.
//

import Foundation

struct RouteTimes {
    
    // MARK: Properties
    
    var departureTime: Date
    var arrivalTime: Date
    
    var humanReadable: (String, String, String) {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.none
        formatter.timeStyle = .short
        
        return (formatter.string(from: departureTime), formatter.string(from: arrivalTime), travelTimeHumanReadable)
    }
    
    var travelTimeInHoursMinutes: (Int, Int) {
        let travelTime = DateHelper.timeInHoursMinutesSeconds(seconds: Int(arrivalTime.timeIntervalSince(departureTime)))
        return (travelTime.0, travelTime.1)
    }
    
    var travelTimeHumanReadable: String {
        let time = travelTimeInHoursMinutes
        return "\(time.0 < 10 ? "0" : "")\(time.0):\(time.1 < 10 ? "0" : "")\(time.1)"
    }
    
    // MARK: - Initialization
    
    init(departureTime: Date, arrivalTime: Date) {
        self.departureTime = DateHelper.roundDateDownToNextMinute(departureTime)
        self.arrivalTime = DateHelper.roundDateUpToNextMinute(arrivalTime)
    }
    
    init(time: Date, tripDepartureArrivalType: TripDepartureArrivalType, travelTimeInSeconds: Int) {
        if tripDepartureArrivalType == .departure {
            self.init(departureTime: time, arrivalTime: time.addingTimeInterval(TimeInterval(travelTimeInSeconds)))
        } else {
            self.init(departureTime: time.addingTimeInterval(TimeInterval(-travelTimeInSeconds)), arrivalTime: time)
        }
    }
}
