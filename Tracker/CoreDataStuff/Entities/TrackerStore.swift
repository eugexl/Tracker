//
//  TrackerStore.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 10.01.2024.
//

import UIKit
import CoreData

final class TrackerStore: NSObject {
    
    private weak var viewModel: TrackerViewModelProtocol?
    private let viewContext: NSManagedObjectContext
    
    var recordStore: TrackerRecordStore?
    
    convenience init(viewModel: TrackerViewModel) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Возникла ошибка при инициализации AppDelegate")
        }
        self.init(viewContext: appDelegate.persistentContainer.viewContext, viewModel: viewModel)
    }
    
    init(viewContext: NSManagedObjectContext, viewModel: TrackerViewModel) {
        self.viewContext = viewContext
        self.viewModel = viewModel
    }
    
    func deleteTracker(with trackerId: UUID) throws {
        
        guard let tracker = getTracker(with: trackerId) else {
            throw CDErrors.couldntDeleteTracker
        }
        
        viewContext.delete(tracker)
        try saveContext()
    }
    
    func getCategoryOfTracker(with trackerId: UUID) -> String? {
        
        guard let tracker = getTracker(with: trackerId) else { return nil }
        return tracker.category?.title
    }
    
    func getTracker(with trackerId: UUID) -> TrackerCoreData? {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K = %@",
                                        #keyPath(TrackerCoreData.trackerId), trackerId as CVarArg)
        let tracker = try? viewContext.fetch(request).first
        return tracker
    }
    
    func toggleTrackerPin(with trackerId: UUID, completingHandler: @escaping (Result<Void,Error>) -> Void ) {
        
        guard let tracker = getTracker(with: trackerId) else {
            completingHandler(.failure(CDErrors.noTrackerFound))
            return
        }
        
        tracker.pinned = !tracker.pinned
        
        do {
            try saveContext()
            completingHandler(.success(()))
        } catch {
            completingHandler(.failure(CDErrors.couldntSaveContext))
        }
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
        
        try saveContext()
    }
    
    private func saveContext() throws {
        
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                throw CDErrors.couldntSaveContext
            }
        }
    }
    
    func transformTrackerCoreData(from trackerEntity: TrackerCoreData) -> Tracker? {
        guard let filterDay = viewModel?.filterByDate.weekDay, let scheduleDay = TrackerSchedule(rawValue: filterDay), let filterName = viewModel?.filterByName else {
            return nil
        }
        guard let id = trackerEntity.trackerId,
              let name = trackerEntity.name,
              let color = trackerEntity.color,
              let emoji = trackerEntity.emoji,
              let schedule = trackerEntity.schedule as? Set<TrackerSchedule> else {
            return nil
        }
        
        let pinned = trackerEntity.pinned
        
        if (schedule.isEmpty || schedule.contains(scheduleDay)) &&
            (filterName.count > 0 && name.contains(filterName) ||  filterName.count == 0) {
            
            return Tracker(id: id, name: name, color: color, emoji: emoji, pinned: pinned, schedule: schedule)
        } else {
            return nil
        }
    }
    
    func update(tracker: Tracker, to categoryItem: TrackerCategoryCoreData) throws {
        
        guard let trackerEntity =  getTracker(with: tracker.id) else {
            throw CDErrors.noTrackerFound
        }
        
        trackerEntity.name = tracker.name
        trackerEntity.color = tracker.color
        trackerEntity.emoji = tracker.emoji
        trackerEntity.schedule = tracker.schedule as NSObject
        trackerEntity.category = categoryItem
        
        categoryItem.addToTrackers(trackerEntity)
        
        try saveContext()
    }
}
