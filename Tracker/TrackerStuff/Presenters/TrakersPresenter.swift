//
//  TrakersViewModel.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 20.12.2023.
//

// MARK: Временно используем UIKit для применения мокковых данных
// import Foundation
import UIKit

protocol TrackersPresenterProtocol {
    
    var view: TrackersViewControllerProtocol? { get set }
    func viewDidLoad()
    func completeTracker(with id: UUID, indeed: Bool)
    func createTracker(type: TrackerType)
    func save(tracker: Tracker, to category: String)
    func updateCollection(withRecords: Bool, and searchFilter: String?)
}

final class TrackersPresenter: TrackersPresenterProtocol {
    
    weak var view: TrackersViewControllerProtocol?
    
    private let trackerStorage: TrackerStorageProtocol = TrackerStorageTemp.shared
    
    func viewDidLoad(){
        
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
    
    func updateCollection(withRecords: Bool = false, and searchFilter: String? = nil){
        
        guard let view = view, let day = Calendar.current.dateComponents([.weekday], from: view.currentDate).weekday else {
            return // ToDo Warning
        }
        
        let categories = trackerStorage.getCategories(by: day, and: searchFilter)
        let records = withRecords ? trackerStorage.getCompletedTrackers() : nil
        
        view.updateTrackersData(with: categories, and: records)
    }
}
