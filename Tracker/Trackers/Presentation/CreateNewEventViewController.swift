//
//  CreateNewEventViewController.swift
//  Tracker
//
//  Created by Olga Trofimova on 07.12.2024.
//

import UIKit

final class CreateNewEventViewController: UIViewController {
    
    private let trackersService = TrackersService.shared
    private var categoryName: String?
    // событие должно переноситься на следующий день, если не выполнено
    private var schedule: [WeekDay] = WeekDay.allCases
    private let isHabit: Bool = false
    private let buttonsName: [String] = ["Категория"]
    private let reuseIdentifier: String = "newEventCell"
    private let emojis = EmojisAndColors.shared.getEmojis()
    private let colors = EmojisAndColors.shared.getColors()
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var emojiIndexPath: IndexPath?
    private var colorIndexPath: IndexPath?
    private let maximumTextCount: Int = 38
    
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
        button.addTarget(self, action: #selector(createNewEvent), for: .touchUpInside)
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
        print(schedule.count)
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        view.backgroundColor = .ypWhite
        view.addSubviews([textStackView, tableView, collectionView, buttonStackView])
        navigationItem.title = "Новое нерегулярное событие"
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
            tableView.heightAnchor.constraint(equalToConstant: 75),
            
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
        let categoryViewController = CategoriesListViewController()
        categoryViewController.delegate = self
        let newNavController = UINavigationController(rootViewController: categoryViewController)
        navigationController?.present(newNavController, animated: true)
    }
    
    private func enableCreateButton() {
        let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let category = categoryName?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let text = text,
              let category = category,
              !text.isEmpty,
              !category.isEmpty,
              text.count <= maximumTextCount,
              selectedEmoji != nil,
              selectedColor != nil
        else { return }
        
        createButton.backgroundColor = .ypBlack
        createButton.isEnabled = true
    }
    
    @objc
    private func createNewEvent() {
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

extension CreateNewEventViewController: UITableViewDataSource {
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
        cell.detailTextLabel?.text = categoryName
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        if indexPath.row == buttonsName.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        return cell
    }
}

extension CreateNewEventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showCreateCategoryViewController()
    }
}

extension CreateNewEventViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        enableCreateButton()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, text.count >= maximumTextCount {
            cautionLabel.isHidden = false
        } else {
            cautionLabel.isHidden = true
        }
        return true
    }
}

extension CreateNewEventViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath) as? EmojisOrColorsCell
        guard let cell else { return UICollectionViewCell() }
        if indexPath.section == 0 {
            cell.configureEmoji(with: emojis[indexPath.row])
        } else if indexPath.section == 1 {
            cell.configureColor(with: colors[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "emojiOrColorHeader", for: indexPath) as? HeaderSupplementaryView
        guard let header else { return UICollectionReusableView()}
        // TODO: - Подумать как лучше сделать без ифов
        let section = indexPath.section // привести к единому виду
        if section == 0 {
            header.configureHeader(with: "Emoji")
        } else if section == 1 {
            header.configureHeader(with: "Цвет")
        }
        return header
    }
    
}

extension CreateNewEventViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath) as? HeaderSupplementaryView
        guard let headerView else { return .zero }
        return headerView.systemLayoutSizeFitting(
            CGSize(width: collectionView.frame.width, height: 18),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // TODO: - вынести константы в переменные - 5 - отступы, 5 - количество отступов (количество элементов - 1), 36 - сум отступы от краев
        return CGSize(width: (collectionView.bounds.width - 36 - (5 * 5))/6, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? EmojisOrColorsCell
        if indexPath.section == 0 {
            if selectedEmoji != nil {
                guard let previewCellIndex = emojiIndexPath else { return }
                let newCell = collectionView.cellForItem(at: previewCellIndex) as? EmojisOrColorsCell
                newCell?.deselectedEmoji()
            }
            cell?.selectedEmoji()
            selectedEmoji = emojis[indexPath.row]
            emojiIndexPath = indexPath
        } else if indexPath.section == 1 {
            if selectedColor != nil {
                guard let previewCellIndex = colorIndexPath else { return }
                let newCell = collectionView.cellForItem(at: previewCellIndex) as? EmojisOrColorsCell
                newCell?.deselectedColor()
            }
            cell?.selectedColor(with: colors[indexPath.row])
            selectedColor = colors[indexPath.row]
            colorIndexPath = indexPath
        }
        
        enableCreateButton()
    }
    
}

extension CreateNewEventViewController: SelectedCategoryDelegate {
    func categoryDidSelect(name: String) {
        categoryName = name
        tableView.reloadData()
        enableCreateButton()
    }
}

