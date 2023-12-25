//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 20.12.2023.
//

import UIKit

protocol TrackersViewControllerProtocol: AnyObject {
    
    var currentDate: Date { get }
    func newTrackerViewControllerPresenting(type: TrackerType)
    func updateTrackersData(with trackerCategories: [TrackerCategory]?, and trackerRecords: [TrackerRecord]?)
    func warnFutureCompletion()
}

final class TrackersViewController: UIViewController {
    
    private let presenter: TrackersPresenterProtocol
    
    private let collectionView: UICollectionView = {
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        view.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        view.register(TrackersSectionHeader.self,
                       forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                       withReuseIdentifier: TrackersSectionHeader.reuseIdentifier)
        return view
    }()
    
    var currentDate: Date = Date()
    
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
    
    private var categories: [TrackerCategory] = []
    
    private var completedTrackers: [TrackerRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewDidLoad()
        
        setUpUI()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        searchTextField.delegate = self
    }
    
    init(presenter: TrackersPresenterProtocol) {
        self.presenter = presenter
        
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
        
        presenter.updateCollection(withRecords: true, and: searchTextField.text)
    }
    
    @objc
    private func dateSelected(){
        
        currentDate = datePicker.date
        presenter.updateCollection(withRecords: false, and: searchTextField.text)
    }
}

extension TrackersViewController: UICollectionViewDelegate {
    // TODO: Необходимо доделать пункты контекстного меню
}

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if categories.count == 0 {
            
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
        
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let category = categories[section]
        return category.trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseIdentifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        cell.presenter = presenter
        
        let tracker: Tracker = categories[indexPath.section].trackers[indexPath.row]
        
        var completeDays: Int = 0
        var complete: Bool = false
        
        completedTrackers.forEach {
            
            if $0.id == tracker.id {
                
                completeDays += 1
                
                if  Calendar.current.isDate(currentDate, inSameDayAs: $0.time) {
                    complete = true
                }
            }
        }
        
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
        
        let headerText = categories[indexPath.section].title
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
    
    func updateTrackersData(with trackerCategories: [TrackerCategory]?, and trackerRecords: [TrackerRecord]?){
        if let trackerCategories = trackerCategories {
            categories = trackerCategories
        }
        
        if let trackerRecords = trackerRecords {
            completedTrackers = trackerRecords
        }
        
        collectionView.reloadData()
    }
    
    func warnFutureCompletion() {
        let alert = UIAlertController(title: "Так не пойдёт!", message: "Нельзя отмечать карточку для будущей даты", preferredStyle: .alert)
        let action = UIAlertAction(title: "Понятно", style: .cancel)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
}

