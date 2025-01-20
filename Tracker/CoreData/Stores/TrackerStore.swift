//
//  TrackerStore.swift
//  Tracker
//
//  Created by Olga Trofimova on 17.12.2024.
//

import CoreData


final class TrackerStore: NSObject {
    
    private enum TrackerStoreError: Error {
        case decodingError
    }
    
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
    
    // MARK: - Initializers
    
    convenience override init() {
        let context = DataBaseService.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Public Methods
    
    func addTracker(_ tracker: Tracker) -> TrackerCoreData {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.title = tracker.title
        trackerCoreData.id = tracker.id
        trackerCoreData.color = colorMarshalling.hexString(from: tracker.color)
        trackerCoreData.isHabit = tracker.isHabit
        trackerCoreData.schedule = tracker.schedule as NSObject
        trackerCoreData.emoji = tracker.emoji
        DataBaseService.shared.saveContext()
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
    
    func deleteTracker(tracker: Tracker) {
        guard let fetchTracker = fetchedResultsController.fetchedObjects?.first(where: {$0.id == tracker.id}) else {
            return
        }
        context.delete(fetchTracker)
    }
    
}

extension TrackerStore: NSFetchedResultsControllerDelegate {

}
