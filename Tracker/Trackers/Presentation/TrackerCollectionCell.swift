//
//  TrackerCollectionCell.swift
//  Tracker
//
//  Created by Olga Trofimova on 02.12.2024.
//

import UIKit

final class TrackerCollectionCell: UICollectionViewCell {
    
    var count: Int = 0
    
    let colors: [UIColor] = [.ypColorSelection1, .ypColorSelection2, .ypColorSelection3, .ypColorSelection4, .ypColorSelection5, .ypColorSelection6, .ypColorSelection7, .ypColorSelection8, .ypColorSelection9, .ypColorSelection10, .ypColorSelection11, .ypColorSelection12, .ypColorSelection13, .ypColorSelection14, .ypColorSelection15, .ypColorSelection16, .ypColorSelection17, .ypColorSelection18]
    let emojis: [String] = ["🙂","😻","🌺","🐶","❤️","😱","😇","😡","🥶","🤔","🍺","🍔","🥦","🏓","🥇","🎸","🏝","😪"]
    
    lazy var colorView: UIView = {
        let view = UIView()
        view.backgroundColor = randomColor()
        view.layer.cornerRadius = 16
        return view
    }()
    
    lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.text = randomEmoji()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var backgroundEmojiView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhite.withAlphaComponent(0.3)
        view.layer.cornerRadius = 68
        view.addSubview(emojiLabel)
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypWhite
        label.textAlignment = .right
        label.numberOfLines = 2
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.text = "\(count) дней"
        return label
    }()
    
    lazy var plusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = randomColor()
        button.layer.cornerRadius = button.bounds.height/2
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var isCompleted: Bool = false
    
    // временные функции
    func randomColor() -> UIColor {
        let color = colors.randomElement()
        guard let color else { return .white }
        return color
        
    }
    
    func randomEmoji() -> String {
        let emoji = emojis.randomElement()
        guard let emoji else { return "" }
        return emoji
    }
    
    // MARK: - Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    private func setupView() {
        contentView.backgroundColor = .ypWhite
        contentView.addSubviews([colorView, backgroundEmojiView, titleLabel, dateLabel, plusButton])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentView.trailingAnchor.constraint(equalTo: colorView.trailingAnchor),
            
            backgroundEmojiView.widthAnchor.constraint(equalToConstant: 24),
            backgroundEmojiView.heightAnchor.constraint(equalToConstant: 24),
            backgroundEmojiView.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            backgroundEmojiView.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
            
            titleLabel.leadingAnchor.constraint(equalTo: backgroundEmojiView.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: backgroundEmojiView.bottomAnchor, constant: 8),
            colorView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 12),
            colorView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            colorView.trailingAnchor.constraint(equalTo: plusButton.trailingAnchor, constant: 16),
            colorView.bottomAnchor.constraint(equalTo: plusButton.topAnchor, constant: 16),
            
            dateLabel.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12)

        ])
    }
    
    @objc
    private func plusButtonTapped() {
        if !isCompleted {
            count += 1
            isCompleted.toggle()
            plusButton.setImage(UIImage(named: "done"), for: .normal)
        } else {
            if count > 0 {
                count -= 1
            }
            isCompleted.toggle()
            plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
        }
        
        dateLabel.text = "\(count) дней"
        
        // добавить функцию склоняющую окончания
    }
}
