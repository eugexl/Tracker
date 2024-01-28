//
//  TrackerCreationViewController.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 20.12.2023.
//

import UIKit

final class TrackerCreationViewController: UIViewController {
    
    private let colorList: [String] = [
        "Color selection 1", "Color selection 2", "Color selection 3", "Color selection 4", "Color selection 5", "Color selection 6",
        "Color selection 7", "Color selection 8", "Color selection 9", "Color selection 10", "Color selection 11", "Color selection 12",
        "Color selection 13", "Color selection 14", "Color selection 15", "Color selection 16", "Color selection 17", "Color selection 18"
    ]
    
    private var colorSelected: Int? = nil
    
    private let emojiList: [String] = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]
    
    private var emojiSelected: Int? = nil
    
    private let newTrackerType: TrackerType
    
    private let presenter: TrackersPresenterProtocol
    
    private let tableCellReuseIdentifier: String = "TableCellSubtitle"
    
    private let tableViewTrackerParameter = ["Категория", "Расписание"]
    
    // FIXME: Необходимо будет убрать наименование отладочной категории
    private var trackerCategory: String = ""
    private var trackerSchedule: Set<TrackerSchedule> = Set<TrackerSchedule>()
    
    private let buttonCancel: UIButton = {
        var button = UIButton()
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor(named: ColorNames.red)?.cgColor
        button.layer.cornerRadius = 16.0
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .medium)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(UIColor(named: ColorNames.red), for: .normal)
        
        return button
    }()
    
    private let buttonCreate: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: ColorNames.gray)
        button.layer.cornerRadius = 16.0
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .medium)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(UIColor(named: ColorNames.white), for: .normal)
        return button
    }()
    
    private let collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.bounces = false
        view.register(TrackerCreationEmojiCell.self, forCellWithReuseIdentifier: TrackerCreationEmojiCell.reuseIdentifier)
        view.register(TrackerCreationColorCell.self, forCellWithReuseIdentifier: TrackerCreationColorCell.reuseIdentifier)
        view.register(TrackersSectionHeader.self,
                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                      withReuseIdentifier: TrackersSectionHeader.reuseIdentifier)
        return view
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
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
        textField.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        trackerCategory = newTrackerType == .habit ? "Категория для отладки привычек" : "Категория для отладки событий"
    }
    
    init(presenter: TrackersPresenterProtocol, type: TrackerType){
        
        self.presenter = presenter
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
        
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        
        [textField, titleLabel, tableView, collectionView, buttonCancel, buttonCreate].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        let buttonWidth = (view.bounds.width - 50) / 2
        
        let contentViewHeightAnchor = contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        contentViewHeightAnchor.priority = UILayoutPriority(50)
        
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentViewHeightAnchor,
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 28.0),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            textField.heightAnchor.constraint(equalToConstant: 75.0),
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38.0),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),
            
            tableView.heightAnchor.constraint(equalToConstant: tableViewHeight),
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 38.0),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),
            
            
            collectionView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 488),
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            collectionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            buttonCancel.heightAnchor.constraint(equalToConstant: 60),
            buttonCancel.widthAnchor.constraint(equalToConstant: buttonWidth),
            buttonCancel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
            buttonCancel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonCancel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            buttonCreate.heightAnchor.constraint(equalToConstant: 60),
            buttonCreate.widthAnchor.constraint(equalToConstant: buttonWidth),
            buttonCreate.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
            buttonCreate.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonCreate.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16.0, bottom: 0, right: 16.0)
        
        buttonCancel.addTarget(self, action: #selector(buttonCancelTapped), for: .touchUpInside)
        buttonCreate.addTarget(self, action: #selector(buttonCreateTapped), for: .touchUpInside)
    }
    
    @objc
    private func buttonCancelTapped(){
        
        dismiss(animated: true)
    }
    
    @objc
    private func buttonCreateTapped(){
        
        guard let trackerName = textField.text, trackerName.count > 0 else {
            let alertAction = UIAlertAction(title: "Понятно", style: .cancel)
            AlertPresenter.shared.presentAlert(title: "Так не пойдёт!", message: "Необходимо указать название трекера", actions: [alertAction], target: self)
            return
        }
        
        if newTrackerType == .habit, trackerSchedule.count == 0 {
            let alertAction = UIAlertAction(title: "Понятно", style: .cancel)
            AlertPresenter.shared.presentAlert(title: "Так не пойдёт!", message: "Необходимо составить расписание трекера", actions: [alertAction], target: self)
            return
        }
        
        guard let selectedEmojiIndex = emojiSelected else {
            let alertAction = UIAlertAction(title: "Понятно", style: .cancel)
            AlertPresenter.shared.presentAlert(title: "Так не пойдёт!", message: "Необходимо выбрать emoji трекера", actions: [alertAction], target: self)
            return
        }
        
        guard let selectedColorIndex = colorSelected else {
            let alertAction = UIAlertAction(title: "Понятно", style: .cancel)
            AlertPresenter.shared.presentAlert(title: "Так не пойдёт!", message: "Необходимо выбрать цвет трекера", actions: [alertAction], target: self)
            return
        }
        
        let emoji = emojiList[selectedEmojiIndex]
        let colorName = colorList[selectedColorIndex]
        
        let tracker = Tracker(id: UUID(),
                              name: trackerName,
                              color: colorName,
                              emoji: emoji,
                              schedule: trackerSchedule)
        
        presenter.save(tracker: tracker, to: trackerCategory)
        dismiss(animated: true)
    }
    
    func scheduleMade(with set: Set<TrackerSchedule>){
        
        self.trackerSchedule = set
        tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
    }
}

