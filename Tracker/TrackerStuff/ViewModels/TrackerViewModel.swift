//
//  DataStore.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 21.01.2024.
//

import Foundation

protocol TrackerViewModelProtocol: AnyObject {
    var filterByDate: Date { get }
    var filterByName: String { get }
    var updateCell: ((_ at: [IndexPath]) -> Void)? { get set }
    var updateTrackersData: (() -> Void)? { get set }
    var updateCategoriesData: (() -> Void)? { get set }
    var warnCoreDataFailure: (( _ title: String, _ message: String) -> Void)? { get set }
    
    func category(at indexPath: IndexPath) -> TrackerCategoryCoreData
    func categoryTitle(for row: Int) -> String
    func categoryTitleFromTotalList(for row: Int) -> String
    func completeTracker(with id: UUID, indeed: Bool)
    func completeTrackerState(for trackerId: UUID, at date: Date) -> (daysNum: Int, state: Bool)
    func createCategory(titledWith title: String)
    func deleteTracker(with trackerId: UUID)
    func deleteCategory(titledWith title: String)
    func getCategoryOfTracker(with trackerId: UUID) -> String
    func getTracker(at: IndexPath) -> Tracker
    func getTracker(with trackerId: UUID) -> Tracker?
    func numberOfItems(in section: Int) -> Int
    func numberOfCategories() -> Int
    func numberOfCategoriesTotal() -> Int
    func save(tracker: Tracker, to categoryWithTitle: String)
    func toggleTrackerPin(with trackerId: UUID)
    func update(tracker: Tracker, to categoryWithTitle: String)
    func updateCategoriesData(withDate date: Date?, andName searchfilter: String?, andFilter: TrackersFilter?)
    func updateCategory(fromOld previousTitle: String, toNew title: String)
    func updateCompletedTrackersData()
}

final class TrackerViewModel {
    
    private lazy var trackerStore: TrackerStore = TrackerStore(viewModel: self)
    private lazy var categoryStore: TrackerCategoryStore = TrackerCategoryStore(viewModel: self, trackerStore: trackerStore)
    private lazy var recordStore: TrackerRecordStore = TrackerRecordStore(viewModel: self)
    
    private var categories: [TrackerCategory] = [TrackerCategory]() {
        didSet {
            self.updateTrackersData?()
        }
    }
    
    private var categoriesTitleList: [String] = [String](){
        didSet{
            self.updateCategoriesData?()
        }
    }
    private var completedTrackers: [TrackerRecord] = [TrackerRecord]()
    
    var filterByDate: Date = Date()
    var filterByName: String = ""
    var trackersFilter: TrackersFilter = .allTrackers {
        didSet {
            TrackersFilter.currentTrackersFilter = trackersFilter
        }
    }
    
    var updateCell: ((_ at: [IndexPath]) -> Void)?
    var updateCategoriesData: (() -> Void)?
    var updateTrackersData: (() -> Void)?
    var warnCoreDataFailure: (( _ title: String, _ message: String) -> Void)?
    
    init(){
        trackerStore.recordStore = recordStore
        updateCompletedTrackersData()
        updateCategoriesData(withDate: filterByDate, andName: nil, andFilter: .allTrackers)
    }
    
    private func filterStateOfTracker(with trackerId: UUID) -> Bool {
        let trackerStateAtDate = completeTrackerState(for: trackerId, at: filterByDate)
        
        switch trackersFilter {
        case .completedTrackers:
            return trackerStateAtDate.state
        case .incompletedTrackers:
            return !trackerStateAtDate.state
        default:
            return true
        }
    }
}

extension TrackerViewModel: TrackerViewModelProtocol {
    
    func category(at indexPath: IndexPath) -> TrackerCategoryCoreData {
        return categoryStore.resultsController.object(at: indexPath)
    }
    
    func categoryTitle(for section: Int) -> String {
        
        return categories[section].title
    }
    
    func categoryTitleFromTotalList(for row: Int) -> String {
        
        return categoriesTitleList[row]
    }
    
    func completeTracker(with trackerId: UUID, indeed: Bool){
        guard let date = filterByDate.woTime else {
            return
        }
        
        if filterByDate > Date() {
            self.warnCoreDataFailure?("Понятно", "Нельзя отмечать карточку для будущей даты")
            return
        }
        
        let trackerRecord = TrackerRecord(id: trackerId, time: date)
        
        do {
            guard let tracker = trackerStore.getTracker(with: trackerRecord.id) else {
                throw CDErrors.noTrackerFound
            }
            if indeed {
                try recordStore.save(record: trackerRecord, with: tracker)
            } else {
                try recordStore.delete(record: trackerRecord)
            }
            if let indexPath = getIndexPathOfTracker(with: trackerRecord.id) {
                updateCell?([indexPath])
            }
        } catch {
            
            self.warnCoreDataFailure?("Жаль","К сожалению, не удалось отметить статус выполнения трекера :(")
        }
    }
    
    func completeTrackerState(for trackerId: UUID, at date: Date) -> (daysNum: Int, state: Bool) {
        
        var completedDays: Int = 0
        var complete: Bool = false
        
        completedTrackers.forEach {
            if $0.id == trackerId {
                completedDays += 1
                if  Calendar.current.isDate(date, inSameDayAs: $0.time) {
                    complete = true
                }
            }
        }
        return (completedDays, complete)
    }
    
