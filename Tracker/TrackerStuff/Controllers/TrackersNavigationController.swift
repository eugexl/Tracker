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
        
        let dataProvider = DataProvider()
        let presenter = TrackersPresenter(provider: dataProvider)
        
        let trackersVC = TrackersViewController(presenter: presenter, provider: dataProvider)
        
        presenter.view = trackersVC
        
        viewControllers.append(trackersVC)
    }
}
