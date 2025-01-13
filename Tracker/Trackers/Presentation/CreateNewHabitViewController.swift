//
//  CreateNewHabitViewController.swift
//  Tracker
//
//  Created by Olga Trofimova on 29.11.2024.
//

import UIKit

final class CreateNewHabitViewController: UIViewController {
    
    private let trackersService = TrackersService.shared
    private var categoryName: String?
    private var schedule: [WeekDay] = []
    private let buttonsName: [String] = ["Категория", "Расписание"]
    private let reuseIdentifier: String = "newTrackerCell"
    private let isHabit: Bool = true
    private let emojis = EmojisAndColors.shared.getEmojis()
    private let colors = EmojisAndColors.shared.getColors()
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var emojiIndexPath: IndexPath?
    private var colorIndexPath: IndexPath?
    
    private enum EmojisOrColors: Int {
        case emojis = 0
        case colors = 1
    }
    
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
        label.isHidden = true
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.baseSettings(with: UITableViewCell.self, reuseIdentifier: reuseIdentifier)
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
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(EmojisOrColorsCell.self, forCellWithReuseIdentifier: "emojiCell")
        collectionView.register(HeaderSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "emojiOrColorHeader")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .ypWhite
        return collectionView
    }()
    
    // MARK: - Initializers
    
    init(isHabit: Bool) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        view.backgroundColor = .ypWhite
        view.addSubviews([textStackView, tableView, buttonStackView, collectionView])
        navigationItem.title = "Новая привычка"
        cautionLabel.isHidden = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            textStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: textStackView.trailingAnchor, constant: 16),
            textStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: textStackView.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: textStackView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: textStackView.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            view.trailingAnchor.constraint(equalTo: buttonStackView.trailingAnchor, constant: 20),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(lessThanOrEqualTo: buttonStackView.bottomAnchor, constant: 24),
            buttonStackView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
            
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32)
        ])
        
    }
    
    private func showCreateCategoryViewController() {
        let viewModel = CategoriesViewModel()
        let categoryViewController = CategoriesListViewController(viewModel: viewModel)
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
        let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let category = categoryName?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let text = text,
              let category = category,
              !text.isEmpty,
              !category.isEmpty,
              !schedule.isEmpty,
              text.count <= ConstantsForHabitOrEventVC.maximumTextCount,
              selectedEmoji != nil,
              selectedColor != nil
        else { return }
        
        createButton.backgroundColor = .ypBlack
        createButton.isEnabled = true
    }
    
    @objc
    private func createNewHabit() {
        guard let title = textField.text,
              let categoryName = categoryName,
              let selectedEmoji = selectedEmoji,
              let selectedColor = selectedColor
        else { return }
        let newTracker = Tracker(
            id: UUID(),
            title: title,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: schedule,
            isHabit: isHabit
        )
        trackersService.addTracker(tracker: newTracker, for: categoryName)
        view?.window?.rootViewController?.dismiss(animated: true)
    }
    
    @objc
    private func createCanceled() {
        view?.window?.rootViewController?.dismiss(animated: true)
    }
    
}

extension CreateNewHabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buttonsName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = buttonsName[indexPath.row]
        cell.backgroundColor = .ypBackgroundDay
        cell.selectionStyle = .none
        cell.detailTextLabel?.textColor = .ypGray
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let item = buttonsName[indexPath.row]
        if item == "Категория" {
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
        if let text = textField.text, text.count >= ConstantsForHabitOrEventVC.maximumTextCount {
            cautionLabel.isHidden = false
        } else {
            cautionLabel.isHidden = true
        }
        return true
    }
}

extension CreateNewHabitViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath) as? EmojisOrColorsCell
        guard let cell else { return UICollectionViewCell() }
        
        let section = EmojisOrColors(rawValue: indexPath.section)
        switch section {
        case .emojis:
            cell.configureEmoji(with: emojis[indexPath.row])
        case .colors:
            cell.configureColor(with: colors[indexPath.row])
        case .none:
            print("\(#function) not section")
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "emojiOrColorHeader", for: indexPath) as? HeaderSupplementaryView
        guard let header else { return UICollectionReusableView()}
        
        let section = EmojisOrColors(rawValue: indexPath.section)
        switch section {
        case .emojis:
            header.configureHeader(with: "Emoji")
        case .colors:
            header.configureHeader(with: "Цвет")
        case .none:
            header.configureHeader(with: "")
        }
        
        return header
    }
    
}

extension CreateNewHabitViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - (ConstantsForHabitOrEventVC.leftOrRightInset * 2) - (ConstantsForHabitOrEventVC.itemsSpacing * (ConstantsForHabitOrEventVC.itemsOnRow - 1)))/ConstantsForHabitOrEventVC.itemsOnRow
        return CGSize(
            width: width,
            height: 52
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return ConstantsForHabitOrEventVC.itemsSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: ConstantsForHabitOrEventVC.topOrBottomInset,
            left: ConstantsForHabitOrEventVC.leftOrRightInset,
            bottom: ConstantsForHabitOrEventVC.topOrBottomInset,
            right: ConstantsForHabitOrEventVC.leftOrRightInset
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? EmojisOrColorsCell
        
        let section = EmojisOrColors(rawValue: indexPath.section)
        switch section {
        case .emojis:
            if selectedEmoji != nil {
                guard let previewCellIndex = emojiIndexPath else { return }
                let newCell = collectionView.cellForItem(at: previewCellIndex) as? EmojisOrColorsCell
                newCell?.deselectedEmoji()
            }
            cell?.selectedEmoji()
            selectedEmoji = emojis[indexPath.row]
            emojiIndexPath = indexPath
        case .colors:
            if selectedColor != nil {
                guard let previewCellIndex = colorIndexPath else { return }
                let newCell = collectionView.cellForItem(at: previewCellIndex) as? EmojisOrColorsCell
                newCell?.deselectedColor()
            }
            cell?.selectedColor(with: colors[indexPath.row])
            selectedColor = colors[indexPath.row]
            colorIndexPath = indexPath
        case .none:
            print("not items for selection")
        }
        
        enableCreateButton()
    }
    
}

extension CreateNewHabitViewController: SelectedCategoryDelegate {
    func categoryDidSelect(name: String) {
        categoryName = name
        tableView.reloadData()
        enableCreateButton()
    }
}

extension CreateNewHabitViewController: SelectedScheduleDelegate {
    func didSelectSchedule(for days: [WeekDay]) {
        schedule = days
        tableView.reloadData()
        enableCreateButton()
    }
}

