//
//  ColorTransformer.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 22.01.2024.
//

import Foundation

@objc(ScheduleTransformer)
final class ScheduleTransformer: ValueTransformer {
    
    static func register() {
        ValueTransformer.setValueTransformer(ScheduleTransformer(),
                                             forName: NSValueTransformerName(rawValue: String(describing: ScheduleTransformer.self)))
    }
    
    class override func allowsReverseTransformation() -> Bool {
        true
    }
    
    class override func transformedValueClass() -> AnyClass {
        NSSet.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        
        guard let schedule = value as? Set<TrackerSchedule> else { return nil }
        return try? JSONEncoder().encode(schedule)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        
        guard let scheduleData = value as? NSData else { return nil }
        return try? JSONDecoder().decode(Set<TrackerSchedule>.self, from: scheduleData as Data)
    }
}
