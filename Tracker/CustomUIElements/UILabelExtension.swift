//
//  UILabelExtension.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 25.12.2023.
//

import UIKit

extension UILabel {
    
    func generateScheduleList(from trackerSchedule: Set<TrackerSchedule>) {
        
        var scheduleList: String = ""
        var delimiter: String = ""
        
        if trackerSchedule.contains(.monday) {
            scheduleList += "Пн"
            delimiter = ", "
        }
        if trackerSchedule.contains(.tuesday) {
            scheduleList += delimiter + "Вт"
            delimiter = ", "
        }
        if trackerSchedule.contains(.wednesday) {
            scheduleList += delimiter + "Ср"
            delimiter = ", "
        }
        if trackerSchedule.contains(.thursday) {
            scheduleList += delimiter + "Чт"
            delimiter = ", "
        }
        if trackerSchedule.contains(.friday) {
            scheduleList += delimiter + "Пт"
            delimiter = ", "
        }
        if trackerSchedule.contains(.saturday) {
            scheduleList += delimiter + "Сб"
            delimiter = ", "
        }
        if trackerSchedule.contains(.sunday) {
            scheduleList += delimiter + "Вс"
        }
        
        self.text = scheduleList
    }
}
