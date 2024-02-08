//
//  TrackersFilter.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 07.02.2024.
//

import Foundation

enum TrackersFilter: Int {
    static var currentTrackersFilter: TrackersFilter = .allTrackers
    case allTrackers = 0
    case todayTrackers = 1
    case completedTrackers = 2
    case incompletedTrackers = 3
}
