//
//  DataStore.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 21.01.2024.
//

import UIKit
import Combine

protocol DataProviderProtocol {
    func category(at indexPath: IndexPath) -> TrackerCategoryCoreData
    func completeTracker(with: TrackerRecord, indeed: Bool) throws -> IndexPath?
    func completeTrackerState(for trackerId: UUID, at date: Date) -> (Int, Bool)
    func getTracker(at: IndexPath) -> Tracker
    func numberOfItems(in section: Int) -> Int
    func numberOfSections() -> Int
    func save(tracker: Tracker, to categoryWithTitle: String, completionHandler: @escaping (Result<Void, Error>) -> Void)
    func updateCollectionData(with date: Date, and searchfilter: String?, completionHandler: (() -> Void)?)
}

final class DataProvider {
    
    private lazy var trackerStore: TrackerStore = TrackerStore(dataProvider: self)
    private lazy var categoryStore: TrackerCategoryStore = TrackerCategoryStore(dataProvider: self, trackerStore: trackerStore)
    private lazy var recordStore: TrackerRecordStore = TrackerRecordStore(dataProvider: self)
    
    var categories: [TrackerCategory] = [TrackerCategory]()
    var completedTrackers: [TrackerRecord] = [TrackerRecord]()
    var filterDay: Int = 0
    var filterName: String = ""
    
    init(){
        
        trackerStore.recordStore = recordStore
        
        updateCollectionData(with: Date(), and: nil, completionHandler: nil)
        updateCompletedTrackersData()
    }
}

extension DataProvider: DataProviderProtocol {
    
    func category(at indexPath: IndexPath) -> TrackerCategoryCoreData {
        
        return categoryStore.resultsController.object(at: indexPath)
    }
    
    func completeTracker(with trackerRecord: TrackerRecord, indeed: Bool) throws -> IndexPath? {
        do {
            guard let tracker = trackerStore.getTracker(with: trackerRecord.id) else {
                throw CDErrors.noTrackerFound
            }
            
            if indeed {
                try recordStore.save(record: trackerRecord, with: tracker)
            } else {
                try recordStore.delete(record: trackerRecord)
            }
            return getIndexPathOfTracker(with: trackerRecord.id)
            
        } catch {
            
            throw CDErrors.cannotSaveContext
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
    
    func getIndexPathOfTracker(with trackerId: UUID) -> IndexPath? {
        
        var row: Int = 0, section: Int = 0
        
        for category in categories {
            
            for tracker in category.trackers {
                if tracker.id == trackerId {
                    
                    return IndexPath(row: row, section: section)
                }
                row += 1
            }
            section += 1
        }
        
        return nil
    }
    
    func getTracker(at indexPath: IndexPath) -> Tracker {
        
        return self.categories[indexPath.section].trackers[indexPath.row]
    }
    
    func numberOfSections() -> Int {
        
        return categories.count
    }
    
    func numberOfItems(in section: Int) -> Int {
        
        return categories[section].trackers.count
    }
    
    func save(tracker: Tracker, to categoryWithTitle: String, completionHandler: @escaping (Result<Void,Error>) -> Void) {
        
        let categoryItem = self.categoryStore.caregory(with: categoryWithTitle)
        
        do {
            try self.trackerStore.save(tracker: tracker, to: categoryItem)
            completionHandler(.success(()))
        } catch {
            completionHandler(.failure(error))
        }
    }
    
    func updateCollectionData(with date: Date, and searchFilter: String?, completionHandler: (() -> Void)? ) {
        
        guard let day = Calendar.current.dateComponents([.weekday], from: date).weekday else {
            return
        }
        
        filterDay = day
        filterName = searchFilter ?? ""
        
        if let categories = categoryStore.getTrackerCategories() {
            
            self.categories = categories
            completionHandler?()
        }
    }
    
    func updateCompletedTrackersData(){
        
        if let completedTrackers = recordStore.getTrackerRecords() {
            
            self.completedTrackers = completedTrackers
        }
    }
}
