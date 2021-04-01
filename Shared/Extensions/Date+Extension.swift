//
//  Date+Extension.swift
//  Portal
//
//  Created by Farid on 09.03.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation

extension Date {
    func timeAgoSinceDate(shortFormat: Bool) -> String {
        
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
}
