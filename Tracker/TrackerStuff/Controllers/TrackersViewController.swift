//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 20.12.2023.
//

import UIKit

protocol TrackersViewControllerProtocol: AnyObject {
    
    var currentDate: Date { get }
    var searchTrackerName: String? { get }
    func newTrackerViewControllerPresenting(type: TrackerType)
}

protocol TrackerCreationProtocol: AnyObject {
    func newTrackerViewControllerPresenting(type: TrackerType)
}

final class TrackersViewController: UIViewController {
    
    var currentDate: Date = Date() {
        didSet {
            viewModel.updateCategoriesData(with: currentDate, and: searchTrackerName)
        }
    }
    
    var searchTrackerName: String? {
        didSet {
            viewModel.updateCategoriesData(with: currentDate, and: searchTrackerName)
        }
    }
    
    private var viewModel: TrackerViewModelProtocol
    
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
        
        currentDate = datePicker.date
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
        viewModel.warnFutureCompletion = { [weak self] in
            guard let self = self else { return }
            let action = UIAlertAction(title: "Понятно", style: .cancel)
            AlertPresenter.shared.presentAlert(title: "Так не пойдёт!",
                                               message: "Нельзя отмечать карточку для будущей даты",
                                               actions: [action],
                                               target: self)
        }
        viewModel.warnSaveRecordFailure = { [weak self] in
            guard let self = self else { return }
            let action = UIAlertAction(title: "Жаль", style: .cancel)
            AlertPresenter.shared.presentAlert(title: "Ой-ой-ой ...",
                                               message: "К сожалению не удалось отметить статус выполнения трекера :(",
                                               actions: [action],
                                               target: self)
        }
        viewModel.warnSaveTrackerFailure = { [weak self] in
            guard let self = self else { return }
            let action = UIAlertAction(title: "Жаль", style: .cancel)
            AlertPresenter.shared.presentAlert(title: "Ой-ой-ой ...",
                                               message: "К сожалению возникла ошибка при сохранении трекера :(",
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
        
        [collectionView, labelTitle, searchTextField].forEach {
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
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        datePicker.addTarget(self, action: #selector(dateSelected), for: .valueChanged)
        searchTextField.addTarget(self, action: #selector(searchTextEdited), for: .editingChanged)
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
    // TODO: Необходимо доделать пункты контекстного меню
}

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        let categoriesNumber = viewModel.numberOfCategories()
        
        if categoriesNumber == 0 {
            
            if let plugView = collectionView.backgroundView as? NoDataPlugView {
                
                plugView.fadeIn()
            } else {
                
                collectionView.backgroundView = NoDataPlugView(frame: collectionView.bounds, labelText: "Что будем отслеживать?")
            }
        } else {
            
            if let plugView = collectionView.backgroundView as? NoDataPlugView {
                
                plugView.fadeOut()
            }
        }
        
        return categoriesNumber
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems(in: section)
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
        
        cell.setUpTrackerInfo(with: tracker)
        
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
        
        let headerText = viewModel.category(at: indexPath).title ?? ""
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
