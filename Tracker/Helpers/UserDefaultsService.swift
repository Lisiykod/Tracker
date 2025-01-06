//
//  UserDefaultsService.swift
//  Tracker
//
//  Created by Olga Trofimova on 06.01.2025.
//

import Foundation

final class UserDefaultsService {
    static let shared = UserDefaultsService()
    
    private let launchKey = "isFirstLaunch"
    private let storage = UserDefaults.standard
    
    private var isNotFirstLaunch: Bool {
        get {
            storage.bool(forKey: launchKey)
        }
        
        set {
            storage.set(newValue, forKey: launchKey)
        }
    }
    
    func getIsNotFirstLaunch() -> Bool {
        return isNotFirstLaunch
    }
    
    func setIsFirstLaunch(_ value: Bool) {
        isNotFirstLaunch = value
    }
    
    private init() {}
    
}
