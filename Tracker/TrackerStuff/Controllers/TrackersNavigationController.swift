//
//  TrackersNavigationController.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 20.12.2023.
//

import UIKit

class TrackersNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewModel = TrackersViewModel()
        let trackersVC = TrackersViewController(viewModel: viewModel)
        
        viewModel.view = trackersVC
        
        viewControllers.append(trackersVC)
    }
}
