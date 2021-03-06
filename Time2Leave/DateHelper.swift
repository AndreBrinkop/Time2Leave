//
//  DateHelper.swift
//  Time2Leave
//
//  Created by André Brinkop on 10.01.17.
//  Copyright © 2017 André Brinkop. All rights reserved.
//

import Foundation

class DateHelper {
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
    
    static func humanReadableTime(seconds: Int) -> String {
        let time = timeInHoursMinutesSeconds(seconds: seconds)
        return "\(time.0 < 10 ? "0" : "")\(time.0):\(time.1 < 10 ? "0" : "")\(time.1):\(time.2 < 10 ? "0" : "")\(time.2)"
    }
    
    static func timeInHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    static func roundDateUpToNextMinute(_ date: Date) -> Date {
        return roundDateToNextMinute(date, roundUp: true)
    }
    
    static func roundDateDownToNextMinute(_ date: Date) -> Date {
        return roundDateToNextMinute(date, roundUp: false)
    }
    
    static private func roundDateToNextMinute(_ date: Date, roundUp: Bool) -> Date {
        let seconds = Int(date.timeIntervalSinceReferenceDate)
        if seconds % 60 == 0 {
            return date
        }
        let offset = roundUp ? 60 : 0
        let newSeconds = (seconds / 60) * 60 + offset
        return Date(timeIntervalSinceReferenceDate: TimeInterval(newSeconds))
    }
}
