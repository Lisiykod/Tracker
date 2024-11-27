//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Olga Trofimova on 23.11.2024.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    private lazy var emptyStatisticsImage: UIImageView = {
        let image = UIImage(named: "empty_statistics")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var emptyStatisticsLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emptyStatisticsImage, emptyStatisticsLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        view.addSubviews([stackView])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            emptyStatisticsImage.heightAnchor.constraint(equalToConstant: 80),
            emptyStatisticsImage.widthAnchor.constraint(equalToConstant: 80),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
