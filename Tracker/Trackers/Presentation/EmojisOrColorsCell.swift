//
//  EmojisOrColorsCell.swift
//  Tracker
//
//  Created by Olga Trofimova on 14.12.2024.
//

import UIKit

final class EmojisOrColorsCell: UICollectionViewCell {
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var emojiBackground: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        return view
    }()
    
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        return view
    }()
    
    private lazy var colorViewSelectedBackground: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 8
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func configureEmoji(with emoji: String) {
        emojiLabel.text = emoji
    }
    
    func configureColor(with color: UIColor) {
        colorView.backgroundColor = color
    }
    
    func selectedColor(with color: UIColor) {
        colorViewSelectedBackground.layer.borderWidth = 3
        colorViewSelectedBackground.layer.borderColor = color.withAlphaComponent(0.3).cgColor
    }
    
    func deselectedColor() {
        colorViewSelectedBackground.layer.borderWidth = 0
        colorViewSelectedBackground.layer.borderColor = .none
    }
    
    func selectedEmoji() {
        emojiBackground.layer.cornerRadius = 16
        emojiBackground.backgroundColor = .ypBackgroundDay.withAlphaComponent(1.0)
    }
    
    func deselectedEmoji() {
        emojiBackground.backgroundColor = .none
    }
    // MARK: - Private Methods
    
    private func setupView() {
        contentView.backgroundColor = .ypWhite
        contentView.addSubviews([emojiBackground, emojiLabel, colorViewSelectedBackground, colorView])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            emojiBackground.heightAnchor.constraint(equalToConstant: 52),
            emojiBackground.widthAnchor.constraint(equalToConstant: 52),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackground.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackground.centerYAnchor),
            
            colorViewSelectedBackground.heightAnchor.constraint(equalToConstant: 52),
            colorViewSelectedBackground.widthAnchor.constraint(equalToConstant: 52),
            
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            
            colorView.centerXAnchor.constraint(equalTo: colorViewSelectedBackground.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: colorViewSelectedBackground.centerYAnchor)
        ])
    }
}