extension TrackerCreationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
            
            // TODO: Добавить функционал выбора/добавления категорий - case 0:
            
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
        
        // TODO: В следующей версии переделать trackerCategory в опционал
        // if (indexPath.row == 0 && trackerCategory != nil){
        if (indexPath.row == 0 && trackerCategory.count > 0){
            
            cell.detailTextLabel?.text = trackerCategory
        } else if (indexPath.row == 1 && !trackerSchedule.isEmpty) {
            
            cell.detailTextLabel?.generateScheduleList(from: trackerSchedule)
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

extension TrackerCreationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
}

extension TrackerCreationViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            if emojiSelected != indexPath.row {
                if let selectedItem = emojiSelected {
                    (collectionView.cellForItem(at: IndexPath(row: selectedItem, section: 0)) as? TrackerCreationEmojiCell)?.toggleSelection()
                }
                (collectionView.cellForItem(at: indexPath) as? TrackerCreationEmojiCell)?.toggleSelection()
                emojiSelected = indexPath.row
            }
        default:
            if colorSelected != indexPath.row {
                if let selectedItem = colorSelected {
                    (collectionView.cellForItem(at: IndexPath(row: selectedItem, section: 1)) as? TrackerCreationColorCell)?.toggleSelection()
                }
                (collectionView.cellForItem(at: indexPath) as? TrackerCreationColorCell)?.toggleSelection()
                colorSelected = indexPath.row
            }
        }
    }
}

extension TrackerCreationViewController: UICollectionViewDataSource {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        var reuseIdentifier: String = ""
        if kind == UICollectionView.elementKindSectionHeader {
            reuseIdentifier = TrackersSectionHeader.reuseIdentifier
        }
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: reuseIdentifier,
                                                                            for: indexPath) as? TrackersSectionHeader ?? TrackersSectionHeader()
        
        let headerText = indexPath.section == 0 ? "Emoji" : "Цвет"
        headerView.setHeader(with: headerText)
        
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        18
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCreationEmojiCell.reuseIdentifier,for: indexPath) as? TrackerCreationEmojiCell
            cell?.emoji = emojiList[indexPath.row]
            
            return cell ?? UICollectionViewCell()
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCreationColorCell.reuseIdentifier,for: indexPath) as? TrackerCreationColorCell
            cell?.color = colorList[indexPath.row]
            return cell ?? UICollectionViewCell()
        }
    }
}
extension TrackerCreationViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        CGSize(width: 200, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let sideInset = CGFloat((contentView.frame.size.width - 332) / 2)
        let inset = UIEdgeInsets(top: 20.0, left: sideInset, bottom: 20.0, right: sideInset)
        
        return inset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        4
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        4
    }
    
}
