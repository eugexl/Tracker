//
//  StringFormaters.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 06.02.2024.
//

import Foundation

struct StringFormaters {
    
    static func doneDays_ru( _ days: Int ) -> String {
        
        var daysString = ""
        
        if (11...19).contains(days) {
            daysString = " дней"
        } else {
            switch days % 10 {
            case 1:
                daysString = " день"
            case 2, 3, 4:
                daysString = " дня"
            default:
                daysString = " дней"
            }
        }
        return days.description + daysString
    }
}
