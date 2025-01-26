//
//  FilterViewController.swift
//  Tracker
//
//  Created by Olga Trofimova on 24.01.2025.
//

import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func updateTrackers(for filter: FilterType)
}

final class FilterViewController: UIViewController {
    
    weak var delegate: FilterViewControllerDelegate?
    private let filters = FilterType.allCases
    private var isSelectedFilter: Bool = false
    private var selectedFilter = UserDefaultsService.shared.selectedFilter
    private var selectIndexPath: IndexPath?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.baseSettings(with: UITableViewCell.self, reuseIdentifier: "filterCell")
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    // MARK: - Private methods
    
    private func setupViews() {
        view.backgroundColor = .ypWhite
        navigationItem.title = "Фильтры"
        view.addSubviews([tableView])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: 16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(filters.count * 75))
        ])
        
    }
    
}

extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath)
        cell.backgroundColor = .ypBackgroundDay
        cell.selectionStyle = .none
        cell.textLabel?.text = filters[indexPath.row].rawValue
        if cell.textLabel?.text == selectedFilter {
            cell.accessoryType = .checkmark
            selectIndexPath = IndexPath(row: indexPath.row, section: indexPath.section)
        } else {
            cell.accessoryType = .none
        }
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return cell
    }
    
}

extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if selectIndexPath != indexPath {
                cell.accessoryType = .checkmark
                if let selectIndexPath {
                    let prevCell = tableView.cellForRow(at: selectIndexPath)
                    prevCell?.accessoryType = .none
                }
                delegate?.updateTrackers(for: filters[indexPath.row])
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.dismiss(animated: true)
                }
            } else {
                cell.accessoryType = .none
            }
            
            selectIndexPath = nil
        }
    }
}
