//
//  Tracker.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 20.12.2023.
//

import UIKit

struct Tracker: Codable {
    
    let id: UUID
    let name: String
    let color: String
    let emoji: String
    let schedule: Set<TrackerSchedule>
}
