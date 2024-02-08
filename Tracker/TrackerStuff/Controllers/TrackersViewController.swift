//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 20.12.2023.
//

import UIKit

protocol TrackersFilterProtocol: AnyObject {
    
    func setTrackersFilter(to filter: TrackersFilter)
}

protocol TrackerCreationProtocol: AnyObject {
    func newTrackerViewControllerPresenting(type: TrackerType)
}

final class TrackersViewController: UIViewController, TrackersFilterProtocol {
    
    var currentDate: Date = Date() {
        didSet {
            viewModel.updateCategoriesData(withDate: currentDate, andName: searchTrackerName, andFilter: trackersFilter)
        }
    }
    
    var searchTrackerName: String? {
        didSet {
            viewModel.updateCategoriesData(withDate: currentDate, andName: searchTrackerName, andFilter: trackersFilter)
        }
    }
    
    private var trackersFilter: TrackersFilter?
    
    func setTrackersFilter(to filter: TrackersFilter){
        
        trackersFilter = filter
        
        if filter == .todayTrackers {
            datePicker.date = Date()
            currentDate = datePicker.date
        } else {
            viewModel.updateCategoriesData(withDate: currentDate, andName: searchTrackerName, andFilter: trackersFilter)
        }
    }
    
    // Переменная для определения момента (когда создаётся последняя ячейка collectionView )
    // выяснения высоты содержимого collectionView, с целью добавления Inset-а содержимому
    // collectionView, что бы избежать пересечения с кнопкой "Фильтры"
    private var lastCellIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    
    private var viewModel: TrackerViewModelProtocol
    
