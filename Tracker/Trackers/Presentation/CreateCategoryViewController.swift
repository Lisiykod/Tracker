//
//  CreateCategoryViewController.swift
//  Tracker
//
//  Created by Olga Trofimova on 29.11.2024.
//

import UIKit

final class CreateCategoryViewController: UIViewController {
    
    weak var delegate: CreateNewCategoryDelegate?
    
    private let maximumTextCount: Int = 38
    
    private lazy var textField: UITextField = {
        let textField = BasicTextField(placeholder: "Введите название категории")
//        textField.translatesAutoresizingMaskIntoConstraints = false
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
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.baseConfiguration(with: "Готово")
        button.backgroundColor = .ypGray
        button.isEnabled = false
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [textField, cautionLabel])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
    // MARK: - Private Methods
    
    private func setupViews() {
        navigationItem.title = "Новая категория"
        view.backgroundColor = .ypWhite
        view.addSubviews([stackView, doneButton])
        navigationItem.hidesBackButton = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 75),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 16),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            view.trailingAnchor.constraint(equalTo: doneButton.trailingAnchor, constant: 20),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: doneButton.bottomAnchor, constant: 16)
        ])
    }
    
    private func enableDoneButton() {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty  else { return }
        
        doneButton.isEnabled = true
        doneButton.backgroundColor = .ypBlack
    }
    
    @objc
    private func doneButtonTapped() {
        guard let text = textField.text else { return }
        delegate?.didCreateCategory(name: text)
        navigationController?.dismiss(animated: true)
    }

}

extension CreateCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        enableDoneButton()
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


