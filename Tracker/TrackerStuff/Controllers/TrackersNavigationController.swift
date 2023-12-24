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
        
        let presenter = TrackersPresenter()
        let trackersVC = TrackersViewController(presenter: presenter)
        
        presenter.view = trackersVC
        
        viewControllers.append(trackersVC)
    }
}
