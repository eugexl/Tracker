//
//  TrackersFilter.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 07.02.2024.
//

import UIKit

final class TrackersFilterViewController: UIViewController {
    
    private var currentFilter: TrackersFilter
    
    private let filterItems: [String] = [
        "Все трекеры",
        "Трекеры на сегодня",
        "Завершённые",
        "Не завершённые"
    ]
    
    weak var delegate: TrackersFilterProtocol?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Фильтры"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let tableView = {
        let tableView = UITableView()
        tableView.bounces = false
        tableView.isScrollEnabled = true
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setupUI()
        ReportMetrics.reportMerics(screen: AppMetricsScreens.main, event: AppMetricsEvents.open, item: AppMetricsItems.filter)
    }
    
    init(delegate: TrackersFilterProtocol){
        self.delegate = delegate
        self.currentFilter = TrackersFilter.currentTrackersFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        
        view.backgroundColor = UIColor(named: ColorNames.white)
        
        [tableView, titleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 28),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(75 * filterItems.count)),
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16.0, bottom: 0, right: 16.0)
        tableView.separatorColor = UIColor(named: ColorNames.gray)
    }
}

extension TrackersFilterViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        
        guard let filter = TrackersFilter(rawValue: indexPath.row) else { return }
        
        delegate?.setTrackersFilter(to: filter)
        
        dismiss(animated: true)
        ReportMetrics.reportMerics(screen: AppMetricsScreens.main, event: AppMetricsEvents.close, item: AppMetricsItems.filter)
    }
}

extension TrackersFilterViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return  indexPath.row == filterItems.count - 1 ? 76 : 75
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filterItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.textLabel?.text = filterItems[indexPath.row]
        cell.backgroundColor = UIColor(named: ColorNames.background)
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 16.0
        
        if currentFilter == TrackersFilter(rawValue: indexPath.row) {
            cell.accessoryType = .checkmark
        }
        
        if indexPath.row == 0 {
                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if indexPath.row == filterItems.count - 1 {
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            cell.layer.maskedCorners = []
        }
        
        return cell
    }
}
