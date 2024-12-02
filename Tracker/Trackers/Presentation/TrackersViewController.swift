//
//  ViewController.swift
//  Tracker
//
//  Created by Olga Trofimova on 22.11.2024.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    private var categories: [TrackerCategory] = [TrackerCategory(name: "Важное", trackers: [])]
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
        collection.isHidden = true
        collection.dataSource = self
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trackerCell", for: indexPath) as? TrackerCollectionCell
        
        guard let cell else { return UICollectionViewCell() }
        
//        cell.backgroundColor = .red
        return cell
    }
    
    
}
