//
//  TrackerStore.swift
//  Tracker
//
//  Created by Olga Trofimova on 17.12.2024.
//

import UIKit
import CoreData

final class TrackerStore {
    private let context: NSManagedObjectContext
    
    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}
