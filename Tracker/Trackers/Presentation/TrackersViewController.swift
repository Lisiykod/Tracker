//
//  ViewController.swift
//  Tracker
//
//  Created by Olga Trofimova on 22.11.2024.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    private let trackerService = TrackersService.shared
    private var categories: [TrackerCategory] = []
    private var filteredCategories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    private var currentDate: Date = Date()
    private var selectedFilterType: FilterType {
        get {
            guard let selectedFilterFromStorage = UserDefaultsService.shared.selectedFilter else {
                return .all
            }
            
            let type = FilterType(rawValue: selectedFilterFromStorage)
            
            guard let type else {
                return .all
            }
            
            return type
        }
        
        set {
            UserDefaultsService.shared.setSelectedFilter(newValue.rawValue)
        }
    }
    
    private let emptyTrackersLabelTitle = NSLocalizedString("emptyTrackersLabel", comment: "Text displayed when tracker is empty")
    private let emptySearchOrFilterLabelTitle = NSLocalizedString("emptySearchOrFilterLabel", comment: "Text displayed when search result or filter result is empty")
    private let pinTitle = NSLocalizedString("pinTitle", comment: "Text displayed when context menu appear")
    private let unpinTitile = NSLocalizedString("unpinTitile", comment: "Text displayed when context menu appear")
    private let deleteTitile = NSLocalizedString("deleteTitile", comment: "Text displayed when context menu appear")
    private let editTitile = NSLocalizedString("editTitile", comment: "Text displayed when context menu appear")
    private let deleteActionSheetTitle = NSLocalizedString("deleteActionSheetTitle", comment: "Title of delete action sheet")
    private let deleteActionTitle = NSLocalizedString("deleteActionTitle", comment: "Title of delete action sheet")
    private let cancelActionTitle = NSLocalizedString("cancelActionTitle", comment: "Title of cancel action sheet")
    private let searchPlaceholderTitle = NSLocalizedString("searchPlaceholderTitle", comment:  "Title of search placeholder")
    private let filterButtonTitle = NSLocalizedString("filterButton", comment: "Title of filter button")
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = .current
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var emptyTrackersImage: UIImageView = {
        let image = UIImage(named: "empty_trackers_image")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var emptyTrackersLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var emptyImageTrackersStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emptyTrackersImage, emptyTrackersLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var emptySearchOrFilterStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emptyTrackersImage, emptyTrackersLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var collection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.backgroundColor = .ypWhite
        collection.register(TrackerCollectionCell.self, forCellWithReuseIdentifier: TrackerCollectionCell.reuseIdentifier)
        collection.register(HeaderSupplementaryView.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collection.isHidden = true
        collection.dataSource = self
        collection.delegate = self
        collection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        return collection
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.titleLabel?.textColor = .ypWhite
        button.setTitle(filterButtonTitle, for: .normal)
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        button.backgroundColor = .ypBlue
        button.layer.cornerRadius = 16
        return button
    }()
    
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trackerService.delegate = self
        updateVisibleCategoryForSelectedDay(currentDate, filter: selectedFilterType)
        filteredCategories = categories
        setupViews()
        setupNavigationBar()
        setupConstraints()
    }
    
    // MARK: - Private methods
    
    private func setupViews() {
        view.backgroundColor = .ypWhite
        view.addSubviews([datePicker, emptyImageTrackersStackView, collection, filterButton])
        makeViewVisible(isDateFilter: true)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            emptyTrackersImage.heightAnchor.constraint(equalToConstant: 80),
            emptyTrackersImage.widthAnchor.constraint(equalToConstant: 80),
            emptyImageTrackersStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyImageTrackersStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            datePicker.widthAnchor.constraint(equalToConstant: 100),
            
            collection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collection.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            collection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: filterButton.bottomAnchor, constant: 16)
            
        ])
        
    }
    
    private func updateVisibleCategoryForSelectedDay(_ day: Date, filter: FilterType) {
        completedTrackers = trackerService.fetchRecords()
        guard let date = day.ignoringTime else { return }
        categories = trackerService.getVisibleCategoriesForDate(date, recordTracker: completedTrackers, filter: filter)
        makeViewVisible(isDateFilter: true)
        collection.reloadData()
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "addTracker"), style: .plain, target: self, action: #selector(addTracker))
        navigationItem.leftBarButtonItem?.tintColor = .ypBlack
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = searchPlaceholderTitle
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func makeViewVisible(isDateFilter: Bool) {
        if !categories.isEmpty {
            emptyImageTrackersStackView.isHidden = true
            collection.isHidden = false
            filterButton.isHidden = false
        } else {
            emptyImageTrackersStackView.isHidden = false
            emptyTrackersLabel.text = isDateFilter ? emptyTrackersLabelTitle : emptySearchOrFilterLabelTitle
            emptyTrackersImage.image = isDateFilter ? UIImage(named: "empty_trackers_image") : UIImage(named: "empty_search_image")
            collection.isHidden = true
            filterButton.isHidden = true
        }
    }
    
    @objc
    private func addTracker() {
        let createTrackerController = CreateTrackerController()
        let newNavController = UINavigationController(rootViewController: createTrackerController)
        navigationController?.present(newNavController, animated: true)
        
    }
    
    @objc
    private func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date.ignoringTime
        guard let selectedDate else { return }
        currentDate = selectedDate
        updateVisibleCategoryForSelectedDay(selectedDate, filter: selectedFilterType)
    }
    
    @objc
    private func filterButtonTapped() {
        let filterVC = FilterViewController()
        filterVC.delegate = self
        let newNavController = UINavigationController(rootViewController: filterVC)
        navigationController?.present(newNavController, animated: true)
    }
    
    private func checkedTrackerIsCompleted(id: UUID) -> Bool {
        completedTrackers.contains { trackerRecord in
            let completedDate = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
            return trackerRecord.id == id && completedDate
        }
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionCell.reuseIdentifier, for: indexPath) as? TrackerCollectionCell
        
        guard let cell else { return UICollectionViewCell() }
        
        cell.delegate = self
        let tracker = categories[indexPath.section].trackers[indexPath.row]
        let isCompleted = checkedTrackerIsCompleted(id: tracker.id)
        let completedDays = completedTrackers.filter { $0.id == tracker.id }.count
        
        cell.configureCell(
            with: tracker,
            isCompleted: isCompleted,
            selectedDate: datePicker.date,
            daysCount: completedDays,
            at: indexPath
        )
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader , withReuseIdentifier: "header", for: indexPath) as? HeaderSupplementaryView
        guard let header else { return UICollectionReusableView() }
        header.configureHeader(with: categories[indexPath.section].title)
        return header
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 32 - 9)/2, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPaths: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self else { return UIMenu() }
            let pinAction = UIAction(title: pinTitle) {_ in
                self.pinTracker(at: indexPaths)
            }
            
            let unpinAction = UIAction(title: unpinTitile) { _ in
                self.unpinTracker(at: indexPaths)
            }
            
            let editAction = UIAction(title: editTitile) { _ in
                self.editTracker(at: indexPaths)
            }
            
            let deleteAction = UIAction(title: deleteTitile, attributes: .destructive) { _ in
                self.deleteTracker(at: indexPaths)
            }
            
            if categories[indexPaths.section].title == "Закрепленные" {
                return UIMenu(options: UIMenu.Options.displayInline, children: [unpinAction, editAction, deleteAction])
            } else {
                return UIMenu(options: UIMenu.Options.displayInline, children: [pinAction, editAction, deleteAction])
            }
        }
        
        return configuration
    }
    
    private func pinTracker(at indexPath: IndexPath) {
        var tracker = categories[indexPath.section].trackers[indexPath.row]
        tracker.isPinned = true
        trackerService.updateTracker(tracker)
        updateVisibleCategoryForSelectedDay(currentDate, filter: selectedFilterType)
        collection.reloadData()
    }
    
    private func unpinTracker(at indexPath: IndexPath) {
        var tracker = categories[indexPath.section].trackers[indexPath.row]
        tracker.isPinned = false
        trackerService.updateTracker(tracker)
        updateVisibleCategoryForSelectedDay(currentDate, filter: selectedFilterType)
        collection.reloadData()
    }
    
    private func deleteTracker(at indexPath: IndexPath) {
        let actionSheet = UIAlertController(title: deleteActionSheetTitle, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: deleteActionTitle, style: .destructive) { [weak self] _ in
            guard let self else { return }
            trackerService.deleteTracker(categories[indexPath.section].trackers[indexPath.row])
            trackerService.deleteAllRecords(categories[indexPath.section].trackers[indexPath.row])
            updateVisibleCategoryForSelectedDay(currentDate,filter: selectedFilterType)
            collection.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel, handler: nil)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        present(actionSheet, animated: true)
        collection.reloadData()
    }
    
    private func editTracker(at indexPath: IndexPath) {
        let dataBaseCategories = trackerService.fetchCategories()
        let tracker = categories[indexPath.section].trackers[indexPath.row]
        var completedDays = 0
        
        if completedTrackers.contains(where: { $0.id == tracker.id }) {
            completedDays = completedTrackers.filter({ $0.id == tracker.id }).count
        }
        
        let categoryIndex = dataBaseCategories.firstIndex { category in
            category.trackers.contains(where: { $0.id == tracker.id })
        }
        
        guard let categoryIndex else { return }
        let category = dataBaseCategories[categoryIndex]
        
        let editHabbitVC = CreateNewHabitViewController(isHabit: tracker.isHabit)
        let editEventVC = CreateNewEventViewController(isHabit: tracker.isHabit)
        
        if tracker.isHabit {
            editHabbitVC.trackerForEdit(tracker: tracker, category: category, daysCompleted: completedDays)
        } else {
            editEventVC.trackerForEdit(tracker: tracker, category: category, daysCompleted: completedDays)
        }
        let newNavController = UINavigationController(rootViewController: tracker.isHabit ? editHabbitVC : editEventVC)
        navigationController?.present(newNavController, animated: true)
    }
    
}

