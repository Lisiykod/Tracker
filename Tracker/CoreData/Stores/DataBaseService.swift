//
//  DataBaseStore.swift
//  Tracker
//
//  Created by Olga Trofimova on 26.12.2024.
//

import CoreData

final class DataBaseService {
    
    static let shared = DataBaseService()
    
    // MARK: - Core Data stack
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Load Persistent Store failed: \(error), \(error.userInfo)")
            }
        })
        
        return container
    }()
    
    // MARK: - Initializers
    
    private init() {}
    
    // MARK: - Core Data saving support
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error.localizedDescription)")
                context.rollback()
            }
        }
    }
}
