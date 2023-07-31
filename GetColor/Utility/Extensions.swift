//
//  Extensions.swift
//  GetColor
//
//  Created by Hương Lâm Quỳnh on 31/07/2023.
//

import Foundation
import UIKit

extension UIView {
    public enum BorderSide {
        case top, bottom, left, right
    }
    @objc func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.1
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 3, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 3, y: self.center.y))
        self.layer.add(animation, forKey: "position")
    }
    func dropShadow() {
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 0
        self.layer.masksToBounds = false
    }
    func addBorder(side: BorderSide, color: UIColor, width: CGFloat) {
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = color
        self.addSubview(border)
        
        let topConstraint = topAnchor.constraint(equalTo: border.topAnchor)
        let rightConstraint = trailingAnchor.constraint(equalTo: border.trailingAnchor)
        let bottomConstraint = bottomAnchor.constraint(equalTo: border.bottomAnchor)
        let leftConstraint = leadingAnchor.constraint(equalTo: border.leadingAnchor)
        let heightConstraint = border.heightAnchor.constraint(equalToConstant: width)
        let widthConstraint = border.widthAnchor.constraint(equalToConstant: width)
        
        
        switch side {
        case .top:
            NSLayoutConstraint.activate([leftConstraint, topConstraint, rightConstraint, heightConstraint])
        case .right:
            NSLayoutConstraint.activate([topConstraint, rightConstraint, bottomConstraint, widthConstraint])
        case .bottom:
            NSLayoutConstraint.activate([rightConstraint, bottomConstraint, leftConstraint, heightConstraint])
        case .left:
            NSLayoutConstraint.activate([bottomConstraint, leftConstraint, topConstraint, widthConstraint])
        }
    }
    
    
    func addGradient(colors: [UIColor] = [.blue, .white], locations: [NSNumber] = [0, 2], startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0), endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0), type: CAGradientLayerType = .axial){
           
           let gradient = CAGradientLayer()
           
           gradient.frame.size = self.frame.size
           gradient.frame.origin = CGPoint(x: 0.0, y: 0.0)

           // Iterates through the colors array and casts the individual elements to cgColor
           // Alternatively, one could use a CGColor Array in the first place or do this cast in a for-loop
           gradient.colors = colors.map{ $0.cgColor }
           
           gradient.locations = locations
           gradient.startPoint = startPoint
           gradient.endPoint = endPoint
           
           // Insert the new layer at the bottom-most position
           // This way we won't cover any other elements
           self.layer.insertSublayer(gradient, at: 0)
       }
}
