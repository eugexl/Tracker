//
//  TrackersCollectionPlugView.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 20.12.2023.
//

import UIKit

final class NoDataPlugView: UIView {
    
    enum PlugMode {
        case noCategories
        case noTrackers
        case noTrackersFound
        case statistics
    }
    
    private lazy var plugImage: UIImageView = UIImageView()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    var plugMode: PlugMode?
    
    init(frame: CGRect, plugMode: NoDataPlugView.PlugMode, displayedByDefault: Bool = true) {
        
        super.init(frame: frame)
        
        switch displayedByDefault {
        case true:
            alpha = 2
        case false:
            alpha = 0
        }
        
        setMode(to: plugMode)
        
        [ plugImage,
          label
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        label.setLineSpacing(lineSpacing: 5)
        
        NSLayoutConstraint.activate([
            plugImage.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            plugImage.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.topAnchor.constraint(equalTo: plugImage.bottomAnchor, constant: 10.0)
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
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
    
    func setMode(to mode: PlugMode) {
        
        var labelText: String = ""
        
        switch mode {
        case .noCategories:
            labelText = "Привычки и события можно\nобъединить по смыслу"
            plugImage.image = UIImage(named: "PlugImage")
        case .noTrackers:
            labelText = NSLocalizedString("trackers.noTrackersTitle", comment: "")
            plugImage.image = UIImage(named: "PlugImage")
        case .noTrackersFound:
            labelText = NSLocalizedString("trackers.noTrackersFoundTitle", comment: "")
            plugImage.image = UIImage(named: "PlugImageSearchMode")
        case .statistics:
            labelText = "Анализировать пока нечего"
            plugImage.image = UIImage(named: "PlugImageStatistics")
        }
        
        label.text = labelText
    }
}
