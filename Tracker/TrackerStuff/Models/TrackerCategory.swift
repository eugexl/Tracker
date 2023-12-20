//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 20.12.2023.
//

import Foundation

/// Разбиение трекеров по категориям
struct TrackerCategory: Codable {
    
    let title: String
    var trackers: [Tracker]
}
