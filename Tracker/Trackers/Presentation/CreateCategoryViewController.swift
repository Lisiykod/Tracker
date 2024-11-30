//
//  CreateCategoryViewController.swift
//  Tracker
//
//  Created by Olga Trofimova on 29.11.2024.
//

import UIKit

final class CreateCategoryViewController: UIViewController {
    
    weak var delegate: CreateCategoryDelegate?
    
    private lazy var textField: UITextField = {
        let textField = BasicTextField(placeholder: "Введите название категории")
        textField.delegate = self
        return textField
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.baseConfiguration(with: "Готово")
        button.backgroundColor = .ypGray
        button.isEnabled = false
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
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
        view.addSubviews([textField, doneButton])
        navigationItem.hidesBackButton = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 16),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            view.trailingAnchor.constraint(equalTo: doneButton.trailingAnchor, constant: 20),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo:doneButton.bottomAnchor, constant: 16)
        ])
    }
    
    private func enableDoneButton() {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        if !text.isEmpty {
            doneButton.isEnabled = true
        }
        doneButton.backgroundColor = .ypBlack
    }
    
    @objc
    private func doneButtonTapped() {
        guard let text = textField.text else { return }
        delegate?.didCreateCategory(name: text)
        print("done button tapped")
//        navigationController?.popToViewController(self, animated: true)
        navigationController?.dismiss(animated: true)
    }

}


extension CreateCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        enableDoneButton()
        return true
    }
}


