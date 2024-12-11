//
//  Date+dateComponents.swift
//  Tracker
//
//  Created by Olga Trofimova on 08.12.2024.
//

import Foundation

extension Date {
    var ignoringTime: Date? {
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: self)
        return Calendar.current.date(from: dateComponents)
    }
}
