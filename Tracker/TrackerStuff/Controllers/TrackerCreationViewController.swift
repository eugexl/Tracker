//
//  TrackerCreationViewController.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 20.12.2023.
//

import UIKit

final class TrackerCreationViewController: UIViewController {
    
    private lazy var colorList: [String] = [
        "Color selection 1", "Color selection 2", "Color selection 3", "Color selection 4", "Color selection 5", "Color selection 6",
        "Color selection 7", "Color selection 8", "Color selection 9", "Color selection 10", "Color selection 11", "Color selection 12",
        "Color selection 13", "Color selection 14", "Color selection 15", "Color selection 16", "Color selection 17", "Color selection 18"
    ]
    
    private lazy var colorSelected: Int? = nil {
        didSet {
           testFormValidity()
        }
    }
    
    private lazy var emojiList: [String] = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]
    
    private lazy var emojiSelected: Int? = nil {
        didSet {
           testFormValidity()
        }
    }
    
    
    private var labelTrackerNameLengthLimitErrorHidden: NSLayoutConstraint?
    private var labelTrackerNameLengthLimitErrorDisplayed: NSLayoutConstraint?
    
    private let newTrackerType: TrackerType
    
    private var tableViewTopHigh: NSLayoutConstraint?
    private var tableViewTopLow: NSLayoutConstraint?
    
    private let viewModel: TrackerViewModelProtocol
    
    private let tableCellReuseIdentifier: String = "TableCellSubtitle"
    
    private lazy var tableViewTrackerParameter = ["Категория", "Расписание"]
    
    private var trackerId: UUID?
    
    private lazy var trackerSchedule: Set<TrackerSchedule> = Set<TrackerSchedule>() {
        didSet {
           testFormValidity()
        }
    }
    
    private lazy var buttonCancel: UIButton = {
        var button = UIButton()
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor(named: ColorNames.red)?.cgColor
        button.layer.cornerRadius = 16.0
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .medium)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(UIColor(named: ColorNames.red), for: .normal)
        
        return button
    }()
    
    private lazy var buttonCreate: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: ColorNames.gray)
        button.layer.cornerRadius = 16.0
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .medium)
        button.setTitleColor(UIColor(named: ColorNames.white), for: .normal)
        button.isEnabled = false
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.bounces = false
        view.register(TrackerCreationEmojiCell.self, forCellWithReuseIdentifier: TrackerCreationEmojiCell.reuseIdentifier)
        view.register(TrackerCreationColorCell.self, forCellWithReuseIdentifier: TrackerCreationColorCell.reuseIdentifier)
        view.register(TrackersSectionHeader.self,
                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                      withReuseIdentifier: TrackersSectionHeader.reuseIdentifier)
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var labelDoneDays: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.text = "5 дней"
        return label
    }()
    
    private lazy var labelTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var labelTrackerNameLengthLimitError: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor(named: ColorNames.red)
        label.text = "Ограничение 38 символов"
        return label
    }()
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var textField = {
        
        let textField = CustomTextField()
        textField.layer.cornerRadius = 16.0
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = UIColor(named: ColorNames.background)
        textField.font = UIFont.systemFont(ofSize: 17.0)
        textField.clearButtonMode = .whileEditing
        
        return textField
    }()
    
    private lazy var tableView = {
        
        let tableView = UITableView()
        tableView.bounces = false
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    var trackerCategory: String = "" {
        didSet {
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
           testFormValidity()
        }
    }
    
    var controllerType: ControllerType
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: tableCellReuseIdentifier)
        textField.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    init(viewModel: TrackerViewModelProtocol, type: TrackerType, controllerType: ControllerType = .create){
        
        self.viewModel = viewModel
        self.newTrackerType = type
        self.controllerType = controllerType
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpUI(){
        
        view.backgroundColor = UIColor(named: ColorNames.white)
        
        let tableViewHeight: CGFloat = newTrackerType == .habit ? 150.0 : 75.0
        switch newTrackerType {
        case .habit:
            labelTitle.text = controllerType == .create ? "Новая привычка" : "Редактирование привычки"
        case .irregularEvent:
            labelTitle.text = controllerType == .create ? "Новое нерегулярное событие" : "Редактирование события"
        }
        
        let buttonTitle = controllerType == .create ? "Создать" : "Сохранить"
        buttonCreate.setTitle(buttonTitle, for: .normal)
        
        view.addSubview(labelTitle)
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        
        [labelDoneDays, textField, labelTrackerNameLengthLimitError, tableView, collectionView, buttonCancel, buttonCreate].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        let buttonWidth = (view.bounds.width - 50) / 2
        
        let contentViewHeightAnchor = contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        contentViewHeightAnchor.priority = UILayoutPriority(50)
        
        let labelDoneDaysHeight: CGFloat = controllerType == .create ? 0 : 60
        
        labelTrackerNameLengthLimitErrorHidden = labelTrackerNameLengthLimitError.heightAnchor.constraint(equalToConstant: 0)
        labelTrackerNameLengthLimitErrorDisplayed = labelTrackerNameLengthLimitError.heightAnchor.constraint(equalToConstant: 22)
        labelTrackerNameLengthLimitErrorHidden?.isActive = true
        
        tableViewTopLow = tableView.topAnchor.constraint(equalTo: labelTrackerNameLengthLimitError.bottomAnchor, constant: 18)
        tableViewTopHigh = tableView.topAnchor.constraint(equalTo: labelTrackerNameLengthLimitError.bottomAnchor, constant: 30)
        tableViewTopLow?.isActive = true
        
        NSLayoutConstraint.activate([
            labelTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 28),
            labelTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            scrollView.topAnchor.constraint(equalTo: labelTitle.bottomAnchor, constant: 10),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentViewHeightAnchor,
            
            labelDoneDays.heightAnchor.constraint(equalToConstant: labelDoneDaysHeight),
            labelDoneDays.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            labelDoneDays.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.topAnchor.constraint(equalTo: labelDoneDays.bottomAnchor, constant: 26),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            labelTrackerNameLengthLimitError.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 6),
            labelTrackerNameLengthLimitError.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            tableView.heightAnchor.constraint(equalToConstant: tableViewHeight),
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
        
        guard let trackerName = textField.text else { return }
        guard let selectedColorIndex = colorSelected else { return }
        guard let selectedEmojiIndex = emojiSelected else { return }
        
        let emoji = emojiList[selectedEmojiIndex]
        let colorName = colorList[selectedColorIndex]
        
        let tracker = Tracker(id: trackerId ?? UUID(),
                              name: trackerName,
                              color: colorName,
                              emoji: emoji,
                              pinned: false,
                              schedule: trackerSchedule)
        
        switch controllerType {
        case .create:
            viewModel.save(tracker: tracker, to: trackerCategory)
        case .edit:
            viewModel.update(tracker: tracker, to: trackerCategory)
        }
        dismiss(animated: true)
    }
    
    private func buttonCreateState(isEnabled: Bool){
        
        buttonCreate.backgroundColor = UIColor(named: isEnabled ? ColorNames.black : ColorNames.gray)
        buttonCreate.isEnabled = isEnabled
    }
    
    private func labelTrackerNameLengthLimitError(displayed: Bool){
        
        if displayed {
            UIView.animate(withDuration: 0.3) {
                self.labelTrackerNameLengthLimitErrorHidden?.isActive = false
                self.labelTrackerNameLengthLimitErrorDisplayed?.isActive = true
                self.tableViewTopLow?.isActive = false
                self.tableViewTopHigh?.isActive = true
                self.view.layoutIfNeeded()
            }
        } else  {
            UIView.animate(withDuration: 0.3) {
                self.labelTrackerNameLengthLimitErrorDisplayed?.isActive = false
                self.labelTrackerNameLengthLimitErrorHidden?.isActive = true
                self.tableViewTopHigh?.isActive = false
                self.tableViewTopLow?.isActive = true
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func testFormValidity(){
        guard let trackerName = textField.text, (1...38).contains(trackerName.count) else {
            buttonCreateState(isEnabled: false);
            return
        }
        
        guard trackerCategory.count > 0 else {
            buttonCreateState(isEnabled: false);
            return
        }
        
        if newTrackerType == .habit, trackerSchedule.count == 0 {
            buttonCreateState(isEnabled: false);
            return
        }
        
        guard colorSelected != nil else {
            buttonCreateState(isEnabled: false);
            return
        }
        
        guard emojiSelected != nil else {
            buttonCreateState(isEnabled: false);
            return
        }
        
        buttonCreateState(isEnabled: true);
    }
    
    func fillInfoOfTracker(with trackerId: UUID, and category: String, done days: Int){
        
        guard let tracker = viewModel.getTracker(with: trackerId) else {
            // TODO: Придумать обратичик ошибки с отсутствием данных ...
            print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            print("Отсутствуют данные для редактируемого трекера")
            print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            return
        }
        
        self.trackerId = tracker.id
        textField.text = tracker.name
        emojiSelected = emojiList.firstIndex(of: tracker.emoji)
        colorSelected = colorList.firstIndex(of: tracker.color)
        trackerCategory = category
        trackerSchedule = tracker.schedule
        labelDoneDays.text = StringFormaters.doneDays_ru(days)
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
            
            let trackerCategoryVC = TrackerCategoryViewController(delegate: self, viewModel: viewModel)
            present(trackerCategoryVC, animated: true)
            
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
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        guard let trackerName = textField.text, trackerName.count < 39 else {
            
            labelTrackerNameLengthLimitError(displayed: true)
            buttonCreateState(isEnabled: false);
            return
        }
        
        labelTrackerNameLengthLimitError(displayed: false)
        testFormValidity()
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
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCreationEmojiCell.reuseIdentifier,for: indexPath) as? TrackerCreationEmojiCell ?? TrackerCreationEmojiCell()
            
            cell.emoji = emojiList[indexPath.row]
            if indexPath.row == emojiSelected {
                cell.toggleSelection()
            }
            
            return cell
        default:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCreationColorCell.reuseIdentifier,for: indexPath) as? TrackerCreationColorCell ?? TrackerCreationColorCell()
            
            cell.color = colorList[indexPath.row]
            if indexPath.row == colorSelected {
                cell.toggleSelection()
            }
            return cell
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
