//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Olga Trofimova on 17.12.2024.
//

import UIKit
import CoreData

enum TrackerRecordStoreError: Error {
    case decodingError
}

final class TrackerRecordStore {
    
    private let context: NSManagedObjectContext
    
    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addRecord(_ record: TrackerRecord) {
        let trackerRecord = TrackerRecordCoreData(context: context)
        trackerRecord.date = record.date
        trackerRecord.id = record.id
        saveContext()
    }
    
    func fetchRecords() -> Set<TrackerRecord> {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        let trackerRecordsFromCoreData = try? context.fetch(request)
        guard let trackerRecordsFromCoreData else {
            return Set()
        }
        let trackerRecords = try? trackerRecordsFromCoreData.map ({ try getRecord(from: $0) })
        return Set(trackerRecords ?? [])
    }
    
    func deleteRecord(_ record: TrackerRecord) {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.predicate = NSPredicate(format: "id == %@ AND date == %@", record.id as CVarArg, record.date as CVarArg)
        let trackerRecordsFromCoreData = try? context.fetch(request)
        if let recordForRemove = trackerRecordsFromCoreData?.first {
            context.delete(recordForRemove)
            saveContext()
        }
    }
    
    func getRecord(from trackerRecordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let id = trackerRecordCoreData.id,
              let date = trackerRecordCoreData.date else {
            throw TrackerRecordStoreError.decodingError
        }
        
        let trackerRecord = TrackerRecord(id: id, date: date)
        return trackerRecord
    }
    
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
