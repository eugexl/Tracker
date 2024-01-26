//
//  DateExtension.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 27.01.2024.
//

import Foundation

extension Date {
    
    var woTime: Date? {
        get {
            let calender = Calendar.current
            var dateComponents = calender.dateComponents([.year, .month, .day], from: self)
            dateComponents.timeZone = NSTimeZone.system
            return calender.date(from: dateComponents)
        }
    }
}
