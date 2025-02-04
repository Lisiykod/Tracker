//
//  FilterType.swift
//  Tracker
//
//  Created by Olga Trofimova on 24.01.2025.
//

import Foundation

enum FilterType: String, CaseIterable {
    case all = "Все трекеры"
    case today = "Трекеры на сегодня"
    case completed = "Завершенные"
    case uncompleted = "Не завершенные"
}
