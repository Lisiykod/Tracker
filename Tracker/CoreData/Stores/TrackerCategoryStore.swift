//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Olga Trofimova on 17.12.2024.
//

import CoreData

final class TrackerCategoryStore: NSObject {
    
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    private enum TrackerCategoryStoreError: Error {
        case decodingError
    }
    
    private let context: NSManagedObjectContext
    private let trackerStore = TrackerStore()
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        self.fetchedResultsController = controller
        try? controller.performFetch()
        return controller
    }()
    
    // MARK: - Initializers
    
    convenience override init() {
        let context = DataBaseService.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Public Methods
    
    func addCategory(_ category: TrackerCategory) {
        let trackerCategory = TrackerCategoryCoreData(context: context)
        guard let categoryFetch = fetchedResultsController.fetchedObjects else {
            return
        }
        
        guard !categoryFetch.contains(where: { $0.title == category.title }) else {
            return
        }
        
        trackerCategory.title = category.title
        trackerCategory.trackers = []
        
        DataBaseService.shared.saveContext()
    }
    
    func fetchCategories() throws -> [TrackerCategory] {
        guard let object = fetchedResultsController.fetchedObjects,
              let categories = try? object.map({ try getCategory(from: $0)})
        else {
            return []
        }
        return categories
    }
    
    func addTrackerToCategory(_ tracker: Tracker, category title: String) {
        let tracker = trackerStore.addTracker(tracker)
        let category = fetchedResultsController.fetchedObjects?.first(where: {$0.title == title} )
        category?.addToTrackers(tracker)
        DataBaseService.shared.saveContext()
    }
    
    func deleteTrackerFromCategory(_ tracker: Tracker)  {
        trackerStore.deleteTracker(tracker: tracker)
        DataBaseService.shared.saveContext()
    }
    
    func deleteCategory(_ title: String) {
        guard let fetchCategory = fetchedResultsController.fetchedObjects?.first(where: {$0.title == title}) else {
            return
        }
        context.delete(fetchCategory)
        DataBaseService.shared.saveContext()
    }
    
    func updateCategory(_ title: String, newTitle: String) {
        let fetchedCategories = fetchedResultsController.fetchedObjects
        guard let fetchCategory = fetchedCategories?.first(where: {$0.title == title}) else {
            return
        }
        fetchCategory.title = newTitle
        DataBaseService.shared.saveContext()
    }
    
    // MARK: - Private Methods
    
    private func getCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = trackerCategoryCoreData.title,
              let trackersFromCoreData = trackerCategoryCoreData.trackers else {
            throw TrackerCategoryStoreError.decodingError
        }
        
        let trackers = try trackersFromCoreData.compactMap { tracker -> Tracker? in
            guard let trackerCoreData = tracker as? TrackerCoreData else {
                throw TrackerCategoryStoreError.decodingError
            }
            
            do {
                let tracker = try trackerStore.getTracker(from: trackerCoreData)
                return tracker
            } catch {
                print("\(error.localizedDescription)")
                return nil
            }
        }
        
        return TrackerCategory(title: title, trackers: trackers)
    }
    
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
   func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
    }
}
