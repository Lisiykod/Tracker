//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Olga Trofimova on 05.01.2025.
//

import UIKit

final class OnboardingViewController: UIViewController {
    
    var completionHandler: (() -> Void)?
    
    private let launchService = UserDefaultsService.shared
    
    private lazy var button: UIButton = {
        let button = UIButton()
        let buttonTitle = NSLocalizedString("buttonTitle", comment: "Text displayed on onboarding page button")
        button.baseConfiguration(with: buttonTitle)
        button.addTarget(self, action: #selector(goToTrackers), for: .touchUpInside)
        return button
    }()
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var mainLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Initializers
    
    init(title: String, imageName: String) {
        super.init(nibName: nil, bundle: nil)
        backgroundImageView.image = UIImage(named: imageName)
        mainLabel.text = title
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
    
    // MARK: - Private Methods
    
    private func setupViews() {
        view.addSubviews([backgroundImageView, button, mainLabel])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            button.heightAnchor.constraint(equalToConstant: 60),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            view.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: 20),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: 50),
            
            mainLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: mainLabel.trailingAnchor, constant: 16),
            button.topAnchor.constraint(lessThanOrEqualTo: mainLabel.bottomAnchor, constant: 160)
            
        ])
    }
    
    @objc
    private func goToTrackers() {
        
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
            print("Invalid Configuration")
            return
        }
        
        sceneDelegate.goToTrackersComletionHandler?()
    }
}
