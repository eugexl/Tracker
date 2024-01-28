//
//  TrackerPropertyCell.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 16.01.2024.
//

import UIKit

final class TrackerCreationEmojiCell: UICollectionViewCell {
    
    static let reuseIdentifier: String = "TrackerCreationEmojiCell"
    
    var emoji: String {
        get { return ""}
        set{
            emojiLabel.text = newValue
        }
    }
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        return label
    }()
    
    private let selectionView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = UIColor(named: ColorNames.lightGray)
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
    
    private func setUpUI(){
        
        [selectionView, emojiLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            selectionView.widthAnchor.constraint(equalToConstant: 52),
            selectionView.heightAnchor.constraint(equalToConstant: 52),
            selectionView.centerXAnchor.constraint(equalTo: centerXAnchor),
            selectionView.centerYAnchor.constraint(equalTo: centerYAnchor),
            emojiLabel.widthAnchor.constraint(equalToConstant: 38),
            emojiLabel.heightAnchor.constraint(equalToConstant: 38),
            emojiLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func toggleSelection(){
        selectionView.isHidden = !selectionView.isHidden
    }
}
