//
//  TrackerScheduleTableCell.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 20.12.2023.
//

import UIKit

final class TrackerScheduleTableCell: UITableViewCell {
    
    var labelText: String? {
        didSet {
            labelCell.text = labelText
        }
    }
    
    var delegate: TrackerScheduleViewController?
    var cellId: Int?
    
    private let labelCell = {
        let label = UILabel()
        return label
    }()
    
    private let switchCell = {
        let cellSwitch = UISwitch()
        cellSwitch.onTintColor = UIColor(red: 55/255, green: 114/255, blue: 231/255, alpha: 1)
        return cellSwitch
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setUpUI(){
        
        [labelCell, switchCell].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            labelCell.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            labelCell.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
            switchCell.heightAnchor.constraint(equalToConstant: 31.0),
            switchCell.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            switchCell.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),
        ])
        
        switchCell.addTarget(self, action: #selector(turnSwitch), for: .valueChanged)
    }
    
    @objc
    private func turnSwitch(){
        guard let cellId = cellId else { return }
        delegate?.cell(with: cellId, switchedOn: switchCell.isOn)
    }
    
    func setSwitch(to state: Bool){
        self.switchCell.setOn(state, animated: true)
    }
}
