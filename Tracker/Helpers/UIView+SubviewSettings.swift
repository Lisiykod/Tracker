//
//  UIView+SubviewSettings.swift
//  Tracker
//
//  Created by Olga Trofimova on 23.11.2024.
//

import UIKit

extension UIView {
    // добавляем сабвью
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }
    
    // привязываем границы к родительской View
    @discardableResult func edgesToSuperview() -> Self {
        guard let superview else {
            fatalError("View is not in the hierarchy")
        }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        return self
    }
}
