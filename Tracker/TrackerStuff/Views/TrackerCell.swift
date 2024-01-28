//
//  TrackerCell.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 20.12.2023.
//

import UIKit

final class TrackerCell: UICollectionViewCell {
    
    static let reuseIdentifier: String = "TrackerCell"
    
    var days: Int = 0 {
        didSet {
            updateQuantityLabel()
        }
    }
    
    var completed: Bool = false {
        didSet {
            updateCompleteTrackerButton()
        }
    }
    
    var presenter: TrackersPresenterProtocol?
    var trackerId: UUID?
    
    private let buttonCompleteTracker: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.layer.cornerRadius = 17.0
        
        return button
    }()
    
    private let labelEmojiIcon: UILabel = {
        let textView = UILabel()
        textView.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textView.textAlignment = .center
        return textView
    }()
    
    private let labelQuantity: UILabel = {
        let text = UILabel()
        text.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return text
    }()
    
    private let textViewTrackerText: UITextView = {
        let text = UITextView()
        text.font = UIFont.systemFont(ofSize: 12.0)
        text.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        text.textColor = .white
        text.backgroundColor = .none
        text.textAlignment = .left
        text.isEditable = false
        return text
    }()
    
    private let viewBottom: UIView = {
        let bottomView = UIView()
        bottomView.backgroundColor = .white
        return bottomView
    }()
    
    private let viewEmojiContainer: UIView = {
        let emojiView = UIView()
        emojiView.layer.cornerRadius = 12.0
        emojiView.backgroundColor = UIColor(named: ColorNames.emojiContainer)
        return emojiView
    }()
    
    private let viewTop: UIView = {
        let topView = UIView()
        topView.layer.cornerRadius = 16.0
        topView.backgroundColor = .orange
        return topView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpUI()
        
        updateQuantityLabel()
        updateCompleteTrackerButton()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @objc
    private func buttonCompleteTrackerTapped(){
        
        guard let presenter = presenter, let trackerId = trackerId else {
            return
        }
        presenter.completeTracker(with: trackerId, indeed: !completed)
    }
    
    private func setUpUI(){
        
        [viewEmojiContainer, labelEmojiIcon, labelQuantity, buttonCompleteTracker, textViewTrackerText, viewTop, viewBottom].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        contentView.addSubview(viewTop)
        contentView.addSubview(viewBottom)
        viewTop.addSubview(viewEmojiContainer)
        viewTop.addSubview(textViewTrackerText)
        viewEmojiContainer.addSubview(labelEmojiIcon)
        viewBottom.addSubview(labelQuantity)
        viewBottom.addSubview(buttonCompleteTracker)
        
        NSLayoutConstraint.activate([
            viewTop.heightAnchor.constraint(equalToConstant: 90.0),
            viewTop.topAnchor.constraint(equalTo: contentView.topAnchor),
            viewTop.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            viewTop.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            viewEmojiContainer.heightAnchor.constraint(equalToConstant: 24.0),
            viewEmojiContainer.widthAnchor.constraint(equalToConstant: 24.0),
            viewEmojiContainer.topAnchor.constraint(equalTo: viewTop.topAnchor, constant: 12.0),
            viewEmojiContainer.leadingAnchor.constraint(equalTo: viewTop.leadingAnchor, constant: 12.0),
            
            labelEmojiIcon.centerXAnchor.constraint(equalTo: viewEmojiContainer.centerXAnchor),
            labelEmojiIcon.centerYAnchor.constraint(equalTo: viewEmojiContainer.centerYAnchor),
            
            textViewTrackerText.heightAnchor.constraint(equalToConstant: 34.0),
            textViewTrackerText.topAnchor.constraint(equalTo: viewTop.topAnchor, constant: 44.0),
            textViewTrackerText.leadingAnchor.constraint(equalTo: viewTop.leadingAnchor, constant: 12.0),
            textViewTrackerText.trailingAnchor.constraint(equalTo: viewTop.trailingAnchor, constant: -12.0),
            
            viewBottom.heightAnchor.constraint(equalToConstant: 58.0),
            viewBottom.topAnchor.constraint(equalTo: viewTop.bottomAnchor),
            viewBottom.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            viewBottom.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            labelQuantity.topAnchor.constraint(equalTo: viewBottom.topAnchor, constant: 16.0),
            labelQuantity.leadingAnchor.constraint(equalTo: viewBottom.leadingAnchor, constant: 12.0),
            
            buttonCompleteTracker.heightAnchor.constraint(equalToConstant: 34.0),
            buttonCompleteTracker.widthAnchor.constraint(equalToConstant: 34.0),
            buttonCompleteTracker.topAnchor.constraint(equalTo: viewBottom.topAnchor, constant: 8.0),
            buttonCompleteTracker.trailingAnchor.constraint(equalTo: viewBottom.trailingAnchor, constant: -12.0)
        ])
        
        buttonCompleteTracker.addTarget(self, action: #selector(buttonCompleteTrackerTapped), for: .touchUpInside)
    }
    
    private func updateQuantityLabel(){
        
        var daysString = ""
        
        if (11...19).contains(days) {
            daysString = " дней"
        } else {
            switch days % 10 {
            case 1:
                daysString = " день"
            case 2, 3, 4:
                daysString = " дня"
            default:
                daysString = " дней"
            }
        }
        labelQuantity.text = days.description + daysString
    }
    
    private func updateCompleteTrackerButton(){
        
        let buttonCompleteTrackerImageName = completed ? "checkmark" : "plus"
        buttonCompleteTracker.setImage(UIImage(systemName: buttonCompleteTrackerImageName) , for: .normal)
        buttonCompleteTracker.layer.opacity = completed ? 0.3 : 1
    }
    
    func setUpTrackerInfo(with tracker: Tracker){
        
        trackerId = tracker.id
        labelEmojiIcon.text = tracker.emoji
        textViewTrackerText.text = tracker.name
        [viewTop, buttonCompleteTracker].forEach {
            $0.backgroundColor = UIColor(named: tracker.color)
        }
    }
}
