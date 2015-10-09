//
//  NSDate+RelativeTime.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 08.05.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import Foundation

extension NSDate {
    func yearsFrom(date:NSDate)   -> Int { return NSCalendar.currentCalendar().components(NSCalendarUnit.Year, fromDate: date, toDate: self, options: []).year }
    func monthsFrom(date:NSDate)  -> Int { return NSCalendar.currentCalendar().components(NSCalendarUnit.Month, fromDate: date, toDate: self, options: []).month }
    func weeksFrom(date:NSDate)   -> Int { return NSCalendar.currentCalendar().components(NSCalendarUnit.WeekOfYear, fromDate: date, toDate: self, options: []).weekOfYear }
    func daysFrom(date:NSDate)    -> Int { return NSCalendar.currentCalendar().components(NSCalendarUnit.Day, fromDate: date, toDate: self, options: []).day }
    func hoursFrom(date:NSDate)   -> Int { return NSCalendar.currentCalendar().components(NSCalendarUnit.Hour, fromDate: date, toDate: self, options: []).hour }
    func minutesFrom(date:NSDate) -> Int { return NSCalendar.currentCalendar().components(NSCalendarUnit.Minute, fromDate: date, toDate: self, options: []).minute }
    func secondsFrom(date:NSDate) -> Int { return NSCalendar.currentCalendar().components(NSCalendarUnit.Second, fromDate: date, toDate: self, options: []).second }
    var relativeTime: String {
        if NSDate().yearsFrom(self)  > 0 {
            return NSDate().yearsFrom(self).description  + " year"  + { return NSDate().yearsFrom(self)   > 1 ? "s" : "" }() + " ago"
        }
        if NSDate().monthsFrom(self) > 0 {
            return NSDate().monthsFrom(self).description + " month" + { return NSDate().monthsFrom(self)  > 1 ? "s" : "" }() + " ago"
        }
        if NSDate().weeksFrom(self)  > 0 { return NSDate().weeksFrom(self).description  + " week"  + { return NSDate().weeksFrom(self)   > 1 ? "s" : "" }() + " ago"
        }
        if NSDate().daysFrom(self)   > 0 {
            if daysFrom(self) == 1 { return "Yesterday" }
            return NSDate().daysFrom(self).description + " days ago"
        }
        if NSDate().hoursFrom(self)   > 0 {
            return "\(NSDate().hoursFrom(self)) hour"     + { return NSDate().hoursFrom(self)   > 1 ? "s" : "" }() + " ago"
        }
        if NSDate().minutesFrom(self) > 0 {
            return "\(NSDate().minutesFrom(self)) minute" + { return NSDate().minutesFrom(self) > 1 ? "s" : "" }() + " ago"
        }
        if NSDate().secondsFrom(self) > 0 {
            if NSDate().secondsFrom(self) < 15 { return "Just now"  }
            return "\(NSDate().secondsFrom(self)) second" + { return NSDate().secondsFrom(self) > 1 ? "s" : "" }() + " ago"
        }
        return ""
    }
}