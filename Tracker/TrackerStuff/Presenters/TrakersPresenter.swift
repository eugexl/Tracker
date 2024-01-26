//
//  TrakersViewModel.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 20.12.2023.
//

// MARK: Временно используем UIKit для применения мокковых данных
import Foundation
//import UIKit

protocol TrackersPresenterProtocol {
    
    var view: TrackersViewControllerProtocol? { get set }
    func viewDidLoad()
    func completeTracker(with id: UUID, indeed: Bool)
    func createTracker(type: TrackerType)
    func save(tracker: Tracker, to categoryWithTitle: String)
    func updateCollection(withRecords: Bool)
}

final class TrackersPresenter: TrackersPresenterProtocol {
    
    weak var view: TrackersViewControllerProtocol?
    
    private let dataProvider: DataProviderProtocol
    
    func viewDidLoad(){
        
    }
    
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
        
        dataProvider.save(tracker: tracker, to: categoryWithTitle){ result in
            switch result {
            case .success( _ ):
                guard let view = self.view else {
                    return
                }
                self.dataProvider.updateCollectionData(with: view.currentDate, and: view.searchTrackerName) {
                    view.updateTrackersData()
                }
            case .failure( _ ):
                
                DispatchQueue.main.async {
                    self.view?.warnSaveTrackerFailure()
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
