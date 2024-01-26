//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 10.01.2024.
//

import UIKit
import CoreData

final class TrackerRecordStore: NSObject {
    
    private let dataProvider: DataProvider
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
    
    convenience init(dataProvider: DataProvider) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(viewContext: context, provider: dataProvider)
    }
    
    init(viewContext: NSManagedObjectContext, provider: DataProvider) {
        
        self.viewContext = viewContext
        self.dataProvider = provider
    }
    
    func delete(record: TrackerRecord) throws {
        
        if let trackerRecord = getRecordCoreData(with: record.id, and: record.time) {
            
            viewContext.delete(trackerRecord)
            try saveContext()
        }
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
    
    func getRecordCoreData(with trackerId: UUID, and date: Date) -> TrackerRecordCoreData? {
        
        let request = TrackerRecordCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(
            format: "%K = %@ AND %K = %@",
            #keyPath(TrackerRecordCoreData.trackerId), trackerId as CVarArg,
            #keyPath(TrackerRecordCoreData.time), date as CVarArg)
        
        let trackerRecord = try? viewContext.fetch(request).first
        return trackerRecord
        
    }
    
    func save(record: TrackerRecord, with tracker: TrackerCoreData) throws {
        
        let recordEntity = TrackerRecordCoreData(context: viewContext)
        
        recordEntity.trackerId = record.id
        recordEntity.time = record.time
        
        recordEntity.tracker = tracker
        
        tracker.addToTrackerRecords(recordEntity)
        
        do{
            try saveContext()
        } catch {
            throw error
        }
    }
    
    func saveContext() throws {
        if viewContext.hasChanges {
            do{
                try viewContext.save()
            } catch {
                throw CDErrors.cannotSaveContext
            }
        }
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        try? controller.performFetch()
        dataProvider.updateCompletedTrackersData()
    }
}
