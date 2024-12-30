//
//  HeaderSupplementaryView.swift
//  Tracker
//
//  Created by Olga Trofimova on 02.12.2024.
//

import UIKit

final class HeaderSupplementaryView: UICollectionReusableView {
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        return label
    }()
    
    // MARK: - Life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews([headerLabel])
        setupTrackersConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func configureHeader(with text: String) {
        headerLabel.text = text
    }
    
    // MARK: - Private Methods
    
    private func setupTrackersConstraints() {
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
        ])
    }
}
