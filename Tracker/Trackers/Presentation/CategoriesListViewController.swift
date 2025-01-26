//
//  CreateCategoryViewController.swift
//  Tracker
//
//  Created by Olga Trofimova on 29.11.2024.
//

import UIKit


protocol SelectedCategoryDelegate: AnyObject {
    func categoryDidSelect(name: String)
}

final class CategoriesListViewController: UIViewController {
    
    weak var delegate: SelectedCategoryDelegate?
    private var storage = UserDefaultsService.shared
    private var viewModel: CategoriesViewModel
    private var isEditMode: Bool = false
    private var selectIndexPath: IndexPath?
    
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
    
    // MARK: - Initializers
    
    init(viewModel: CategoriesViewModel, isEditMode: Bool) {
        self.viewModel = viewModel
        self.isEditMode = isEditMode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        viewModel.categoriesBinding = { [weak self] categories in
            guard let self else { return }
            self.tableView.reloadData()
        }
        viewModel.fetchCategories()
        checkCategoriesIsEmpty()
    }
    
    // MARK: - Public Methods
    
    func selectedCategory(at title: String) {
        storage.setSelectedCategory(title)
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        view.backgroundColor = .ypWhite
        view.addSubviews([tableView, addCategoryButton, stackView])
        navigationItem.title = "Категория"
        navigationItem.hidesBackButton = true
        setupTableViewConstraints()
        setupButtonConstraints()
    }
    
    private func setupButtonConstraints() {
        
        NSLayoutConstraint.activate([
            
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            view.trailingAnchor.constraint(equalTo: addCategoryButton.trailingAnchor, constant: 20),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: addCategoryButton.bottomAnchor, constant: 16),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.topAnchor.constraint(greaterThanOrEqualTo: tableView.bottomAnchor, constant: 24)
        ])
        
    }
    
    private func setupTableViewConstraints() {
        
        NSLayoutConstraint.activate([
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: 16),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(75 * viewModel.categoriesAmount)),
            
        ])
        
    }
    
    private func setupNewTableViewHeightConstraints() {
        let cellCount = viewModel.categoriesAmount
        
        let tableViewHeightConstraint = tableView.constraints.first { $0.firstAttribute == .height }
        if let tableViewHeightConstraint {
            tableViewHeightConstraint.priority = .defaultLow
            tableViewHeightConstraint.constant = CGFloat(75 * cellCount)
            tableViewHeightConstraint.isActive = true
        }
        
        view.layoutIfNeeded()
        
    }
    
    private func setupStackViewConstraints() {
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func checkCategoriesIsEmpty() {
        let categoriesIsEmpty = viewModel.categories.isEmpty
        stackView.isHidden = !categoriesIsEmpty
        tableView.isHidden = categoriesIsEmpty
        
        if categoriesIsEmpty {
            setupStackViewConstraints()
        }
        
    }
    
    private func updateAllCategories() {
        viewModel.fetchCategories()
        checkCategoriesIsEmpty()
        setupNewTableViewHeightConstraints()
    }
    
    @objc
    private func addCategory() {
        let createCategoryVC = CreateCategoryViewController()
        createCategoryVC.delegate = self
        let newNavController = UINavigationController(rootViewController: createCategoryVC)
        navigationController?.present(newNavController, animated: true)
    }
}

extension CategoriesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categoriesAmount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newCategoryCell", for: indexPath)
        cell.textLabel?.text = viewModel.getCategoryTitle(at: indexPath.row)
        cell.backgroundColor = .ypBackgroundDay
        if cell.textLabel?.text == storage.selectedCategory, isEditMode {
            cell.accessoryType = .checkmark
            selectIndexPath = IndexPath(row: indexPath.row, section: indexPath.section)
        } else {
            cell.accessoryType = .none
        }
        cell.selectionStyle = .none
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return cell
    }
    
}

extension CategoriesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if selectIndexPath != indexPath, isEditMode {
                cell.accessoryType = .checkmark
                if let selectIndexPath {
                    let prevCell = tableView.cellForRow(at: selectIndexPath)
                    prevCell?.accessoryType = .none
                }
                guard let title = viewModel.getCategoryTitle(at: indexPath.row) else { return }
                storage.setSelectedCategory(title)
                delegate?.categoryDidSelect(name: title)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.dismiss(animated: true)
                }
            } else {
                cell.accessoryType = .none
            }
            
            selectIndexPath = nil
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if isEditMode {
            return nil
        }
        
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self else { return UIMenu() }
            
            let editAction = UIAction(title: "Редактировать") { _ in
                self.editTracker(at: indexPath)
            }
            
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { _ in
                self.deleteTracker(at: indexPath)
            }
            
            return UIMenu(options: UIMenu.Options.displayInline, children: [editAction, deleteAction])
        }
        
        return configuration
    }
    
    private func editTracker(at indexPath: IndexPath) {
        let title = viewModel.getCategoryTitle(at: indexPath.row)
        let createCategoryVC = CreateCategoryViewController()
        createCategoryVC.delegate = self
        guard let title else { return }
        createCategoryVC.categoryForEdit(with: title)
        let newNavController = UINavigationController(rootViewController: createCategoryVC)
        navigationController?.present(newNavController, animated: true)
    }
    
    private func deleteTracker(at indexPath: IndexPath) {
        let actionSheet = UIAlertController(title: "Эта категория точно не нужна?", message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self else { return }
            viewModel.deleteCategory(at: indexPath.row)
            updateAllCategories()
        }
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel, handler: nil)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        present(actionSheet, animated: true)
        updateAllCategories()
    }
    
}

extension CategoriesListViewController: CreateNewCategoryDelegate  {
    func didUpdateCategory(oldTitle: String, newTitle: String) {
        viewModel.updateCategory(oldTitle: oldTitle, with: newTitle)
        viewModel.fetchCategories()
    }
    
    func didCreateCategory(name: String) {
        viewModel.addCategory(TrackerCategory(title: name, trackers: []))
        updateAllCategories()
    }
}
