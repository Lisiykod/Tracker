//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Olga Trofimova on 28.01.2025.
//

import Foundation
import AppMetricaCore

final class AnalyticsService {
    
    func trackerEvent(name: String, parameters: [AnyHashable: Any]) {
        AppMetrica.reportEvent(name: name, parameters: parameters) { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        }
    }
    
}
