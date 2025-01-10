//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by Olga Trofimova on 09.01.2025.
//

import Foundation

typealias Binding<T> = (T) -> ()

final class CategoriesViewModel {
    
    var categoriesBinding: Binding<[TrackerCategory]>?
    
    private let trackerService = TrackersService.shared
    
    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            categoriesBinding?(categories)
        }
    }
    
    func addCategory(_ category: TrackerCategory) {
        trackerService.addCategory(category)
    }
    
    func getCategoriesCount() -> Int {
        trackerService.getCategoriesCount()
    }
    
    func fetchCategories() {
        categories = trackerService.fetchCategories()
    }
    
    func getCategoryTitle(at index: Int) -> String? {
        guard index < categories.count else { return nil }
        return categories[index].title
    }
    
}
