//
//  Date+Extension.swift
//  Portal
//
//  Created by Farid on 09.03.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation

extension Date {
    public func timeAgoSinceDate(shortFormat: Bool) -> String {
        
        // From Time
        let fromDate = self
        
        // To Time
        let toDate = Date()
        
        // Estimation
        // Year
        if let interval = Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year, interval > 0  {
            if shortFormat {
                return "\(interval)" + "y ago"
            }
            if interval == 1 {
                return "\(interval)" + " year ago"
            } else {
                return "\(interval)" + " years ago"
            }
        }
        
        // Month
        if let interval = Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month, interval > 0  {
            return interval == 1 ? "\(interval)" + " " + "month ago" : "\(interval)" + " " + "months ago"
        }
        
        // Day
        if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0  {
            if shortFormat {
                return "\(interval)" + "d ago"
            }
            if interval == 1 {
                return "\(interval)" + " day ago"
            } else {
                return "\(interval)" + " days ago"
            }
        }
        
        // Hours
        if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {
            if shortFormat {
                return "\(interval)" + "h ago"
            }
            if interval == 1 {
                return "\(interval)" + " hour ago"
            } else {
                return "\(interval)" + " hours ago"
            }
        }
        
        // Minute
        if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {
            if shortFormat {
                return "\(interval)" + "m ago"
            }
            if interval == 1 {
                return "\(interval)" + " minute ago"
            } else {
                return "\(interval)" + " minutes ago"
            }
        }
        
        return "just now"
    }
    
    public func hoursAfterDate(_ aDate: Date) -> Double {
        let ti = timeIntervalSince(aDate)
        return ti / (60 * 60)
    }

    public func minutesAfterDate(_ aDate: Date) -> Double {
        let ti = timeIntervalSince(aDate)
        return ti / 60
    }

    public func daysAfterDate(_ aDate: Date) -> Double {
        let ti = timeIntervalSince(aDate)
        return ti / (60 * 60 * 24)
    }

    public func isDateInCurrentYear(date: Date) -> Bool {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        return year == calendar.component(.year, from: Date())
    }

    public func isSameDay(as date: Date) -> Bool {
        Calendar.current.compare(self, to: date, toGranularity: .day) == .orderedSame
    }
    
    public func currentDateInUserTimeZone() -> Date {
        let currentDate = Date()
        let timezoneOffset =  TimeZone.current.secondsFromGMT()
        let epochDate = currentDate.timeIntervalSince1970
        let timezoneEpochOffset = (epochDate + Double(timezoneOffset))
        let timeZoneOffsetDate = Date(timeIntervalSince1970: timezoneEpochOffset)
        return timeZoneOffsetDate
    }
}
