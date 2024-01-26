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
    func updateCell(at: IndexPath)
    func updateTrackersData()
    func warnFutureCompletion()
    func warnSaveTrackerFailure()
    func warnSaveRecordFailure()
}

final class TrackersViewController: UIViewController {
    
    var currentDate: Date = Date()
    var searchTrackerName: String?
    
    private let dataProvider: DataProviderProtocol
    private let presenter: TrackersPresenterProtocol
    
    private let collectionView: UICollectionView = {
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        view.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        view.register(TrackersSectionHeader.self,
                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                      withReuseIdentifier: TrackersSectionHeader.reuseIdentifier)
        return view
    }()
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        return datePicker
    }()
    
    private let labelTitle = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.text = "Трекеры"
        return label
    }()
    
    private let searchTextField: UISearchTextField = {
        let searchBar = UISearchTextField()
        searchBar.placeholder = "Поиск"
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewDidLoad()
        
        setUpUI()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        searchTextField.delegate = self
    }
    
    init(presenter: TrackersPresenterProtocol, provider: DataProviderProtocol) {
        self.presenter = presenter
        self.dataProvider = provider
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func newTrackerButtonTapped() {
        
        let trackerTypeSelectionVC = TrackerTypeSelectionViewController(presenter: presenter)
        trackerTypeSelectionVC.modalPresentationStyle = .popover
        present(trackerTypeSelectionVC, animated: true)
    }
    
    func newTrackerViewControllerPresenting(type: TrackerType){
        
        let newTrackerVC = TrackerCreationViewController(presenter: presenter, type: type)
        newTrackerVC.modalPresentationStyle = .popover
        present(newTrackerVC, animated: true)
    }
    
    private func setUpUI () {
        
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
    
    @objc
    private func searchTextEdited(){
        
        searchTrackerName = searchTextField.text
        presenter.updateCollection(withRecords: true)
    }
    
    @objc
    private func dateSelected(){
        
        currentDate = datePicker.date
        presenter.updateCollection(withRecords: false)
    }
    
    func updateCell(at: IndexPath){
        collectionView.reloadItems(at: [at])
    }
}

extension TrackersViewController: UICollectionViewDelegate {
    // TODO: Необходимо доделать пункты контекстного меню
}

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        let categoriesNumber = dataProvider.numberOfSections()
        
        if categoriesNumber == 0 {
            
            if let plugView = collectionView.backgroundView as? TrackersCollectionPlugView {
                
                plugView.fadeIn()
            } else {
                
                collectionView.backgroundView = TrackersCollectionPlugView(frame: collectionView.bounds)
            }
        } else {
            
            if let plugView = collectionView.backgroundView as? TrackersCollectionPlugView {
                
                plugView.fadeOut()
            }
        }
        return categoriesNumber
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return dataProvider.numberOfItems(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseIdentifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        cell.presenter = presenter
        
        let tracker: Tracker = dataProvider.getTracker(at: indexPath)
        
        var completeDays: Int = 20
        var complete: Bool = true
        
        (completeDays, complete) = dataProvider.completeTrackerState(for: tracker.id, at: currentDate)
        
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
                                                                         for: indexPath) as! TrackersSectionHeader
        
        let headerText = dataProvider.category(at: indexPath).title ?? ""
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
                                             at: indexPath) as! TrackersSectionHeader
        
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

extension TrackersViewController: TrackersViewControllerProtocol {
    
    func updateTrackersData(){
        collectionView.reloadData()
    }
    
    func warnFutureCompletion() {
        let action = UIAlertAction(title: "Понятно", style: .cancel)
        AlertPresenter.shared.presentAlert(title: "Так не пойдёт!",
                                           message: "Нельзя отмечать карточку для будущей даты",
                                           actions: [action],
                                           target: self)
    }
    
    func warnSaveRecordFailure() {
        let action = UIAlertAction(title: "Жаль", style: .cancel)
        AlertPresenter.shared.presentAlert(title: "Ой-ой-ой ...",
                                           message: "К сожалению не удалось отметить статус выполнения трекера :(",
                                           actions: [action],
                                           target: self)
    }
    
    func warnSaveTrackerFailure() {
        let action = UIAlertAction(title: "Жаль", style: .cancel)
        AlertPresenter.shared.presentAlert(title: "Ой-ой-ой ...",
                                           message: "К сожалению возникла ошибка при сохранении трекера :(",
                                           actions: [action],
                                           target: self)
    }
    
}

