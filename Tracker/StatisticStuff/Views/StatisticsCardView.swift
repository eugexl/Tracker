//
//  StatisticsCardView.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 09.02.2024.
//

import UIKit

class StatisticsCardView: UIView {
    
    private var value: Int = 0 {
        didSet {
            labelValue.text = value.description
        }
    }
    
    private let labelTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private let labelValue: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.text = "0"
        return label
    }()
    
    required init(frame: CGRect, title: String){
        self.labelTitle.text = title
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = true
        
        [labelTitle, labelValue].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            labelValue.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            labelValue.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            labelTitle.topAnchor.constraint(equalTo: self.topAnchor, constant: 70),
            labelTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
        ])
    }
    
    func updateValue(value: Int) {
        self.value = value
    }
}
