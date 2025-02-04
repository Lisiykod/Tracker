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
        case selectedCategoryKey = "selectedCategory"
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
            storage.string(forKey: Keys.selectedFilterKey.rawValue) ?? FilterType.all.rawValue
        }
        
        set {
            storage.set(newValue, forKey: Keys.selectedFilterKey.rawValue)
        }
    }
    
    private(set) var selectedCategory: String? {
        get {
            storage.string(forKey: Keys.selectedCategoryKey.rawValue) ?? ""
        }
        
        set {
            storage.set(newValue, forKey: Keys.selectedCategoryKey.rawValue)
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
    
    func setSelectedCategory(_ category: String) {
        selectedCategory = category
    }
    
}
