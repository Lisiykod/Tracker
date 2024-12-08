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
//            Tracker(
//                id: UUID(),
//                title: "Погладить кота",
//                color: .ypColorSelection15,
//                emoji: "😻",
//                schedule: [.monday , .tuersday, .saturday, .sunday],
//                isHabit: true
//            ),
//            Tracker(
//                id: UUID(),
//                title: "Лечь спать до 12ти",
//                color: .ypColorSelection8,
//                emoji: "😪",
//                schedule: [.monday, .wednesday, .thursday],
//                isHabit: true
//            ),
//            Tracker(
//                id: UUID(),
//                title: "Помечтать о пятнице",
//                color: .ypColorSelection12,
//                emoji: "🎸",
//                schedule: [.monday],
//                isHabit: true
//            )
        ]
    )]
    
    // MARK: - Public Methods
    
    func getCategoriesCount() -> Int {
        trackers.count
    }
    
    func addTracker(tracker: Tracker, for category: String) {
        if let categoryIndex = trackers.firstIndex(where: { $0.title == category }) {
            let currentCategory = trackers[categoryIndex]
            
            let newCategory = TrackerCategory(title: currentCategory.title,
                                              trackers: currentCategory.trackers + [tracker])
            trackers[categoryIndex] = newCategory
        }
        delegate?.updateTrackers()
    }
    
    func addCategory(_ category: TrackerCategory) {
        trackers.append(category)
    }
    
    func getVisibleCategoriesForDate(_ selectedDate: Date, recordTracker: Set<TrackerRecord>) -> [TrackerCategory] {
        let weekday = Calendar.current.component(.weekday, from: selectedDate)
        let filterWeekday = weekday == 1 ? 7 : weekday - 1
        var allVisibleCategories = [TrackerCategory]()

        allVisibleCategories = trackers.compactMap { category in
            let allFilteredTrackers = category.trackers.filter { tracker in
                tracker.schedule.contains { weekday in
                    return weekday.rawValue == filterWeekday
                }
            }
    
            let filteredEventTrackers = allFilteredTrackers.filter { tracker in
                if !recordTracker.isEmpty, !tracker.isHabit {
                    return recordTracker.contains { trackerRecord in
                        return trackerRecord.date == selectedDate
                    }
                }
                
                return true
            }
            
            if filteredEventTrackers.isEmpty {
                return nil
            }
            
            return TrackerCategory(title: category.title, trackers: filteredEventTrackers)
        }
        
        return allVisibleCategories
    }
    
    // MARK: - Private Methods
    
    private init() { }
    
}
