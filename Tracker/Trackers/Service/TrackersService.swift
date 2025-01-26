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
    
    var categoriesAmount: Int {
        let categories = fetchCategories()
        return categories.count
    }
    
    private let trackerCategoryStore = TrackerCategoryStore()
    private var trackerRecordStore = TrackerRecordStore()
    private let trackerStore = TrackerStore()
    
    private(set) var categoryExample: [TrackerCategory] = [TrackerCategory(
        title: "Важное",
        trackers: [
            //            Tracker(
            //                id: UUID(),
            //                title: "Поспать",
            //                color: .ypColorSelection15,
            //                emoji: "😻",
            //                schedule: [.monday , .tuersday, .wednesday, .thursday, .friday, .saturday, .sunday],
            //                isHabit: false
            //            ),
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
    )
    ]
    
    // MARK: - Public Methods
    
    func fetchCategories() -> [TrackerCategory] {
        let categories = try? trackerCategoryStore.fetchCategories()
        guard let categories else {
            print("Do not fetch Categories")
            return []
        }
        return categories
    }
    
    func getCategoriesExampleCount() -> Int {
        return categoryExample.count
    }
    
    func addTracker(tracker: Tracker, for category: String) {
        trackerCategoryStore.addTrackerToCategory(tracker, category: category)
        delegate?.updateTrackers()
    }
    
    func addCategory(_ category: TrackerCategory) {
        trackerCategoryStore.addCategory(category)
    }
    
    func deleteTracker(_ tracker: Tracker) {
        trackerCategoryStore.deleteTrackerFromCategory(tracker)
    }
    
    func updateTracker(_ tracker: Tracker) {
//        let category = fetchCategories().compactMap { category -> TrackerCategory in
//            if category.trackers.contains(where: {$0.id == tracker.id}) {
//                trackerStore.updateTracker(tracker: tracker)
//            }
//        }
        
//        fetchCategories().forEach { category in
//            if category.trackers.contains(where: {$0.id == tracker.id}) {
//                trackerStore.updateTracker(tracker: tracker)
//            } else {
//                addTracker(tracker: tracker, for: <#T##String#>)
//            }
//            
//        }
        trackerStore.updateTracker(tracker: tracker)
        delegate?.updateTrackers()
    }
    
    func updateCategory(_ oldTitle: String, newTitle: String) {
        trackerCategoryStore.updateCategory(oldTitle, newTitle: newTitle)
    }
    
    func deleteCategory(category title: String) {
        trackerCategoryStore.deleteCategory(title)
        delegate?.updateTrackers()
    }
    
    
    func getVisibleCategoriesForDate(_ selectedDate: Date, recordTracker: Set<TrackerRecord>, filter: FilterType) -> [TrackerCategory] {
        let weekday = Calendar.current.component(.weekday, from: selectedDate)
        let filterWeekday = weekday == 1 ? 7 : weekday - 1
        let fecthTrackers = fetchCategories()
        var allVisibleCategories = [TrackerCategory]()
        var trackers: [Tracker] = []
        var pinnedTrackers = [TrackerCategory(title: "Закрепленные", trackers: [])]
        
        allVisibleCategories = fecthTrackers.compactMap { category in
            let allFilteredTrackers = category.trackers.filter { tracker in
                tracker.schedule.contains { weekday in
                    return weekday.rawValue == filterWeekday
                }
            }
            
            let filteredEventTrackers = allFilteredTrackers.filter { tracker in
                if !tracker.isHabit {
                    let isEventRecordOnDate = recordTracker.contains { trackerRecord in
                        return trackerRecord.date == selectedDate && trackerRecord.id == tracker.id
                    }
                    
                    let isNotEventRecord = recordTracker.allSatisfy { trackerRecord in
                        return trackerRecord.id != tracker.id
                    }
                    
                    return isEventRecordOnDate || isNotEventRecord
                }
                
                return true
            }
            
            let filteredWithPinningTracker = filteredEventTrackers.filter { tracker in
                if tracker.isPinned {
                    trackers.append(tracker)
                    pinnedTrackers = [TrackerCategory(title: "Закрепленные", trackers: trackers)]
                    
                    return false
                }
                return true
            }
            
            if filteredWithPinningTracker.isEmpty {
                return nil
            }
            
            return TrackerCategory(title: category.title, trackers: filteredWithPinningTracker)
        }
        
        if !pinnedTrackers[0].trackers.isEmpty {
            allVisibleCategories.insert(contentsOf: pinnedTrackers, at: 0)
        }
        
        switch filter {
        case .all, .today:
            return allVisibleCategories
        case .completed:
            let completedCategories = getCompletedOrNotComplitedTrackers(allVisibleCategories, selectedDate: selectedDate, recordTracker: recordTracker, isComplited: true)
            return completedCategories
        case .uncompleted:
            let uncompletedCategories = getCompletedOrNotComplitedTrackers(allVisibleCategories, selectedDate: selectedDate, recordTracker: recordTracker, isComplited: false)
            return uncompletedCategories
        }
    }
    
    func getSearchedTrackers(_ searchText: String, filtered categories: [TrackerCategory]) -> [TrackerCategory] {
        let filteredCategories = categories.compactMap { category -> TrackerCategory? in
            let allFilteredTrackers = category.trackers.filter { $0.title.lowercased().contains(searchText.lowercased()) }
            
            
            if allFilteredTrackers.isEmpty {
                return nil
            }
            
            return TrackerCategory(title: category.title, trackers: allFilteredTrackers)
        }
        
        return filteredCategories
    }
    
    func getCompletedOrNotComplitedTrackers(_ categories: [TrackerCategory], selectedDate: Date, recordTracker: Set<TrackerRecord>, isComplited: Bool) -> [TrackerCategory] {
        let complitedTrackers = categories.compactMap { category -> TrackerCategory? in
            let complitedTrackers = category.trackers.filter { tracker in
                if isComplited {
                    return recordTracker.contains { trackerRecord in
                        return trackerRecord.date == selectedDate && trackerRecord.id == tracker.id
                    }
                    
                } else {
                    return !recordTracker.contains { trackerRecord in
                        return trackerRecord.date == selectedDate && trackerRecord.id == tracker.id
                    }
                }
            }
            
            if complitedTrackers.isEmpty {
                return nil
            }
            
            return TrackerCategory(title: category.title, trackers: complitedTrackers)
        }
        
        return complitedTrackers
    }
    
    func addRecord(_ record: TrackerRecord) {
        trackerRecordStore.addRecord(record)
    }
    
    func deleteRecord(_ record: TrackerRecord) {
        trackerRecordStore.deleteRecord(record)
    }
    
    func fetchRecords() -> Set<TrackerRecord> {
        trackerRecordStore.fetchRecords()
    }
    
    func deleteAllRecords(_ tracker: Tracker) {
        trackerRecordStore.deleteAllRecords(tracker)
    }
    
    // MARK: - Private Methods
    
    private init() { }
    
}

