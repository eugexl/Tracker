//
//  StatisticsRecordStore.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 09.02.2024.
//

import UIKit
import CoreData

final class StatisticsRecordStore: NSObject {
    
    private weak var viewModel: StatisticsViewModelProtocol?
    private let viewContext: NSManagedObjectContext
    
    lazy var resultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: CoreDataNames.trackerRecordEntityName)
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "time", ascending: true)
        ]
        
        let fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                               managedObjectContext: viewContext,
                                                               sectionNameKeyPath: nil,
                                                               cacheName: nil)
        fetchResultController.delegate = self
        try? fetchResultController.performFetch()
        
        return fetchResultController
    }()
    
    convenience init(viewModel: StatisticsViewModelProtocol) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Возникла ошибка при инициализации AppDelegate")
        }
        self.init(viewContext: appDelegate.persistentContainer.viewContext , viewModel: viewModel)
    }
    
    init(viewContext: NSManagedObjectContext, viewModel: StatisticsViewModelProtocol) {
        self.viewContext = viewContext
        self.viewModel = viewModel
    }
    
    func getTrackerRecords() -> [TrackerRecord]? {
        guard let coreDataRecords = resultsController.fetchedObjects else {
            return nil
        }
        
        var trackerRecords = [TrackerRecord]()
        
        coreDataRecords.forEach { record in
            if let trackerId = record.trackerId, let time = record.time {
                trackerRecords.append( TrackerRecord(id: trackerId, time: time) )
            }
        }
        return trackerRecords
    }
}

extension StatisticsRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        try? controller.performFetch()
        viewModel?.updateCompletedTrackersData()
    }
}
