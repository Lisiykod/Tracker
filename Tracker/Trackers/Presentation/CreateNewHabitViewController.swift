//
//  CreateNewHabitViewController.swift
//  Tracker
//
//  Created by Olga Trofimova on 29.11.2024.
//

import UIKit

final class CreateNewHabitViewController: UIViewController {
    
    private let buttonsName: [String] = ["Категория", "Расписание"]
    var categoryName: String = "Важное"
    var schedule: [WeekDay] = []
    
    private lazy var textField: UITextField = {
        let textField = BasicTextField(placeholder: "Введите название трекера")
        textField.delegate = self
        return textField
    }()
    
    private lazy var cautionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypRed
        label.text = "Ограничение 38 символов"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
//        label.isHidden = true
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.baseSettings(with: UITableViewCell.self, reuseIdentifier: "newTrackerCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
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
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var textStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [textField, cautionLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
        tableView.reloadData()
        print(schedule.count)
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        view.backgroundColor = .ypWhite
        view.addSubviews([textStackView, tableView, buttonStackView])
        navigationItem.title = "Новая привычка"
        cautionLabel.isHidden = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            textStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: textStackView.trailingAnchor, constant: 16),
            textStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textStackView.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: textStackView.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: textStackView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: textStackView.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            view.trailingAnchor.constraint(equalTo: buttonStackView.trailingAnchor, constant: 20),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(lessThanOrEqualTo: buttonStackView.bottomAnchor, constant: 24)
        ])
        
    }
    
    private func showCreateCategoryViewController() {
        let categoryViewController = CategoriesListViewController()
        categoryViewController.delegate = self
        let newNavController = UINavigationController(rootViewController: categoryViewController)
        navigationController?.present(newNavController, animated: true)
    }
    
    private func showCreateScheduleViewController() {
        let scheduleViewController = CreateScheduleViewController()
        scheduleViewController.delegate = self
        let newNavController = UINavigationController(rootViewController: scheduleViewController)
        navigationController?.present(newNavController, animated: true)
    }
    
    private func enableCreateButton() {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              categoryName != "",
              !schedule.isEmpty
        else { return }
        
        if !text.isEmpty {
            createButton.isEnabled = true
        }
        createButton.backgroundColor = .ypBlack
    }
    
    private func showCautionView() {
        if let text = textField.text, text.count >= 1 {
            cautionLabel.isHidden = false
        } else {
            cautionLabel.isHidden = true
        }
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
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "newTrackerCell")
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = buttonsName[indexPath.row]
        cell.backgroundColor = .ypBackgroundDay
        cell.selectionStyle = .none
        cell.detailTextLabel?.textColor = .ypGray
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let item = buttonsName[indexPath.row]
        if item == "Категория" && !categoryName.isEmpty  {
            cell.detailTextLabel?.text = categoryName
        } else if item == "Расписание" && !schedule.isEmpty {
            if schedule.count == 7 {
                cell.detailTextLabel?.text = "Каждый день"
            } else {
                var daysForTitle: [String] = []
                for days in schedule {
                    daysForTitle.append(days.getShortDay())
                    cell.detailTextLabel?.text = daysForTitle.joined(separator: ", ")
                }
            }
            
        }
        
        if indexPath.row == buttonsName.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        return cell
    }
}

extension CreateNewHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = buttonsName[indexPath.row]
        if item == "Категория" {
            showCreateCategoryViewController()
        } else if item == "Расписание" {
            showCreateScheduleViewController()
        }
    }
}

extension CreateNewHabitViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        enableCreateButton()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, text.count >= 1 {
            cautionLabel.isHidden = false
        } else {
            cautionLabel.isHidden = true
        }
        return true
    }
}

extension CreateNewHabitViewController: SelectedCategoryDelegate {
    func categoryDidSelect(name: String) {
        categoryName = name
        navigationController?.popViewController(animated: true)
    }
}

extension CreateNewHabitViewController: SelectedScheduleDelegate {
    func didSelectSchedule(for days: [WeekDay]) {
        schedule = days
        tableView.reloadData()
    }
}

