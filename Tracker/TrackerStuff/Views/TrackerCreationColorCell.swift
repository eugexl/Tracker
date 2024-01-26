//
//  TrackerCreationColorCell.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 18.01.2024.
//

import UIKit

final class TrackerCreationColorCell: UICollectionViewCell {
    
    static let reuseIdentifier: String = "TrackerCreationColorCell"
    
    var color: String {
        get { return ""}
        set{
            colorView.backgroundColor = UIColor(named: newValue)
            selectionView.layer.borderColor = UIColor(named: newValue)?.cgColor
        }
    }
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let selectionView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 3
        view.layer.opacity = 0.3
        view.isHidden = true
        return view
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSelectionView(for section: Int){
    }
    
    private func setUpUI(){
        
        [selectionView, colorView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            selectionView.widthAnchor.constraint(equalToConstant: 49),
            selectionView.heightAnchor.constraint(equalToConstant: 49),
            selectionView.centerXAnchor.constraint(equalTo: centerXAnchor),
            selectionView.centerYAnchor.constraint(equalTo: centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func toggleSelection(){
        selectionView.isHidden = !selectionView.isHidden
    }
}
