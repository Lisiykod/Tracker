//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Olga Trofimova on 17.12.2024.
//

import UIKit
import CoreData


final class TrackerRecordStore {
    
    private enum TrackerRecordStoreError: Error {
        case decodingError
    }
    
    private let context: NSManagedObjectContext
    
    // MARK: - Initializers
    
    convenience init() {
        let context = DataBaseService.shaired.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Public Methods
    
    func addRecord(_ record: TrackerRecord) {
        let trackerRecord = TrackerRecordCoreData(context: context)
        trackerRecord.date = record.date
        trackerRecord.id = record.id
        DataBaseService.shaired.saveContext()
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
        if let recordForDelete = trackerRecordsFromCoreData?.first {
            context.delete(recordForDelete)
            DataBaseService.shaired.saveContext()
        }
    }
    
    // MARK: - Private Methods
    
    private func getRecord(from trackerRecordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let id = trackerRecordCoreData.id,
              let date = trackerRecordCoreData.date else {
            throw TrackerRecordStoreError.decodingError
        }
        
        let trackerRecord = TrackerRecord(id: id, date: date)
        return trackerRecord
    }
    
}