    func createCategory(titledWith title: String) {
        
        categoryStore.create(with: title)
        updateCategoriesData(withDate: filterByDate, andName: filterByName, andFilter: nil)
    }
    
    func deleteCategory(titledWith title: String) {
        
        categoryStore.delete(with: title)
    }
    
    func deleteTracker(with trackerId: UUID){
        do {
            try trackerStore.deleteTracker(with: trackerId)
            updateCategoriesData(withDate: filterByDate, andName: filterByName, andFilter: nil)
        } catch {
            DispatchQueue.main.async {
                self.warnCoreDataFailure?("Жаль", "К сожалению, нам не удалось удалить трекер :(")
            }
        }
    }
    
    func getCategoryOfTracker(with trackerId: UUID) -> String {
        
        return trackerStore.getCategoryOfTracker(with: trackerId) ?? ""
    }
    
    func getIndexPathOfTracker(with trackerId: UUID) -> IndexPath? {
        
        var row: Int = 0, section: Int = 0
        for category in categories {
            for tracker in category.trackers {
                if tracker.id == trackerId {
                    return IndexPath(row: row, section: section)
                }
                row += 1
            }
            row = 0
            section += 1
        }
        return nil
    }
    
    func getTracker(at indexPath: IndexPath) -> Tracker {
        return categories[indexPath.section].trackers[indexPath.row]
    }
    
    func getTracker(with trackerId: UUID) -> Tracker? {
        guard let trackerCoreData = trackerStore.getTracker(with: trackerId) else { return nil }
        
        guard let tracker = trackerStore.transformTrackerCoreData(from: trackerCoreData) else { return nil }
        
        return tracker
    }
    
    // Количество только тех категорий к которым привязаны трекеты
    func numberOfCategories() -> Int {
        return categories.count
    }
    
    // Количество всех категорий, в том числе без привязанных трекеров
    func numberOfCategoriesTotal() -> Int {
        return categoriesTitleList.count
    }
    
    func numberOfItems(in section: Int) -> Int {
        return categories[section].trackers.count
    }
    
    func save(tracker: Tracker, to categoryWithTitle: String) {
        
        let categoryEntity = categoryStore.category(with: categoryWithTitle)
        
        do {
            try trackerStore.save(tracker: tracker, to: categoryEntity)
            updateCategoriesData(withDate: filterByDate, andName: filterByName, andFilter: nil)
        } catch {
            DispatchQueue.main.async {
                self.warnCoreDataFailure?("Жаль", "К сожалению, возникла ошибка при сохранении трекера :(")
            }
        }
    }
    
    func toggleTrackerPin(with trackerId: UUID){
        
        trackerStore.toggleTrackerPin(with: trackerId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success( _ ):
                self.updateCategoriesData(withDate: nil, andName: nil, andFilter: nil)
            case .failure( _ ):
                self.warnCoreDataFailure?("Жаль","К сожалению, не удалось закрепить/открепить трекер :(")
            }
        }
    }
    
    func update(tracker: Tracker, to categoryWithTitle: String) {
        
        let categoryEntity = categoryStore.category(with: categoryWithTitle)
        
        do {
            try trackerStore.update(tracker: tracker, to: categoryEntity)
            updateCategoriesData(withDate: filterByDate, andName: filterByName, andFilter: nil)
        } catch {
            DispatchQueue.main.async {
                self.warnCoreDataFailure?("Жаль", "К сожалению возникла ошибка при обновлении трекера :(")
            }
        }
    }
    
    func updateCategory(fromOld previousTitle: String, toNew title: String){
        
        categoryStore.updateCategory(fromOld: previousTitle, toNew: title)
    }
    
    func updateCategoriesData(withDate date: Date?, andName searchFilter: String?, andFilter: TrackersFilter?) {
        
        if let date = date {
            filterByDate = date
        }
        if let searchFilter = searchFilter {
            filterByName = searchFilter
        }
        if let filter = andFilter {
            trackersFilter = filter
        }
        
        if let categories = categoryStore.getTrackerCategories() {
            
            // Составляем список категорий вне зависимости от привязанных к ним трекеров
            var newCategoriesTitleList: [String] = [String]()
            categories.forEach {
                newCategoriesTitleList.append($0.title)
            }
            categoriesTitleList = newCategoriesTitleList
            
            // Выделяем закреплённые трекеры в отдельную категорию, отфильтровываем категории не содержащие трекеры
            var pinnedTrackers: [Tracker] = [Tracker]()
            var newCategoriesList: [TrackerCategory] = [TrackerCategory]()
            
            categories.forEach { category in
                
                pinnedTrackers.append(contentsOf: category.trackers.filter{ $0.pinned == true && filterStateOfTracker(with: $0.id)})
                let unpinnedTrackers = category.trackers.filter{ $0.pinned == false && filterStateOfTracker(with: $0.id)}
                
                if !unpinnedTrackers.isEmpty {
                    newCategoriesList.append(TrackerCategory(title: category.title, trackers: unpinnedTrackers))
                }
            }
            if !pinnedTrackers.isEmpty {
                newCategoriesList.insert(TrackerCategory(title: "Закрепленные", trackers: pinnedTrackers), at: 0)
            }
            self.categories = newCategoriesList
        }
    }
    
    func updateCompletedTrackersData(){
        if let completedTrackers = recordStore.getTrackerRecords() {
            self.completedTrackers = completedTrackers
        }
    }
}
