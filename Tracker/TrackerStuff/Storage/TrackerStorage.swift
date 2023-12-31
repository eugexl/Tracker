//
//  TrackerStorage.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 20.12.2023.
//

import Foundation

protocol TrackerStorageProtocol {
    
    func add(tracker: Tracker, to categoryTitle: String)
    func completeTracker(with tracker: TrackerRecord, indeed: Bool) -> [TrackerRecord]
    func getCategories(by day: Int?, and searchFilter: String?) -> [TrackerCategory]
    func getCompletedTrackers() -> [TrackerRecord]
    func save(categories: [TrackerCategory])
}

final class TrackerStorageTemp: TrackerStorageProtocol {
    
    static let shared = TrackerStorageTemp()
    
    private let categoriesKey = "TrackerCategories"
    private let completedTrackersKey = "CompletedTrackers"
    
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    func add(tracker: Tracker, to categoryTitle: String){
        
        let categories = getCategories(by: nil)
        var newCategoriesArray: [TrackerCategory] = [TrackerCategory]()
        var additionDone = false
        
        categories.forEach {
            var trackers = $0.trackers
            if $0.title == categoryTitle {
                trackers.append(tracker)
                additionDone = true
            }
            let newCategory: TrackerCategory = TrackerCategory(title: $0.title, trackers: trackers)
            newCategoriesArray.append(newCategory)
        }
        
        if !additionDone {
            let newCategory = TrackerCategory(title: categoryTitle, trackers: [tracker])
            
            newCategoriesArray.append(newCategory)
        }
        
        save(categories: newCategoriesArray)
    }
    
    func completeTracker(with tracker: TrackerRecord, indeed: Bool) -> [TrackerRecord] {
        
        var completedTrackers = getCompletedTrackers()
        
        if indeed {
            
            completedTrackers.append(tracker)
        } else {
            
            completedTrackers = completedTrackers.filter{
                !($0.id == tracker.id && Calendar.current.isDate($0.time, equalTo: tracker.time, toGranularity: .day))
            }
        }
        
        save(completedTrackers: completedTrackers)
        return completedTrackers
    }
    
    func deleteCategory(with name: String){
        
    }
    
    func getCategories(by day: Int?, and searchFilter: String? = nil) -> [TrackerCategory] {
        
        guard let AllCategoriesJSONData = userDefaults.object(forKey: categoriesKey) as? Data else {
            
            return [TrackerCategory]()
        }
        
        
        do {
            let AllCategories = try JSONDecoder().decode([TrackerCategory].self, from: AllCategoriesJSONData)
            
            if let day = day {
                
                var byDayCategories = [TrackerCategory]()
                
                AllCategories.forEach { category in
                    
                    guard let scheduleDay = TrackerSchedule(rawValue: day) else {
                        return
                    }
                    
                    let searchFilterUnwrapped: String = searchFilter ?? ""
                    
                    let trackers = category.trackers.filter {
                        
                        ($0.schedule.isEmpty || $0.schedule.contains(scheduleDay)) && (searchFilterUnwrapped.count > 0 && $0.name.contains(searchFilterUnwrapped) ||  searchFilterUnwrapped.count == 0)
                    }
                    if trackers.count > 0 {
                        byDayCategories.append(TrackerCategory(title: category.title, trackers: trackers))
                    }
                }
                
                return byDayCategories
                
            } else {
                
                return AllCategories
            }
            
        } catch {
            // TODO: В следующей весрии приложения отработать ошибку кодировки
        }
        
        return [TrackerCategory]()
    }
    
    func getCompletedTrackers() -> [TrackerRecord] {
        
        guard let completedTrackersJSONData = userDefaults.object(forKey: completedTrackersKey) as? Data else {
            return [TrackerRecord]()
        }
        
        do {
            
            let completedTrackers = try JSONDecoder().decode([TrackerRecord].self, from: completedTrackersJSONData)
            return completedTrackers
            
        } catch {
            
            return [TrackerRecord]()
        }
    }
    
    func save(categories: [TrackerCategory]) {
        
        do {
            let json = try JSONEncoder().encode(categories)
            userDefaults.set(json, forKey: categoriesKey)
        } catch {
            // TODO: В следующей весрии приложения отработать ошибку кодировки
        }
    }
    
    func save(completedTrackers: [TrackerRecord]){
        
        do {
            let json = try JSONEncoder().encode(completedTrackers)
            userDefaults.set(json, forKey: completedTrackersKey)
        } catch {
            // TODO: В следующей весрии приложения отработать ошибку кодировки
        }
    }
}
