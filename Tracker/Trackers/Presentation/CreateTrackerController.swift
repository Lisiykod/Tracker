//
//  CreateTrackerController.swift
//  Tracker
//
//  Created by Olga Trofimova on 28.11.2024.
//

import UIKit

final class CreateTrackerController: UIViewController {
    
    private lazy var habbitButton: UIButton = {
        let button = UIButton()
        button.baseConfiguration(with: "Привычка")
        button.addTarget(self, action: #selector(createHabbit), for: .touchUpInside)
        return button
    }()
    
    private lazy var irregularEventButton: UIButton = {
        let button = UIButton()
        button.baseConfiguration(with: "Нерегулярное событие")
        button.addTarget(self, action: #selector(createEvent), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    // MARK: - Private Methods
    @objc
    private func createHabbit() {
        let newHabitController = CreateNewHabitViewController(isHabit: true)
        let newNavController = UINavigationController(rootViewController: newHabitController)
        navigationController?.present(newNavController, animated: true)
    }
    
    @objc
    private func createEvent() {
        let newEventController = CreateNewEventViewController(isHabit: false)
        let newNavController = UINavigationController(rootViewController: newEventController)
        navigationController?.present(newNavController, animated: true)
    }
    
    private func setupView() {
        view.backgroundColor = .ypWhite
        view.addSubviews([habbitButton, irregularEventButton])
        navigationItem.title = "Создание трекера"
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            habbitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            habbitButton.heightAnchor.constraint(equalToConstant: 60),
            habbitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            view.trailingAnchor.constraint(equalTo: habbitButton.trailingAnchor, constant: 20),
            
            irregularEventButton.heightAnchor.constraint(equalTo: habbitButton.heightAnchor),
            irregularEventButton.topAnchor.constraint(equalTo: habbitButton.bottomAnchor, constant: 16),
            irregularEventButton.leadingAnchor.constraint(equalTo: habbitButton.leadingAnchor),
            irregularEventButton.trailingAnchor.constraint(equalTo: habbitButton.trailingAnchor)
        ])
    }
}
