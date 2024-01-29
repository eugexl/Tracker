//
//  TrakersViewModel.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 20.12.2023.
//

import Foundation

protocol TrackersPresenterProtocol {
    
    var view: TrackersViewControllerProtocol? { get set }
    func completeTracker(with id: UUID, indeed: Bool)
    func createTracker(type: TrackerType)
    func save(tracker: Tracker, to categoryWithTitle: String)
    func updateCollection(withRecords: Bool)
}

final class TrackersPresenter: TrackersPresenterProtocol {
    
    weak var view: TrackersViewControllerProtocol?
    
    private let dataProvider: DataProviderProtocol
    
    init(provider: DataProviderProtocol){
        self.dataProvider = provider
    }
    
    func completeTracker(with trackerId: UUID, indeed: Bool){
        guard let view = view, let date = view.currentDate.woTime else {
            return
        }
        if view.currentDate > Date() {
            view.warnFutureCompletion()
            return
        }
        
        let trackerRecord = TrackerRecord(id: trackerId, time: date)
        
        do {
            if let indexPath = try dataProvider.completeTracker(with: trackerRecord, indeed: indeed) {
                view.updateCell(at: indexPath)
            }
        } catch {
            view.warnSaveRecordFailure()
        }
    }
    
    func createTracker(type: TrackerType){
        view?.newTrackerViewControllerPresenting(type: type)
    }
    
    func save(tracker: Tracker, to categoryWithTitle: String) {
        dataProvider.save(tracker: tracker, to: categoryWithTitle){ [weak self] result in
            
            guard let self = self else { return }
            guard let view = self.view else { return }
            
            switch result {
            case .success( _ ):
                self.dataProvider.updateCollectionData(with: view.currentDate, and: view.searchTrackerName) {
                    view.updateTrackersData()
                }
            case .failure( _ ):
                DispatchQueue.main.async { 
                    view.warnSaveTrackerFailure()
                }
            }
        }
    }
    
    func updateCollection(withRecords: Bool = false) {
        guard let view = view else {
            return
        }
        dataProvider.updateCollectionData(with: view.currentDate, and: view.searchTrackerName) {
            view.updateTrackersData()
        }
    }
}
