//
//  UserDefaultsService.swift
//  Tracker
//
//  Created by Olga Trofimova on 06.01.2025.
//

import Foundation

final class UserDefaultsService {
    static let shared = UserDefaultsService()
    
    private let storage = UserDefaults.standard
    
    private enum Keys: String {
        case launchKey = "isFirstLaunch"
        case selectedFilterKey = "selectedFilter"
    }
    
    private var isFirstLaunch: Bool {
        get {
            storage.bool(forKey: Keys.launchKey.rawValue)
        }
        
        set {
            storage.set(newValue, forKey: Keys.launchKey.rawValue)
        }
    }
    
    private(set) var selectedFilter: String? {
        get {
            storage.string(forKey: Keys.selectedFilterKey.rawValue)
        }
        
        set {
            storage.set(newValue, forKey: Keys.selectedFilterKey.rawValue)
        }
    }
    
    private init() {}
    
    func getIsFirstLaunch() -> Bool {
        return isFirstLaunch
    }
    
    func setIsFirstLaunch(_ value: Bool) {
        isFirstLaunch = value
    }
    
    func setSelectedFilter(_ filter: String) {
        selectedFilter = filter
    }
    
}
