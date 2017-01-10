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
    var travelTimeInSeconds: Int
    
    var humanReadable: (String, String, String) {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.none
        formatter.timeStyle = .short
        
        return (formatter.string(from: departureTime), formatter.string(from: arrivalTime), travelTimeHumanReadable)
    }
    
    var travelTimeInHoursMinutesSeconds: (Int, Int, Int) {
        return (travelTimeInSeconds / 3600, (travelTimeInSeconds % 3600) / 60, (travelTimeInSeconds % 3600) % 60)
    }
    
    var travelTimeInHoursMinutes: (Int, Int) {
        var travelTime = travelTimeInHoursMinutesSeconds
        if travelTime.2 >= 30 {
            travelTime.1 += 1
        }
        if travelTime.1 >= 30 {
            travelTime.0 += 1
        }
        return (travelTime.0, travelTime.1)
    }
    
    var travelTimeHumanReadable: String {
        let time = travelTimeInHoursMinutes
        return "\(time.0 < 10 ? "0" : "")\(time.0):\(time.1 < 10 ? "0" : "")\(time.1)"
    }
    
    // MARK: - Initialization
    
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
    
    // Mark: - Helper Methods
    
    static func humanReadableDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    static func humanReadableTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
