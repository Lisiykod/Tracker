//
//  CreateNewHabitViewController.swift
//  Tracker
//
//  Created by Olga Trofimova on 29.11.2024.
//

import UIKit

final class CreateNewHabitViewController: UIViewController {
    
    private let buttonsName: [String] = ["Категория", "Расписание"]
    
    // TODO: - добавить отступ плейсхолдеру, проверку на количество символов
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .ypBackgroundDay
        textField.placeholder = "Введите название трекера"
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        return textField
    }()
    
    private lazy var cautionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypRed
        label.text = "Ограничение 38 символов"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.isHidden = true
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .ypBackgroundDay
        tableView.layer.cornerRadius = 16
        tableView.rowHeight = 75
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "newTrackerCell")
        return tableView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.backgroundColor = .ypWhite
        button.layer.borderWidth = 1
        let borderColor: UIColor = .ypRed
        button.layer.borderColor = borderColor.cgColor
        button.addTarget(self, action: #selector(createCanceled), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.baseConfiguration(with: "Создать")
        button.backgroundColor = .ypGray
        button.addTarget(self, action: #selector(createNewHabit), for: .touchUpInside)
        button.isEnabled = true
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        view.backgroundColor = .ypWhite
        view.addSubviews([textField, cautionLabel, tableView, stackView])
        navigationItem.title = "Новая привычка"
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 16),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 20),
            stackView.heightAnchor.constraint(equalToConstant: 60),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
    }
    
    private func showCreateCategoryViewController() {
        let categoryViewController = CreateCategoryViewController()
        let newNavController = UINavigationController(rootViewController: categoryViewController)
        navigationController?.present(newNavController, animated: true)
    }
    
    private func showCreateScheduleViewController() {
        let scheduleViewController = CreateScheduleViewController()
        let newNavController = UINavigationController(rootViewController: scheduleViewController)
        navigationController?.present(newNavController, animated: true)
    }
    
    @objc
    private func createNewHabit() {
        
    }
    
    @objc
    private func createCanceled() {
        self.dismiss(animated: true)
    }
    
    
}


extension CreateNewHabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buttonsName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newTrackerCell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = buttonsName[indexPath.row]
        cell.backgroundColor = .ypBackgroundDay
//        cell.selectionStyle = .none
        return cell
    }
}

extension CreateNewHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            showCreateCategoryViewController()
        } else if indexPath.row == 1 {
            showCreateScheduleViewController()
        }
    }
}
