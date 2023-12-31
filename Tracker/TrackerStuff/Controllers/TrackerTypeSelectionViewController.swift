//
//  TrackerTypeSelectionViewController.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 20.12.2023.
//

import UIKit

final class TrackerTypeSelectionViewController: UIViewController {
    
    private let presenter: TrackersPresenterProtocol
    
    private let buttonHabbit = {
        let button = UIButton()
        button.layer.cornerRadius = 16.0
        button.setTitle("Привычка", for: .normal)
        button.backgroundColor = UIColor(named: ColorNames.black)
        return button
    }()
    
    private let buttonIrregularEvents = {
        let button = UIButton()
        button.layer.cornerRadius = 16.0
        button.setTitle("Нерегулярные события", for: .normal)
        button.backgroundColor = UIColor(named: ColorNames.black)
        return button
    }()
    
    private let titleLabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "Создание трекера"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        
        buttonHabbit.addTarget(self, action: #selector(buttonHabbitTapped), for: .touchUpInside)
        buttonIrregularEvents.addTarget(self, action: #selector(buttonIrregularEventsTapped), for: .touchUpInside)
    }
    
    init(presenter: TrackersPresenterProtocol){
        
        self.presenter = presenter
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc
    func buttonHabbitTapped(){
        dismiss(animated: true)
        presenter.createTracker(type: .habit)
    }
    
    @objc
    func buttonIrregularEventsTapped(){
        dismiss(animated: true)
        presenter.createTracker(type: .irregularEvent)
    }
    
    func setUpUI(){
        
        view.backgroundColor = .white
        
        [buttonHabbit, buttonIrregularEvents, titleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        let buttonHabbitTopPosition = view.bounds.height / 2 - (60 + 5)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 28),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonHabbit.heightAnchor.constraint(equalToConstant: 60),
            buttonHabbit.topAnchor.constraint(equalTo: view.topAnchor, constant: buttonHabbitTopPosition),
            buttonHabbit.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonHabbit.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonIrregularEvents.heightAnchor.constraint(equalToConstant: 60),
            buttonIrregularEvents.topAnchor.constraint(equalTo: buttonHabbit.bottomAnchor, constant: 10),
            buttonIrregularEvents.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonIrregularEvents.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}
