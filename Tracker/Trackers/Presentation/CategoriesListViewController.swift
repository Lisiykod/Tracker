//
//  CreateCategoryViewController.swift
//  Tracker
//
//  Created by Olga Trofimova on 29.11.2024.
//

import UIKit

protocol CreateNewCategoryDelegate: AnyObject {
    func didCreateCategory(name: String)
}

protocol SelectedCategoryDelegate: AnyObject {
    func categoryDidSelect(name: String)
}

final class CategoriesListViewController: UIViewController {
   
    weak var delegate: SelectedCategoryDelegate?
    private var trackersService = TrackersService.shared
    private var isSelectedCategory: Bool = false
    
    private lazy var emptyCategoryImage: UIImageView = {
        let image = UIImage(named: "empty_trackers_image")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var emptyCategoryLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.text = """
        Привычки и события можно
        объединить по смыслу
        """
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emptyCategoryImage, emptyCategoryLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.baseConfiguration(with: "Добавить категорию")
        button.addTarget(self, action: #selector(addCategory), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.baseSettings(with: UITableViewCell.self, reuseIdentifier: "newCategoryCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isHidden = true
        return tableView
    }()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        if trackersService.categoryExample.isEmpty {
            setupStackViewConsttraints()
        }
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stackView.isHidden = trackersService.categoryExample.isEmpty ? false : true
        tableView.isHidden = !trackersService.categoryExample.isEmpty ? false : true
        if trackersService.categoryExample.isEmpty {
            setupStackViewConsttraints()
        }
        setupConstraints()
        tableView.reloadData()
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        view.backgroundColor = .ypWhite
        view.addSubviews([tableView, stackView, addCategoryButton])
        navigationItem.title = "Категория"
        navigationItem.hidesBackButton = true
        stackView.isHidden = trackersService.categoryExample.isEmpty ? false : true
        tableView.isHidden = !trackersService.categoryExample.isEmpty ? false : true
        
    }
    
    private func setupConstraints() {
        addCategoryButton.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        NSLayoutConstraint.activate([
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: 16),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(75 * trackersService.getCategoriesExampleCount())),
            
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            view.trailingAnchor.constraint(equalTo: addCategoryButton.trailingAnchor, constant: 20),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: addCategoryButton.bottomAnchor, constant: 16),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.topAnchor.constraint(greaterThanOrEqualTo: tableView.bottomAnchor, constant: 24)
            
        ])
    }
    
    private func setupStackViewConsttraints() {
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    @objc
    private func addCategory() {
        // TODO: - здесь будет код с переходом на экран создания категории
    }
}

extension CategoriesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackersService.getCategoriesExampleCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newCategoryCell", for: indexPath)
        cell.accessoryType = .checkmark
        cell.textLabel?.text = trackersService.categoryExample[indexPath.section].title
        cell.backgroundColor = .ypBackgroundDay
        cell.accessoryType = isSelectedCategory ? .checkmark : .none
        cell.selectionStyle = .none
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        if trackersService.getCategoriesExampleCount() == 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            tableView.isScrollEnabled = false
        }
        return cell
    }
    
}

extension CategoriesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if !isSelectedCategory {
                cell.accessoryType = .checkmark
                delegate?.categoryDidSelect(name: trackersService.categoryExample[indexPath.row].title)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.dismiss(animated: true)
                }
            } else {
                cell.accessoryType = .none
            }
        }
    }
    
}

extension CategoriesListViewController: CreateNewCategoryDelegate  {
    func didCreateCategory(name: String) {
    
    }
}
