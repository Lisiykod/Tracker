//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Olga Trofimova on 17.12.2024.
//

import UIKit
import CoreData

enum TrackerCategoryStoreError: Error {
    case decodingError
}

final class TrackerCategoryStore: NSObject {
    
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
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
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addCategory(_ category: TrackerCategory) {
        let trackerCategory = TrackerCategoryCoreData(context: context)
        guard let categoryFetch = fetchedResultsController.fetchedObjects else {
            return
        }
        
        let isContainsSameTitle = categoryFetch.contains { _ in
            trackerCategory.title != category.title
        }
        
        if !isContainsSameTitle {
            trackerCategory.title = category.title
            trackerCategory.trackers = []
        }
        
        saveContext()
    }
    
    func getCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = trackerCategoryCoreData.title else {
            throw TrackerCategoryStoreError.decodingError
        }
        guard let trackersFromCoreData = trackerCategoryCoreData.trackers else {
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
        saveContext()
    }
    
    // TODO: - добавить метод удаления категории
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("\(#file): \(#function): Error saving context: \(error.localizedDescription)")
                context.rollback()
            }
        }
    }
    
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        //  TODO: - добавить обновление таблицы при добавлении новой категории
    }
}