//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Eugene Dmitrichenko on 10.01.2024.
//

import UIKit
import CoreData

final class TrackerCategoryStore: NSObject  {
    
    private weak var dataProvider: DataProvider?
    private weak var trackerStore: TrackerStore?
    private let viewContext: NSManagedObjectContext
    
    lazy var resultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: CoreDataNames.trackerCategoryEntityName)
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]
        
        let fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                               managedObjectContext: viewContext,
                                                               sectionNameKeyPath: "title",
                                                               cacheName: nil)
        fetchResultController.delegate = self
        try? fetchResultController.performFetch()
        return fetchResultController
    }()
    
    convenience init(dataProvider: DataProvider, trackerStore: TrackerStore) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Возникла ошибка при инициализации AppDelegate")
        }
        self.init(viewContext: appDelegate.persistentContainer.viewContext, provider: dataProvider, trackerStore: trackerStore)
    }
    
    init(viewContext: NSManagedObjectContext, provider: DataProvider, trackerStore: TrackerStore) {
        self.viewContext = viewContext
        self.dataProvider = provider
        self.trackerStore = trackerStore
    }
    
    func category(with title: String) -> TrackerCategoryCoreData {
        if let categoryItem = resultsController.fetchedObjects?.filter( { $0.title == title }).first {
            return categoryItem
        } else {
            let categoryItem = TrackerCategoryCoreData(context: viewContext)
            categoryItem.title = title
            saveContext()
            return categoryItem
        }
    }
    
    func getTrackerCategories() -> [TrackerCategory]? {
        guard let coreDataCategories = resultsController.fetchedObjects else {
            return nil
        }
        
        var categories: [TrackerCategory] = []
        
        coreDataCategories.forEach { trackerCategoryEntity in
            if let trackerCategory = transformTrackerCategoryCoreData(from: trackerCategoryEntity) {
                categories.append(trackerCategory)
            }
        }
        return categories
    }
    
    private func saveContext(){
        if viewContext.hasChanges {
            try? viewContext.save()
        }
    }
    
    private func transformTrackerCategoryCoreData(from trackerCategoryEntity: TrackerCategoryCoreData) -> TrackerCategory? {
        guard let title = trackerCategoryEntity.title, let trackersSet = trackerCategoryEntity.trackers as? Set<TrackerCoreData> else {
            return nil
        }
        var trackers = [Tracker]()
        trackersSet.forEach { trackerEntity in
            if let tracker = trackerStore?.transformTrackerCoreData(from: trackerEntity) {
                trackers.append(tracker)
            }
        }
        trackers.sort { $0.name < $1.name }
        return TrackerCategory(title: title, trackers: trackers)
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) { }
}
