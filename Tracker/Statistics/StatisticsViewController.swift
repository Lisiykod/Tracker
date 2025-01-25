//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Olga Trofimova on 23.11.2024.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    private var completedTrackers = TrackersService.shared.fetchRecords()
    
    private lazy var emptyStatisticsImage: UIImageView = {
        let image = UIImage(named: "empty_statistics")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var emptyStatisticsLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emptyStatisticsImage, emptyStatisticsLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .ypWhite
        tableView.rowHeight = 90
        tableView.register(StatisticCell.self, forCellReuseIdentifier: "statisticCell")
        tableView.dataSource = self
        tableView.separatorStyle = .none
        return tableView
    }()
    
    // MARK: - Lyfe Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupViews()
        setupPlaceholderConstraints()
        setupTableViewConstraints()
        if completedTrackers.isEmpty {
            tableView.isHidden = true
            stackView.isHidden = false
        } else {
            stackView.isHidden = true
            tableView.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        completedTrackers = TrackersService.shared.fetchRecords()
        tableView.reloadData()
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        view.addSubviews([stackView, tableView])
    }
    
    private func setupPlaceholderConstraints() {
        NSLayoutConstraint.activate([
            emptyStatisticsImage.heightAnchor.constraint(equalToConstant: 80),
            emptyStatisticsImage.widthAnchor.constraint(equalToConstant: 80),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
        ])
    }
    
    private func setupTableViewConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 70),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: 16),
//            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
}

extension StatisticsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "statisticCell", for: indexPath) as? StatisticCell
        
        guard let cell else { return UITableViewCell() }
        
        cell.configureCell(
            completedDays: completedTrackers.count,
            description: "Трекеров завершено"
        )
        
        return cell
    }
    
    
}
