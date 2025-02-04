//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Olga Trofimova on 28.01.2025.
//

import Foundation
import AppMetricaCore

final class AnalyticsService {
    
    static func configuration() {
        guard let configuration = AppMetricaConfiguration(apiKey: Constants.apiKey) else { return }
        AppMetrica.activate(with: configuration)
    }
    
    static func trackerEvent(name: String, parameters: [AnyHashable: Any]) {
        AppMetrica.reportEvent(name: name, parameters: parameters) { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        }
    }
    
}
