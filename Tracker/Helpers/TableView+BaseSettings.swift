//
//  TableView+BaseSettings.swift
//  Tracker
//
//  Created by Olga Trofimova on 01.12.2024.
//

import UIKit

extension UITableView {
    func baseSettings(with cell: AnyClass, reuseIdentifier: String) {
        let tableView = self
        tableView.backgroundColor = .ypBackgroundDay
        tableView.layer.cornerRadius = 16
        tableView.rowHeight = 75
        tableView.register(cell, forCellReuseIdentifier: reuseIdentifier)
    }
}
