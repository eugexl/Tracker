//
//  Tracker.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 20.12.2023.
//

import UIKit

struct Tracker {
    
    let id: UUID
    let name: String
    let color: String
    let emoji: String
    let pinned: Bool
    let schedule: Set<TrackerSchedule>
}
