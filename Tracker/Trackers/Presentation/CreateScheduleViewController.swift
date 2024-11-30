//
//  CreateScheduleViewController.swift
//  Tracker
//
//  Created by Olga Trofimova on 29.11.2024.
//

import UIKit

enum WeekDay: String {
    case monday = "Понедельник"
    case tuersday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
}

enum ShortWeekDay: String {
    case monday = "Пн"
    case tuersday = "Вт"
    case wednesday = "Ср"
    case thursday = "Чт"
    case friday = "Пт"
    case saturday = "Сб"
    case sunday = "Вс"
}

final class CreateScheduleViewController: UIViewController {
    
    private let weekDay: [String] = [
        WeekDay.monday.rawValue,
        WeekDay.tuersday.rawValue,
        WeekDay.wednesday.rawValue,
        WeekDay.thursday.rawValue,
        WeekDay.friday.rawValue,
        WeekDay.saturday.rawValue,
        WeekDay.sunday.rawValue
    ]
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.backgroundColor = .ypBackgroundDay
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: "scheduleCell")
        return tableView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.baseConfiguration(with: "Готово")
        button.addTarget(self, action: #selector(createNewSchedule), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        navigationItem.title = "Расписание"
        view.backgroundColor = .ypWhite
        view.addSubviews([tableView, doneButton])
        if UIDevice().name.contains("iPhone SE") {
            tableView.isScrollEnabled = true
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: 16),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(75 * weekDay.count)),
            
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            view.trailingAnchor.constraint(equalTo: doneButton.trailingAnchor, constant: 20),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: doneButton.bottomAnchor, constant: 16),
            doneButton.topAnchor.constraint(greaterThanOrEqualTo: tableView.bottomAnchor, constant: 24)
        ])
    }
    
    private func configureCell(with cell: ScheduleTableViewCell, for indexPath: IndexPath) {
        cell.label.text = weekDay[indexPath.row]
        cell.switchControl.isOn = false
        
        if indexPath.row == weekDay.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        }
    }
    
    @objc
    private func createNewSchedule() {
        
    }
    
    
}


extension CreateScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weekDay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell", for: indexPath)
        
        guard let imageCell = cell as? ScheduleTableViewCell else {
            return UITableViewCell()
        }
       
        configureCell(with: imageCell, for: indexPath)
        return imageCell
    }
    
    
}

extension CreateScheduleViewController: UITableViewDelegate {
    
}
