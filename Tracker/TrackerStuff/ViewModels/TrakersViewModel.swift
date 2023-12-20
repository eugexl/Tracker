//
//  TrakersViewModel.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 20.12.2023.
//

// MARK: Временно используем UIKit для применения мокковых данных
// import Foundation
import UIKit

protocol TrackersViewModelProtocol {
    
    var view: TrackersViewControllerProtocol? { get set }
    func viewDidLoad()
    func completeTracker(with id: UUID, indeed: Bool)
    func createTracker(type: TrackerType)
    func save(tracker: Tracker, to category: String)
    func updateCollection(withRecords: Bool)
}

class TrackersViewModel: TrackersViewModelProtocol {
    
    weak var view: TrackersViewControllerProtocol?
    
    private let trackerStorage: TrackerStorageProtocol = TrackerStorageTemp.shared
    
    func viewDidLoad(){
       
        // Добавляем тестовые данные для наглядности
        if UserDefaults.standard.object(forKey: "TrackerCategories") == nil {
            
            trackerStorage.save(categories: mockCategories)
        }
        
        updateCollection(withRecords: true)
    }
    
    
    func completeTracker(with trackerId: UUID, indeed: Bool){
        
        guard let view = view else {
            return
        }
        
        if view.currentDate > Date() {
            
            view.warnFutureCompletion()
            return
        }
        
        let trackerRecord = TrackerRecord(id: trackerId, time: view.currentDate)
        let completedTracers = trackerStorage.completeTracker(with: trackerRecord, indeed: indeed)
        
        view.updateTrackersData(with: nil, and: completedTracers)
    }
    
    func createTracker(type: TrackerType){
        
        view?.newTrackerViewControllerPresenting(type: type)
    }
    
    func save(tracker: Tracker, to category: String){
        
        trackerStorage.add(tracker: tracker, to: category)
        updateCollection()
    }
    
    func updateCollection(withRecords: Bool = false){
        
        guard let view = view, let day = Calendar.current.dateComponents([.weekday], from: view.currentDate).weekday else {
            return // ToDo Warning
        }
        
        let categories = trackerStorage.getCategories(by: day)
        let records = withRecords ? trackerStorage.getCompletedTrackers() : nil
        
        view.updateTrackersData(with: categories, and: records)
    }
    
    // MARK: Тестовые данные
    var mockCategories: [TrackerCategory] = [
        TrackerCategory(title: "Category One", trackers: [
            Tracker(id: UUID(), name: "Tracker One in Category One", color: ColorNames.colorSlection1 , emoji: "😝", schedule: [.sunday, .monday]),
            Tracker(id: UUID(), name: "Tracker Two in Category One", color: ColorNames.colorSlection2, emoji: "😐", schedule: [.sunday, .tuesday]),
            Tracker(id: UUID(), name: "Tracker Three in Category One", color: ColorNames.colorSlection3, emoji: "🫢", schedule: [.tuesday, .thursday])
        ]),
        TrackerCategory(title: "Category Two", trackers: [
            Tracker(id: UUID(), name: "Tracker One in Category Two", color: ColorNames.colorSlection4, emoji: "😒", schedule: [.wednesday]),
            Tracker(id: UUID(), name: "Tracker Two in Category Two", color: ColorNames.colorSlection5, emoji: "😷", schedule: [.wednesday, .thursday]),
            Tracker(id: UUID(), name: "Tracker Three in Category Two", color: ColorNames.colorSlection6, emoji: "😴", schedule: [.monday, .tuesday, .wednesday, .thursday]),
            Tracker(id: UUID(), name: "Tracker Three in Category Two", color: ColorNames.colorSlection7, emoji: "🤫", schedule: [.sunday,.monday,.tuesday,.wednesday,.thursday,.saturday])
        ])
    ]
}
