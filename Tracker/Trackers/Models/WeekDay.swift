//
//  WeekDay.swift
//  Tracker
//
//  Created by Olga Trofimova on 06.12.2024.
//

import Foundation

enum WeekDay: Int, CaseIterable {
    case monday = 1
    case tuersday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    case sunday = 7
    
    func getShortDay() -> String {
        switch self {
        case .monday:
            "Пн"
        case .tuersday:
            "Вт"
        case .wednesday:
            "Ср"
        case .thursday:
            "Чт"
        case .friday:
            "Пт"
        case .saturday:
            "Сб"
        case .sunday:
            "Вс"
        }
    }
    
    func getFullDay() -> String {
        switch self {
        case .monday:
            "Понедельник"
        case .tuersday:
            "Вторник"
        case .wednesday:
            "Среда"
        case .thursday:
            "Четверг"
        case .friday:
            "Пятница"
        case .saturday:
            "Суббота"
        case .sunday:
            "Воскресенье"
        }
    }
    
    static func getCurrentDay() -> WeekDay? {
        let currentDay = Calendar.current.component(.weekday, from: Date() )
        let filterWeekday = currentDay == 1 ? 7 : currentDay - 1
        
        let allDays: [WeekDay] = WeekDay.allCases.filter { weekDay in
            weekDay.rawValue == filterWeekday
        }
        
        return allDays.first
    }

}
