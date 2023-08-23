//
//  UnderlineTextField.swift
//  GetColor
//
//  Created by Hương Lâm Quỳnh on 20/08/2023.
//

import UIKit

class UnderlinedTextField: UITextField {
    private let defaultUnderlineColor = UIColor.black
    private let bottomLine = UIView()

    override func awakeFromNib() {
        super.awakeFromNib()
        borderStyle = .none
        contentVerticalAlignment = .center //added
        clearButtonMode = .unlessEditing //added
        font = UIFont.boldSystemFont(ofSize: 18) //added
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.backgroundColor = defaultUnderlineColor
        self.addSubview(bottomLine)
        bottomLine.topAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true //updated to make the line closer to the text
        bottomLine.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        bottomLine.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        bottomLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }

    public func setUnderlineColor(color: UIColor = .red) {
        bottomLine.backgroundColor = color
    }

    public func setDefaultUnderlineColor() {
        bottomLine.backgroundColor = defaultUnderlineColor
    }
}
