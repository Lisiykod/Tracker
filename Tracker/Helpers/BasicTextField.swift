//
//  BasicTextField.swift
//  Tracker
//
//  Created by Olga Trofimova on 01.12.2024.
//

import UIKit

final class BasicTextField: UITextField {
    let padding: UIEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 41)
    
    init(placeholder: String) {
        super.init(frame: .zero)
        self.backgroundColor = .ypBackgroundDay
        self.layer.cornerRadius = 16
        self.placeholder = placeholder
        self.clearButtonMode = .whileEditing
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
