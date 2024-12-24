//
//  TrackerStore.swift
//  Tracker
//
//  Created by Olga Trofimova on 17.12.2024.
//

import UIKit
import CoreData

enum TrackerStoreError: Error {
    case decodingError
}

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private let colorMarshalling = UIColorMarshalling()
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCoreData.title, ascending: true)]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: #keyPath(TrackerCategoryCoreData.title),
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
    
    func addTracker(_ tracker: Tracker) -> TrackerCoreData {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.title = tracker.title
        trackerCoreData.id = tracker.id
        trackerCoreData.color = colorMarshalling.hexString(from: tracker.color)
        trackerCoreData.isHabit = tracker.isHabit
        trackerCoreData.schedule = tracker.schedule as NSObject
        trackerCoreData.emoji = tracker.emoji
        saveContext()
        return trackerCoreData
    }
    
    func fetchTrackers() -> [Tracker] {
        guard let object = fetchedResultsController.fetchedObjects,
              let tracker = try? object.map ({ try getTracker(from: $0)})
        else { return [] }
        return tracker
    }
    
    func getTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = trackerCoreData.id,
              let title = trackerCoreData.title,
              let color = trackerCoreData.color,
              let emoji = trackerCoreData.emoji,
              let schedule = trackerCoreData.schedule as? [WeekDay] else {
            throw TrackerStoreError.decodingError
        }
        return Tracker(
            id: id,
            title: title,
            color: colorMarshalling.color(from: color),
            emoji: emoji,
            schedule: schedule,
            isHabit: trackerCoreData.isHabit
        )
    }
    
    // TODO: - Добавить функцию удаления трекера
    
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

extension TrackerStore: NSFetchedResultsControllerDelegate {

}
