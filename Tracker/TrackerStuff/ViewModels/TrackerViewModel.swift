//
//  DataStore.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 21.01.2024.
//

import Foundation

protocol TrackerViewModelProtocol: AnyObject {
    var filterDate: Date { get }
    var filterName: String { get }
    var updateCell: ((_ at: IndexPath) -> Void)? { get set }
    var updateTrackersData: (() -> Void)? { get set }
    var updateCategoriesData: (() -> Void)? { get set }
    var warnFutureCompletion: (() -> Void)? { get set }
    var warnSaveRecordFailure: (() -> Void)? { get set }
    var warnSaveTrackerFailure: (() -> Void)? { get set }
    
    func category(at indexPath: IndexPath) -> TrackerCategoryCoreData
    func categoryTitle(for row: Int) -> String
    func completeTracker(with id: UUID, indeed: Bool)
    func completeTrackerState(for trackerId: UUID, at date: Date) -> (Int, Bool)
    func createCategory(titledWith title: String)
    func getTracker(at: IndexPath) -> Tracker
    func numberOfItems(in section: Int) -> Int
    func numberOfCategories() -> Int
    func save(tracker: Tracker, to categoryWithTitle: String)
    func updateCategoriesData(with date: Date?, and searchfilter: String?)
    func updateCompletedTrackersData()
}

final class TrackerViewModel {
    
    private lazy var trackerStore: TrackerStore = TrackerStore(viewModel: self)
    private lazy var categoryStore: TrackerCategoryStore = TrackerCategoryStore(viewModel: self, trackerStore: trackerStore)
    private lazy var recordStore: TrackerRecordStore = TrackerRecordStore(viewModel: self)
    
    private var categories: [TrackerCategory] = [TrackerCategory]() {
        didSet {
            self.updateCategoriesData?()
            self.updateTrackersData?()
        }
    }
    private var completedTrackers: [TrackerRecord] = [TrackerRecord]()
    
    var filterDate: Date = Date()
    var filterName: String = ""
    
    var updateCell: ((_ at: IndexPath) -> Void)?
    var updateCategoriesData: (() -> Void)?
    var updateTrackersData: (() -> Void)?
    var warnFutureCompletion: (() -> Void)?
    var warnSaveRecordFailure: (() -> Void)?
    var warnSaveTrackerFailure: (() -> Void)?
    
    init(){
        trackerStore.recordStore = recordStore
        updateCategoriesData(with: filterDate, and: nil)
        updateCompletedTrackersData()
    }
}

extension TrackerViewModel: TrackerViewModelProtocol {
    
    func category(at indexPath: IndexPath) -> TrackerCategoryCoreData {
        return categoryStore.resultsController.object(at: indexPath)
    }
    
    func categoryTitle(for row: Int) -> String {
        
        return categories[row].title
    }
    
    func completeTracker(with trackerId: UUID, indeed: Bool){
        guard let date = filterDate.woTime else {
            return
        }
        
        if filterDate > Date() {
            warnFutureCompletion?()
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
                updateCell?(indexPath)
            }
        } catch {
            warnSaveRecordFailure?()
        }
    }
    
    func completeTrackerState(for trackerId: UUID, at date: Date) -> (Int, Bool) {
        
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
    
    func numberOfCategories() -> Int {
        return categories.count
    }
    
    func numberOfItems(in section: Int) -> Int {
        return categories[section].trackers.count
    }
    
    func save(tracker: Tracker, to categoryWithTitle: String) {
        
        let categoryItem = categoryStore.category(with: categoryWithTitle)
        
        do {
            try trackerStore.save(tracker: tracker, to: categoryItem)
            updateCategoriesData(with: filterDate, and: filterName)
        } catch {
            DispatchQueue.main.async {
                self.warnSaveTrackerFailure?()
            }
        }
    }
    
    func updateCategoriesData(with date: Date?, and searchFilter: String? ) {
        
        if let date = date {
            filterDate = date
        }
        if let searchFilter = searchFilter {
            filterName = searchFilter
        }
        
        if let categories = categoryStore.getTrackerCategories() {
            self.categories = categories
        }
    }
    
    func updateCompletedTrackersData(){
        if let completedTrackers = recordStore.getTrackerRecords() {
            self.completedTrackers = completedTrackers
        }
    }
}


