//
//  TrackerCreationViewController.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 20.12.2023.
//

import UIKit

class TrackerCreationViewController: UIViewController {
    
    private let newTrackerType: TrackerType
    
    private let viewModel: TrackersViewModelProtocol
    
    private let tableCellReuseIdentifier: String = "TableCellSubtitle"
    
    private let tableViewTrackerParameter = ["Категория", "Расписание"]
    
    private var trackerCategory: String = "Категория для отладки"
    private var trackerSchedule: Set<TrackerSchedule> = Set<TrackerSchedule>()
    
    private let buttonCancel = {
        var button = UIButton()
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor(named: ColorNames.red)?.cgColor
        button.layer.cornerRadius = 16.0
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .medium)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(UIColor(named: ColorNames.red), for: .normal)
    
        return button
    }()

    private let buttonCreate = {
       let button = UIButton()
        button.backgroundColor = UIColor(named: ColorNames.gray)
        button.layer.cornerRadius = 16.0
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .medium)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(UIColor(named: ColorNames.white), for: .normal)
        return button
    }()

    private let titleLabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let textField = {
        
        let textField = CustomTextField()
        textField.layer.cornerRadius = 16.0
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = UIColor(named: ColorNames.background)
        textField.font = UIFont.systemFont(ofSize: 17.0)
        textField.clearButtonMode = .whileEditing
        
        return textField
    }()
    
    private let tableView = {
        
        let tableView = UITableView()
        tableView.bounces = false
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: tableCellReuseIdentifier)
    }
    
    init(viewModel: TrackersViewModelProtocol, type: TrackerType){
        
        self.viewModel = viewModel
        self.newTrackerType = type
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpUI(){
        
        view.backgroundColor = UIColor(named: ColorNames.white)
        
        let tableViewHeight: CGFloat = newTrackerType == .habit ? 150.0 : 75.0
        titleLabel.text = newTrackerType == .habit ? "Новая привычка" : "Новое нерегулярное событие"
        
        [textField, titleLabel, tableView, buttonCancel, buttonCreate].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        let buttonWidth = (view.bounds.width - 50) / 2
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 28.0),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.heightAnchor.constraint(equalToConstant: 75.0),
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38.0),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
            tableView.heightAnchor.constraint(equalToConstant: tableViewHeight),
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 38.0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
            buttonCancel.heightAnchor.constraint(equalToConstant: 60.0),
            buttonCancel.widthAnchor.constraint(equalToConstant: buttonWidth),
            buttonCancel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0),
            buttonCancel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40.0),
            buttonCreate.heightAnchor.constraint(equalToConstant: 60.0),
            buttonCreate.widthAnchor.constraint(equalToConstant: buttonWidth),
            buttonCreate.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0),
            buttonCreate.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40.0)
        ])
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16.0, bottom: 0, right: 16.0)
        
        buttonCancel.addTarget(self, action: #selector(buttonCancelTapped), for: .touchUpInside)
        buttonCreate.addTarget(self, action: #selector(buttonCreateTapped), for: .touchUpInside)
    }
    
    @objc
    func buttonCancelTapped(){
    
        dismiss(animated: true)
    }
    
    @objc
    func buttonCreateTapped(){
        
        guard let trackerName = textField.text, trackerName.count > 0 else {
            let alertAction = UIAlertAction(title: "Понятно", style: .cancel)
            AlertPresenter.shared.presentAlert(title: "Так не пойдёт!", message: "Необходимо указать название трекера", actions: [alertAction], target: self)
            return
        }
        
        guard trackerSchedule.count > 0 else {
            let alertAction = UIAlertAction(title: "Понятно", style: .cancel)
            AlertPresenter.shared.presentAlert(title: "Так не пойдёт!", message: "Необходимо составить расписание трекера", actions: [alertAction], target: self)
            return
        }
        
        let randomEmoji: String = Emoji.list[Int.random(in: 0..<Emoji.list.count)]
        let randomColorName: String = "Color selection " + Int.random(in: 1...18).description
        
        let tracker = Tracker(id: UUID(),
                              name: trackerName,
                              color: randomColorName,
                              emoji: randomEmoji,
                              schedule: trackerSchedule)
        viewModel.save(tracker: tracker, to: trackerCategory)
        dismiss(animated: true)
    }
    
    func generateScheduleList() -> String {
        
        var scheduleList: String = ""
        var delimiter: String = ""
        
        if trackerSchedule.contains(.monday) {
            scheduleList += "Пн"
            delimiter = ", "
        }
        if trackerSchedule.contains(.tuesday) {
            scheduleList += delimiter + "Вт"
            delimiter = ", "
        }
        if trackerSchedule.contains(.wednesday) {
            scheduleList += delimiter + "Ср"
            delimiter = ", "
        }
        if trackerSchedule.contains(.thursday) {
            scheduleList += delimiter + "Чт"
            delimiter = ", "
        }
        if trackerSchedule.contains(.friday) {
            scheduleList += delimiter + "Пт"
            delimiter = ", "
        }
        if trackerSchedule.contains(.saturday) {
            scheduleList += delimiter + "Сб"
            delimiter = ", "
        }
        if trackerSchedule.contains(.sunday) {
            scheduleList += delimiter + "Вс"
        }
        
        return scheduleList
    }
    
    func scheduleMade(with set: Set<TrackerSchedule>){
        
        self.trackerSchedule = set
        tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
    }
}

extension TrackerCreationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        switch indexPath.row {
        case 0:
            print("Category Cell Tapped")
        case 1:
            let trackerScheduleVC = TrackerScheduleViewController()
            trackerScheduleVC.delegate = self
            trackerScheduleVC.schedule = trackerSchedule
            present(trackerScheduleVC, animated: true)
        default:
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TrackerCreationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch newTrackerType {
        case .habit:
            return tableViewTrackerParameter.count
        case .irregularEvent:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        // Прячем последнюю разделительную линию ...
        var height: CGFloat = 76.0
        if newTrackerType == .habit {
            height = indexPath.row == 0 ? 75.0 : 76.0
        }
    
        return height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = UITableViewCell(style: .subtitle, reuseIdentifier: tableCellReuseIdentifier)
        
        cell.detailTextLabel?.textColor = UIColor(named: ColorNames.gray)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 15.0)
        
        // В следующей версии приложения trckerCategory будет опциональным
//        if (indexPath.row == 0 && trackerCategory != nil){
        if (indexPath.row == 0 && trackerCategory.count > 0){
            
            cell.detailTextLabel?.text = trackerCategory
        } else if (indexPath.row == 1 && !trackerSchedule.isEmpty) {
            
            cell.detailTextLabel?.text = generateScheduleList()
        }
        
        cell.textLabel?.text = tableViewTrackerParameter[indexPath.row]
        cell.backgroundColor = UIColor(named: ColorNames.background)
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 16.0
        
        switch newTrackerType {
        case .habit:
            cell.layer.maskedCorners = indexPath.row == 0 ? [.layerMinXMinYCorner, .layerMaxXMinYCorner] : [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .irregularEvent:
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
}
