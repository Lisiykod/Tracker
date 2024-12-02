//
//  ViewController.swift
//  Tracker
//
//  Created by Olga Trofimova on 22.11.2024.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    private var categories: [TrackerCategory] = [TrackerCategory(name: "Важное", trackers: [Trackers(id: UUID(), name: "", color: .ypRed, emoji: "☺️", schedule: [])])]
    private var completedTrackers: [TrackerRecord] = []
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
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
        label.text = "Что будем отслеживать?"
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
    
    private lazy var collection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.backgroundColor = .ypWhite
        collection.register(TrackerCollectionCell.self, forCellWithReuseIdentifier: "trackerCell")
        collection.register(HeaderSupplementaryView.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collection.isHidden = true
        collection.dataSource = self
        collection.delegate = self
        return collection
    }()
    
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationBar()
        setupConstraints()
    }
    
    // MARK: - Private methods
    
    private func setupViews() {
        view.backgroundColor = .ypWhite
        view.addSubviews([datePicker, emptyImageTrackersStackView, collection])
        makeViewVisible()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
                emptyTrackersImage.heightAnchor.constraint(equalToConstant: 80),
                emptyTrackersImage.widthAnchor.constraint(equalToConstant: 80),
                emptyImageTrackersStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                emptyImageTrackersStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                datePicker.widthAnchor.constraint(equalToConstant: 100)
            ])
        
        collection.edgesToSuperview()
    }
    
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "addTracker"), style: .plain, target: self, action: #selector(addTracker))
        navigationItem.leftBarButtonItem?.tintColor = .ypBlack
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func makeViewVisible() {
        if !categories.isEmpty {
            emptyImageTrackersStackView.isHidden = true
            collection.isHidden = false
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
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formateDate = dateFormatter.string(from: selectedDate)
        //TODO: - потом удалить принт
        print("Выбранная дата: \(formateDate)")
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trackerCell", for: indexPath) as? TrackerCollectionCell
        
        guard let cell else { return UICollectionViewCell() }
        
        cell.titleLabel.text = "Кошка заслонила камеру на созвоне"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? HeaderSupplementaryView
        guard let header else { return UICollectionReusableView() }
//        header.headerLabel.text = categories[indexPath.section].name
        header.headerLabel.text = "Важное"
        return header
    }
    
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        return headerView.systemLayoutSizeFitting(
            CGSize(width: collectionView.frame.width,
                   height: 18)
//            withHorizontalFittingPriority: .required,
//            verticalFittingPriority: .fittingSizeLevel
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 32 - 9)/2, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 16, bottom: 0, right: 16)
    }
    
}
