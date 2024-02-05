//
//  TrackersNavigationController.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 20.12.2023.
//

import UIKit

final class TrackersNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackersVC = TrackersViewController(viewModel: TrackerViewModel())
        
        viewControllers.append(trackersVC)
    }
}
