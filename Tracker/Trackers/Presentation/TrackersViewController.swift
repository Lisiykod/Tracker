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
    private var completedTrackers: Set<TrackerRecord> = []
    private var currentDate: Date = Date()
    
    private let emptyTrackersLabelTitle = NSLocalizedString("emptyTrackersLabel", comment: "Text displayed when tracker is empty")
    private let emptySearchOrFilterLabelTitle = NSLocalizedString("emptySearchOrFilterLabel", comment: "Text displayed when search result or filter result is empty")
    
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
        return collection
    }()
    
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trackerService.delegate = self
        updateVisibleCategoryForSelectedDay(currentDate)
        setupViews()
        setupNavigationBar()
        setupConstraints()
    }
    
    func updateVisibleCategoryForSelectedDay(_ day: Date) {
        completedTrackers = trackerService.fetchRecords()
        guard let date = day.ignoringTime else { return }
        categories = trackerService.getVisibleCategoriesForDate(date, recordTracker: completedTrackers)
        makeViewVisible(isDateFilter: true)
        collection.reloadData()
    }
    
    // MARK: - Private methods
    
    private func setupViews() {
        view.backgroundColor = .ypWhite
        view.addSubviews([datePicker, emptyImageTrackersStackView, collection])
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
            collection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "addTracker"), style: .plain, target: self, action: #selector(addTracker))
        navigationItem.leftBarButtonItem?.tintColor = .ypBlack
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Поиск"
        searchController.delegate = self
        navigationItem.searchController = searchController
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func makeViewVisible(isDateFilter: Bool) {
        // TODO: - добавить проверку на пустой поиск и фильтр + настройку текста
        if isDateFilter && !categories.isEmpty {
            emptyImageTrackersStackView.isHidden = true
            collection.isHidden = false
        } else {
            emptyImageTrackersStackView.isHidden = false
            emptyTrackersLabel.text = isDateFilter ? emptyTrackersLabelTitle : emptySearchOrFilterLabelTitle
            emptyTrackersImage.image = isDateFilter ? UIImage(named: "empty_trackers_image") : UIImage(named: "empty_search_image")
            collection.isHidden = true
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
        updateVisibleCategoryForSelectedDay(selectedDate)
    }
    
    private func checkedTrackerIsCompleted(id: UUID) -> Bool {
        completedTrackers.contains { trackerRecord in
            let completedDate = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
            return trackerRecord.id == id && completedDate
        }
    }
}

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
    
}

extension TrackersViewController: UISearchControllerDelegate {
    
}

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

extension TrackersViewController: TrackersServiceDelegate {
    func updateTrackers() {
        updateVisibleCategoryForSelectedDay(currentDate)
    }
}


