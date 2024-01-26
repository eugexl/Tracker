//
//  TrackerStore.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 10.01.2024.
//

import UIKit
import CoreData

final class TrackerStore: NSObject {
    
    private let dataProvider: DataProvider
    private let viewContext: NSManagedObjectContext
    
    var recordStore: TrackerRecordStore?
    
    convenience init(dataProvider: DataProvider) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(viewContext: context, provider: dataProvider)
    }
    
    init(viewContext: NSManagedObjectContext, provider: DataProvider) {
        self.viewContext = viewContext
        self.dataProvider = provider
    }
    
    func getTracker(with id: UUID) -> TrackerCoreData? {
        let request = TrackerCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K = %@",
                                        #keyPath(TrackerCoreData.trackerId), id as CVarArg)
        
        let tracker = try? viewContext.fetch(request).first
        return tracker
    }
    
    func save(tracker: Tracker, to categoryItem: TrackerCategoryCoreData) throws {
        
        let trackerEntity = TrackerCoreData(context: viewContext)
        
        trackerEntity.trackerId = tracker.id
        trackerEntity.color = tracker.color
        trackerEntity.name = tracker.name
        trackerEntity.emoji = tracker.emoji
        trackerEntity.schedule = tracker.schedule as NSObject
        trackerEntity.category = categoryItem
        
        categoryItem.addToTrackers(trackerEntity)
        
        do {
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
                throw error
            }
        }
    }
    
    func transformTrackerCoreData(from trackerEntity: TrackerCoreData) -> Tracker? {
        
        guard let scheduleDay = TrackerSchedule(rawValue: dataProvider.filterDay) else {
            return nil
        }
        
        let filterName = dataProvider.filterName
        
        guard let id = trackerEntity.trackerId,
              let name = trackerEntity.name,
              let emoji = trackerEntity.emoji,
              let color = trackerEntity.color,
              let schedule = trackerEntity.schedule as? Set<TrackerSchedule> else {
            return nil
        }
        
        if (schedule.isEmpty || schedule.contains(scheduleDay)) &&
            (filterName.count > 0 && name.contains(filterName) ||  filterName.count == 0) {
            
            return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
        } else {
            return nil
        }
    }
}
