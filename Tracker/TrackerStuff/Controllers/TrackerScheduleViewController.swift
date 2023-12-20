//
//  TrackerScheduleViewController.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 20.12.2023.
//

import UIKit

class TrackerScheduleViewController: UIViewController {

    var schedule: Set<TrackerSchedule> = Set<TrackerSchedule>()
    
    private let cellTitle: [String] =
    ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    private let cellItemValue: [TrackerSchedule] = [
        .monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    
    var delegate: TrackerCreationViewController?
    
    private let buttonDone = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: ColorNames.black)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17.0, weight: .medium)
        button.tintColor = .orange
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(UIColor(named: ColorNames.white), for: .normal)
        button.layer.cornerRadius = 16.0
        return button
    }()
    
    private let titleLabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.text = "Расписание"
        return label
    }()
    
    private let tableView = {
        let tableView = UITableView()
        tableView.bounces = false
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        setUpUI()
    }
    
    private func setUpUI(){
        
        view.backgroundColor = .white
        
        [titleLabel, tableView, buttonDone].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 28.0),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 7.0 * 75.0),
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38.0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
            buttonDone.heightAnchor.constraint(equalToConstant: 60.0),
            buttonDone.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 50.0),
            buttonDone.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0),
            buttonDone.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0)
        ])
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16.0, bottom: 0, right: 16.0)
        
        buttonDone.addTarget(self, action: #selector(scheduleMade), for: .touchUpInside)
    }
    
    func cell(with id: Int, switchedOn: Bool){
        
        if switchedOn {
            schedule.insert(cellItemValue[id])
        } else {
            schedule.remove(cellItemValue[id])
        }
    }
    
    @objc
    func scheduleMade(){
        
        delegate?.scheduleMade(with: schedule)
        dismiss(animated: true)
    }
}

extension TrackerScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TrackerScheduleViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return indexPath.row < 6 ? 75 : 76
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return cellTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = TrackerScheduleTableCell()
        
        cell.backgroundColor = UIColor(named: ColorNames.background)
        
        switch indexPath.row {
        case 0:
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 16.0
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case cellTitle.count - 1:
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 16.0
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        default:
            break;
        }
        
        cell.labelText = cellTitle[indexPath.row]
        cell.cellId = indexPath.row
        cell.delegate = self
        
        if schedule.contains(cellItemValue[indexPath.row]) {
            cell.setSwitch(to: true)
        }
        
        return cell
    }
}
