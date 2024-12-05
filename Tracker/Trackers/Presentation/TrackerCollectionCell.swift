//
//  TrackerCollectionCell.swift
//  Tracker
//
//  Created by Olga Trofimova on 02.12.2024.
//

import UIKit

protocol CompletedTrackerDelegate: AnyObject {
    func appendTrackerRecord(tracker id: UUID, at indexPath: IndexPath)
    func removeTrackerRecord(tracker id: UUID, at indexPath: IndexPath)
}

final class TrackerCollectionCell: UICollectionViewCell {
    
    weak var delegate: CompletedTrackerDelegate?
    
    var daysCount: Int = 0
    var id: UUID?
    var indexPath: IndexPath?
    var isCompleted: Bool = false

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
        return label
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypWhite
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()
    
    lazy var plusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .ypWhite
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = randomColor()
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var backgroundEmojiView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhite.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        return view
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
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
    
    func configureCell(with tracker: Tracker, isCompleted: Bool, selectedDate: Date, daysCount: Int, at indexPath: IndexPath) {
        titleLabel.text = tracker.title
        colorView.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        self.isCompleted = isCompleted
        self.daysCount = daysCount
        // добавить функцию склоняющую окончания
        dateLabel.text = "\(self.daysCount) дней"
        
        let buttonImage = isCompleted ? UIImage(named: "done") : UIImage(systemName: "plus")
        plusButton.setImage(buttonImage, for: .normal)
        plusButton.alpha = isCompleted ?  0.3 : 1
        
        id = tracker.id
        self.indexPath = indexPath
        
        if selectedDate > Date() {
            plusButton.isHidden = true
        } else {
            plusButton.isHidden = false
        }
    }
    
    // MARK: - Private Methods
    private func setupView() {
        contentView.backgroundColor = .ypWhite
        contentView.addSubviews([colorView, backgroundEmojiView, emojiLabel, titleLabel, dateLabel, plusButton])
        print("isCompleted \(isCompleted)")
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
            
            emojiLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 16),
            emojiLabel.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: backgroundEmojiView.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: backgroundEmojiView.bottomAnchor, constant: 8),
            colorView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 12),
            colorView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            colorView.trailingAnchor.constraint(equalTo: plusButton.trailingAnchor, constant: 16),
            plusButton.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 8),
            contentView.bottomAnchor.constraint(equalTo: plusButton.bottomAnchor, constant: 16),
            
            dateLabel.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12)
            
        ])
    }
    
    @objc
    private func plusButtonTapped() {
        guard let id = id,
              let indexPath = indexPath else {
            print("not id")
            return
        }
        
        if !isCompleted {
            delegate?.appendTrackerRecord(tracker: id, at: indexPath)
        } else {
            delegate?.removeTrackerRecord(tracker: id, at: indexPath)
        }
    }
}