// MARK: - UISearchResultsUpdating

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        var isDateFilter = false
        
        if let searchText = searchController.searchBar.text, !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let searchResult = trackerService.getSearchedTrackers(searchText, filtered: categories)
            categories = searchResult
        } else {
            updateVisibleCategoryForSelectedDay(currentDate, filter: selectedFilterType)
            isDateFilter = true
        }
        makeViewVisible(isDateFilter: isDateFilter)
        collection.reloadData()
    }
    
}

// MARK: - CompletedTrackerDelegate

extension TrackersViewController: CompletedTrackerDelegate {
    
    func appendTrackerRecord(tracker id: UUID, at indexPath: IndexPath) {
        guard let date = currentDate.ignoringTime else { return }
        let trackerRecord = TrackerRecord(id: id, date: date)
        trackerService.addRecord(trackerRecord)
        completedTrackers = trackerService.fetchRecords()
        collection.reloadItems(at: [indexPath])
    }
    
    func removeTrackerRecord(tracker id: UUID, at indexPath: IndexPath) {
        guard let date = currentDate.ignoringTime else { return }
        let trackerRecord = TrackerRecord(id: id, date: date)
        if completedTrackers.contains(trackerRecord) {
            trackerService.deleteRecord(trackerRecord)
            completedTrackers = trackerService.fetchRecords()
        }
        collection.reloadItems(at: [indexPath])
    }
}

// MARK: - TrackersServiceDelegate

extension TrackersViewController: TrackersServiceDelegate {
    func updateTrackers() {
        updateVisibleCategoryForSelectedDay(currentDate, filter: selectedFilterType)
    }
}

// MARK: - FilterViewControllerDelegate

extension TrackersViewController: FilterViewControllerDelegate {
    func updateTrackers(for filter: FilterType) {
        switch filter {
        case .all:
            selectedFilterType = .all
            updateVisibleCategoryForSelectedDay(currentDate, filter: selectedFilterType)
        case .today:
            selectedFilterType = .today
            currentDate = Date()
            datePicker.setDate(currentDate, animated: true)
            updateVisibleCategoryForSelectedDay(currentDate, filter: selectedFilterType)
        case .completed:
            selectedFilterType = .completed
            updateVisibleCategoryForSelectedDay(currentDate, filter: selectedFilterType)
        case .uncompleted:
            selectedFilterType = .uncompleted
            updateVisibleCategoryForSelectedDay(currentDate, filter: selectedFilterType)
        }
    }
    
}

