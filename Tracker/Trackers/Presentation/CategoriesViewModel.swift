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
    
    var categoriesAmount: Int {
        trackerService.categoriesAmount
    }
    
    private let trackerService = TrackersService.shared
    
    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            categoriesBinding?(categories)
        }
    }
    
    func addCategory(_ category: TrackerCategory) {
        trackerService.addCategory(category)
    }
    
    func fetchCategories() {
        categories = trackerService.fetchCategories()
    }
    
    func getCategoryTitle(at index: Int) -> String? {
        guard index < categories.count else { return nil }
        return categories[index].title
    }
    
    func updateCategory(oldTitle: String, with newTitle: String) {
        guard let categoryForUpdate = categories.first(where: {$0.title == oldTitle}) else { return }
        trackerService.updateCategory(categoryForUpdate.title, newTitle: newTitle)
    }
    
    func deleteCategory(at index: Int) {
        let category = categories[index]
        trackerService.deleteCategory(category: category.title)
    }
    
}
