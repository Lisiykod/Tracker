//
//  StatisticCell.swift
//  Tracker
//
//  Created by Olga Trofimova on 24.01.2025.
//

import UIKit

final class StatisticCell: UITableViewCell {
    
    private lazy var gradient: CAGradientLayer = {
        let layer = CAGradientLayer()
        let colorOne = UIColor.ypColorSelection3.cgColor
        let colorTwo = UIColor.ypColorSelection9.cgColor
        let colorThree = UIColor.ypColorSelection1.cgColor
        layer.colors = [colorOne, colorTwo, colorThree]
        layer.startPoint = .init(x: 0, y: 0.5)
        layer.endPoint = .init(x: 1, y: 0.5)
                
        let shape = CAShapeLayer()
        shape.lineWidth = 1
        shape.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 16).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        layer.mask = shape
                
        self.clipsToBounds = true
        self.layer.addSublayer(layer)
    
        return layer
    }()
    
    private lazy var gradientView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlack
        label.textAlignment = .left
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = gradientView.bounds
        gradientView.layer.addSublayer(gradient)
    }
    
    // MARK: - Public Methods
    
    func configureCell(completedDays: Int, description: String) {
        dayLabel.text = "\(completedDays)"
        descriptionLabel.text = description
    }
    
    // MARK: - Private Methods
    
    private func setupCell() {
        contentView.addSubviews([gradientView, dayLabel, descriptionLabel])
        contentView.backgroundColor = .ypWhite
        contentView.layer.cornerRadius = 16
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.addSubview(gradientView)
        selectionStyle = .none
        separatorInset = .zero
        
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            gradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            gradientView.topAnchor.constraint(equalTo: contentView.topAnchor),
            gradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            dayLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            contentView.trailingAnchor.constraint(equalTo: dayLabel.trailingAnchor, constant: 12),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: dayLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: dayLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 7)
            
        ])
    }
}
