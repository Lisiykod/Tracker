//
//  TrackersService.swift
//  Tracker
//
//  Created by Olga Trofimova on 04.12.2024.
//

import Foundation

protocol TrackersServiceDelegate: AnyObject {
    func updateTrackers()
}

final class TrackersService {
    static let shared = TrackersService()
    weak var delegate: TrackersServiceDelegate?
    
    private(set) var trackers: [TrackerCategory] = [TrackerCategory(
        title: "Важное",
        trackers: [
            Tracker(
                id: UUID(),
                title: "Погладить кота",
                color: .ypColorSelection15,
                emoji: "😻",
//                schedule: [.monday]
                schedule: [.monday , .tuersday, .wednesday, .thursday, .friday, .saturday, .sunday]
            ),
            Tracker(
                id: UUID(),
                title: "Лечь спать до 12ти",
                color: .ypColorSelection8,
                emoji: "😪",
                schedule: [.monday, .wednesday, .thursday]
            ),
            Tracker(
                id: UUID(),
                title: "Помечтать о пятнице",
                color: .ypColorSelection12,
                emoji: "🎸",
                schedule: [.monday]
            )
        ]
    )]
    
    private init() {
        
    }
    
    func getCategoriesCount() -> Int {
        trackers.count
    }
    
    func addTracker(tracker: Tracker, for category: String) {
        if let categoryIndex = trackers.firstIndex(where: { $0.title == category }) {
            let currentCategory = trackers[categoryIndex]
            
            let newCategory = TrackerCategory(title: currentCategory.title,
                                              trackers: currentCategory.trackers + [tracker])
            trackers[categoryIndex] = newCategory
            delegate?.updateTrackers()
        }
        
    }
    
    func addCategory(_ category: TrackerCategory) {
        trackers.append(category)
    }
    
    func getVisibleCategoriesForDate(_ date: Date) -> [TrackerCategory] {
        let weekday = Calendar.current.component(.weekday, from: date)
        let filterWeekday = weekday == 1 ? 7 : weekday - 1
        var visibleCategories = [TrackerCategory]()
        
        visibleCategories = trackers.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                tracker.schedule.contains { weekday in
                    return weekday.getDayNumber() == filterWeekday
                    
                }
            }
    
            if filteredTrackers.isEmpty {
                return nil
            }
            
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        
        return visibleCategories
    }
    
}