    private lazy var buttonFilters: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Фильтры", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.tintColor = .white
        button.backgroundColor = UIColor(red: 55/255, green: 114/255, blue: 231/255, alpha: 1)
        button.layer.cornerRadius = 16
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        view.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        view.register(TrackersSectionHeader.self,
                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                      withReuseIdentifier: TrackersSectionHeader.reuseIdentifier)
        return view
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        return datePicker
    }()
    
    private lazy var labelTitle = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.text = "Трекеры"
        return label
    }()
    
    private lazy var searchTextField: UISearchTextField = {
        let searchBar = UISearchTextField()
        searchBar.placeholder = "Поиск"
        searchBar.backgroundColor = UIColor(named: ColorNames.background)
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        searchTextField.delegate = self
    }
    
    init(viewModel: TrackerViewModelProtocol){
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func dateSelected(){
        
        if trackersFilter == .todayTrackers {
            trackersFilter = .allTrackers
        }
        currentDate = datePicker.date
    }
    
    private func buttonFiltersIs(hidden: Bool) {
        
        buttonFilters.isHidden = hidden
    }
    
    @objc
    private func buttonFiltersTapped(){
        let trackersFilterVC = TrackersFilterViewController(delegate: self)
        trackersFilterVC.modalPresentationStyle = .popover
        present(trackersFilterVC, animated: true)
    }
    
    @objc
    private func newTrackerButtonTapped() {
        
        let trackerTypeSelectionVC = TrackerTypeSelectionViewController(delegate: self)
        trackerTypeSelectionVC.modalPresentationStyle = .popover
        present(trackerTypeSelectionVC, animated: true)
    }
    
    @objc
    private func searchTextEdited(){
        
        searchTrackerName = searchTextField.text
    }
    
    private func setupBindings(){
        viewModel.updateCell = collectionView.reloadItems
        viewModel.updateTrackersData = collectionView.reloadData
        viewModel.warnCoreDataFailure = { [weak self] (title, message) in
            guard let self = self else { return }
            let action = UIAlertAction(title: title, style: .cancel)
            AlertPresenter.shared.presentAlert(title: "Ой-ой-ой ...",
                                               message: message,
                                               actions: [action],
                                               target: self)
        }
    }
    
    private func setupUI () {
        
        view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .darkGray
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.shadowImage = UIImage()
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newTrackerButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        [collectionView, labelTitle, searchTextField, buttonFilters].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(equalToConstant: 96),
            
            labelTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 90.0),
            labelTitle.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16.0),
            
            searchTextField.heightAnchor.constraint(equalToConstant: 36.0),
            searchTextField.topAnchor.constraint(equalTo: labelTitle.bottomAnchor, constant: 10.0),
            searchTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonFilters.heightAnchor.constraint(equalToConstant: 50),
            buttonFilters.widthAnchor.constraint(equalToConstant: 114),
            buttonFilters.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonFilters.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
            
        ])
        
        datePicker.addTarget(self, action: #selector(dateSelected), for: .valueChanged)
        searchTextField.addTarget(self, action: #selector(searchTextEdited), for: .editingChanged)
        buttonFilters.addTarget(self, action: #selector(buttonFiltersTapped), for: .touchUpInside)
    }
}

extension TrackersViewController: TrackerCreationProtocol {
    func newTrackerViewControllerPresenting(type: TrackerType){
        
        let newTrackerVC = TrackerCreationViewController(viewModel: viewModel, type: type)
        newTrackerVC.modalPresentationStyle = .popover
        present(newTrackerVC, animated: true)
    }
}

extension TrackersViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, highlightPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell else { return nil }
        return UITargetedPreview(view: cell.viewTop)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard indexPaths.count > 0 else { return nil }
        
        let indexPath = indexPaths[0]
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell,
              let trackerId = cell.trackerId,
              let trackerType = cell.trackerType,
              let pinned = cell.pinned
        else { return nil }
        
        let pinTitle = pinned ? "Открепить" : "Закрепить"
        
        return UIContextMenuConfiguration( actionProvider: { actions in
            
            return UIMenu(children: [
                
                UIAction(title: pinTitle) { [weak self] _ in
                    guard let self = self else { return }
                    self.viewModel.toggleTrackerPin(with: trackerId)
                },
                
                UIAction(title: "Редактировать") { [weak self] _ in
                    guard let self = self else { return }
                    let categoryTitle = self.viewModel.getCategoryOfTracker(with: trackerId)
                    
                    let newTrackerVC = TrackerCreationViewController(viewModel: self.viewModel, type: trackerType, controllerType: .edit)
                    newTrackerVC.modalPresentationStyle = .popover
                    newTrackerVC.fillInfoOfTracker(with: trackerId, and: categoryTitle, done: cell.days)
                    self.present(newTrackerVC, animated: true)
                },
                
                UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                    guard let self = self else { return }
                    let actionCancel = UIAlertAction(title: "Отменить", style: .cancel)
                    let actionDelete = UIAlertAction(title: "Удалить", style: .destructive) { _ in
                        self.viewModel.deleteTracker(with: trackerId)
                    }
                    AlertPresenter.shared.presentAlert(title: "",
                                                       message: "Уверены что хотите удалить трекер?",
                                                       actions: [actionCancel, actionDelete],
                                                       target: self,
                                                       preferredStyle: .actionSheet)
                }
            ])
        })
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        let categoriesNumber = viewModel.numberOfCategories()
        let searchByText = !(searchTextField.text?.isEmpty ?? true)
        
        if categoriesNumber == 0 {
            
            let plugMode: NoDataPlugView.PlugMode = searchByText ? .noTrackersFound : .noTrackers
            buttonFiltersIs(hidden: searchByText)
            
            if let plugView = collectionView.backgroundView as? NoDataPlugView {
                
                if plugView.plugMode != plugMode {
                    plugView.setMode(to: plugMode)
                }
                
                plugView.fadeIn()
            } else {
                
                collectionView.backgroundView = NoDataPlugView(frame: collectionView.bounds, plugMode: plugMode)
            }
            
        } else {
            
            if let plugView = collectionView.backgroundView as? NoDataPlugView {
                
                plugView.fadeOut()
            }
            
            buttonFiltersIs(hidden: false)
        }
        
        return categoriesNumber
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let numberOfItems = viewModel.numberOfItems(in: section)
        lastCellIndexPath = IndexPath(row: numberOfItems - 1, section: section)
        
        return  numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseIdentifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        cell.viewModel = viewModel
        
        let tracker: Tracker = viewModel.getTracker(at: indexPath)
        
        var completeDays: Int = 20
        var complete: Bool = true
        
        (completeDays, complete) = viewModel.completeTrackerState(for: tracker.id, at: currentDate)
        
        cell.days = completeDays
        cell.completed = complete
        cell.pinned = tracker.pinned
        
        cell.setUpTrackerInfo(with: tracker)
        
        if indexPath == lastCellIndexPath {
            
            // Добавляем Нижний Инсет в collectionView для предотвращения пересечения ячеек с кнопкой "Фильтры"
            if collectionView.contentSize.height - collectionView.visibleSize.height > 70 {
                collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
            }
        }
        
        return cell
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
        
        let headerText = viewModel.categoryTitle(for: indexPath.section)
        headerView.setHeader(with: headerText)
        
        return headerView
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = (collectionView.bounds.width - 48) / 2
        return CGSize(width: cellWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
        
        return inset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 16.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let indexPath = IndexPath(row: 0, section: section)
        
        let headerView = self.collectionView(collectionView,
                                             viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
                                             at: indexPath) as? TrackersSectionHeader ?? TrackersSectionHeader()
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }
    
}

extension TrackersViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
}
