//
//  ScheduleTableViewCell.swift
//  Tracker
//
//  Created by Olga Trofimova on 30.11.2024.
//

import UIKit

protocol WeekDayDelegate: AnyObject {
    func selected(day: Int)
    func deselected(day: Int)
}

final class ScheduleTableViewCell: UITableViewCell {
    
    var day: Int?
    weak var delegate: WeekDayDelegate?
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return label
    }()
    
    lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
//        switchControl.setOn(false, animated: true)
        switchControl.onTintColor = .ypBlue
        switchControl.addTarget(self, action: #selector(selectChanged), for: .valueChanged)
        return switchControl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.addSubviews([label, switchControl])
        contentView.backgroundColor = .ypBackgroundDay
        self.selectionStyle = .none
        self.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    private func setupConstraint() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22),
            contentView.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 22),
            
            switchControl.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: switchControl.trailingAnchor, constant: 16),
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    @objc
    private func selectChanged(_ sender: UISwitch) {
        guard let day else { return }
        sender.isOn ? delegate?.selected(day: day) : delegate?.deselected(day: day)
    }
}
