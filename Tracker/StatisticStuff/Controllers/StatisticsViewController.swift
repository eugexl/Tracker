//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 20.12.2023.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    enum cardTitles {
        static let best = "Лучший период"
        static let ideal = "Идеальные дни"
        static let complete = "Трекеров завершено"
        static let middle = "Среднее значение"
    }
    
    private let labelLarge: UILabel = {
        let label = UILabel()
        label.text = "Статистика"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    
    private var valueBest: Int = 0 {
        didSet {
            cardBest.updateValue(value: valueBest)
            checkValues()
        }
    }
    
    var valueComplete: Int = 0 {
        didSet {
            cardComplete.updateValue(value: valueComplete)
            checkValues()
        }
    }
    
    private var valueIdeal: Int = 0 {
        didSet {
            cardIdeal.updateValue(value: valueIdeal)
            checkValues()
        }
    }
    
    private var valueMiddle: Int = 0 {
        didSet {
            cardMiddle.updateValue(value: valueMiddle)
            checkValues()
        }
    }
    
    private var cardBest: StatisticsCardView
    private var cardComplete: StatisticsCardView
    private var cardIdeal: StatisticsCardView
    private var cardMiddle: StatisticsCardView
    private var plugView: NoDataPlugView = NoDataPlugView(frame: UIScreen.main.bounds, plugMode: .statistics, displayedByDefault: false)
    private var viewModel: StatisticsViewModelProtocol
    
    init(viewModel: StatisticsViewModelProtocol){
        
        let cardFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 32, height: 100)
        cardBest = StatisticsCardView(frame: cardFrame, title: cardTitles.best)
        cardComplete = StatisticsCardView(frame: cardFrame, title: cardTitles.complete)
        cardIdeal = StatisticsCardView(frame: cardFrame, title: cardTitles.ideal)
        cardMiddle = StatisticsCardView(frame: cardFrame, title: cardTitles.middle)
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        self.setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        viewModel.updateCompletedTrackersData()
    }
    
    private func setupUI(){
        
        view.backgroundColor = UIColor(named: ColorNames.white)
        
        [cardBest, cardComplete, cardIdeal, cardMiddle, plugView, labelLarge].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        plugView.backgroundColor = UIColor(named: ColorNames.white)
        
        var cardsConstaints: [NSLayoutConstraint] = [NSLayoutConstraint]()
        
        [cardBest, cardComplete, cardIdeal, cardMiddle].forEach {
            cardsConstaints.append(contentsOf: [
                $0.heightAnchor.constraint(equalToConstant: 100),
                $0.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 32),
                $0.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ])
        }
        
        NSLayoutConstraint.activate(cardsConstaints)
        NSLayoutConstraint.activate([
            plugView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            plugView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            plugView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            plugView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            labelLarge.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            labelLarge.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cardBest.topAnchor.constraint(equalTo: labelLarge.bottomAnchor, constant: 90),
            cardIdeal.topAnchor.constraint(equalTo: cardBest.bottomAnchor, constant: 10),
            cardComplete.topAnchor.constraint(equalTo: cardIdeal.bottomAnchor, constant: 10),
            cardMiddle.topAnchor.constraint(equalTo: cardComplete.bottomAnchor, constant: 10),
        ])
        
        [cardBest, cardComplete, cardIdeal, cardMiddle].forEach {
            $0.setGradientBorder(with: [
                ColorNames.statisticsBorderGradient1,
                ColorNames.statisticsBorderGradient2,
                ColorNames.statisticsBorderGradient3,
            ],
                                 width: 5,
                                 radius: 16
            )
        }
    }
    
    private func checkValues(){
        
        if valueBest == 0, valueComplete == 0, valueIdeal == 0, valueMiddle == 0 {
            plugView.fadeIn()
        } else {
            plugView.fadeOut()
        }
    }
    
    private func setupBindings(){
        viewModel.updateBest = { [weak self] value in
            guard let self = self else { return }
            self.valueBest = value
        }
        viewModel.updateCompleted = { [weak self] value in
            guard let self = self else { return }
            self.valueComplete = value
        }
        viewModel.updateIdeal = { [weak self] value in
            guard let self = self else { return }
            self.valueIdeal = value
        }
        viewModel.updateMiddle = { [weak self] value in
            guard let self = self else { return }
            self.valueMiddle = value
        }
    }
}

