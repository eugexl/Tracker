//
//  TrackersCollectionPlugView.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 20.12.2023.
//

import UIKit

final class TrackersCollectionPlugView: UIView {
    
    
    private let plugImage: UIImageView = UIImageView(image: UIImage(named: "PlugImage"))
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        [ plugImage,
          label
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            plugImage.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            plugImage.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.topAnchor.constraint(equalTo: plugImage.bottomAnchor, constant: 10.0)
        ])
        alpha = 0.0
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func didMoveToSuperview() {
        fadeIn()
    }
    
    func fadeIn(){
        UIView.animate(withDuration: 0.3) {
            self.alpha = 2
        }
    }
    
    func fadeOut(){
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        }
    }
}
