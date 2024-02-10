//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Eugene Dmitrichenko on 08.02.2024.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testTrackerViewControllerWithDarkStyle() {
        
        let vm = TrackerViewModel()
        let vc = TrackersViewController(viewModel: vm)
        
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
    
    func testTrackerViewControllerWithLightStyle() {
        
        let vm = TrackerViewModel()
        let vc = TrackersViewController(viewModel: vm)
        
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
        
}
