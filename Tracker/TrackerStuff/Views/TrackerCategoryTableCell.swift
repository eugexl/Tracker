//
//  TrackerCategoryTableCell.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 03.02.2024.
//

import UIKit

final class TrackerCategoryTableCell: UITableViewCell {
    
    static let reuseIdentifier = "TrackerCategoryTableCell"
    var hidesBottomSeparator = false
    
    lazy var labelText: String? = "" {
        didSet {
            labelCell.text = labelText
        }
    }
    
    weak var delegate: TrackerCategoryViewController?
    var cellId: Int?
    
    private lazy var labelCell = {
        let label = UILabel()
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bottomSeparator = subviews.first { $0.frame.minY >= bounds.maxY - 1 && $0.frame.height <= 1 }
        bottomSeparator?.isHidden = hidesBottomSeparator
    }
    
    private func setUpUI(){
        
        [labelCell].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            labelCell.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            labelCell.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
        ])
    }
}

