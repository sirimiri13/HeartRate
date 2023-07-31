//
//  VerifyTextField.swift
//  GetColor
//
//  Created by Hương Lâm Quỳnh on 29/07/2023.
//

import Foundation
import UIKit

class VerifyCodeTextField: UITextField {
    private var isConfigured = false
    private var digitLabel = [UILabel]()
    var didEnterLastDigit : ((String) -> Void)?
    var notendOfDigit: ((String)->Void)?
    
    private lazy var tapRecognizer : UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()
        recognizer.addTarget(self, action: #selector(becomeFirstResponder))
        return recognizer
    }()
    
    func configure(with slot: Int = 6){
        guard isConfigured == false else {
            return
        }
        isConfigured.toggle()
        configuredTextField()
        
        let labelStackView = createStack(with: slot)
        addSubview(labelStackView)
        addGestureRecognizer(tapRecognizer)
        
        NSLayoutConstraint.activate([
            labelStackView.topAnchor.constraint(equalTo: topAnchor),
            labelStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            labelStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            labelStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    
    func configuredTextField(){
        tintColor = .clear
        textColor = .clear
        keyboardType = .numberPad
        textContentType  = .oneTimeCode
        
        addTarget(self, action: #selector(textDidChanged), for: .editingChanged)
    }
    
    private func createStack(with count: Int) -> UIStackView{
        let stackView = UIStackView()
        stackView.alignment  = .fill
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 8
        
        for _ in 1...count {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 30)
            label.isUserInteractionEnabled = true
            stackView.addArrangedSubview(label)
            label.text = "_"
            digitLabel.append(label)
        }
        
        
        return stackView
    }
    
    @objc func textDidChanged(){
        guard let text = self.text , text.count <= digitLabel.count else {return}
        
        
        for i in 0..<digitLabel.count {
            let currentLabel = digitLabel[i]
            if i < text.count {
                let index = text.index(text.startIndex, offsetBy: i)
                currentLabel.text = String(text[index])
            }
            else {
                currentLabel.text = "_"
            }
        }
        if (text.count == digitLabel.count){
            didEnterLastDigit!(text)
        }
        else {
            notendOfDigit!(text)
        }
    }
}

extension VerifyCodeTextField: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let characterCount = textField.text?.count else {return false}
        return (characterCount < digitLabel.count || string == "")
    }
}
