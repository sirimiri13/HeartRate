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


extension UITextField {
    func styleTextField(color: UIColor) {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: self.bounds.height - 2, width: self.bounds.width, height: 2)
        bottomLine.backgroundColor = color.cgColor
        self.borderStyle = .none
        self.layer.masksToBounds = true
        self.layer.addSublayer(bottomLine)
    }
}


extension UIButton {
    func setShadow(){
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 0
        self.layer.masksToBounds = false
    }
    func isAuthButton() {
        self.layer.cornerRadius = self.frame.height / 10
        self.clipsToBounds = true
    }
}


extension String {
    func emailEncryptedForFirebase() -> String { //string method that converts an email to a key that Firebase can accept. It first splits an email by "@", then convert "@" to a "_at_", and "_dot_" to a string
        let lastIndex = self.lastIndex(of: "@") //lastIndex because we want to search for @ from the end of the string //NOTE: make sure email being asked has @ symbol or it will crash
        let emailName = self.prefix(upTo: lastIndex!) //kobeBryant
        let emailDomain = self.suffix(from: lastIndex!) //@gmail.com
        let emailDomainWith_at_ = emailDomain.replacingOccurrences(of: "@", with: "_at_") //convert @ in emailDomain to _at_
        let newEmailDomain = emailDomainWith_at_.replacingOccurrences(of: ".", with: "_dot_") //conver all . in emailDomain to _dot_ //NOTE: must use this because email domain can have multiple "."
        return emailName + newEmailDomain
    }
    
    func emailDecryptedFromFirebase() -> String { //string method that converts an encrypted email back to original email
        let newEmail = self.replacingLastOccurrenceOfString("_at_", with: "@") //replace one occurence of _at_
        let lastIndex = newEmail.lastIndex(of: "@")
        let emailName = newEmail.prefix(upTo: lastIndex!)
        let emailDomain = newEmail.suffix(from: lastIndex!)
        let newEmailDomain = emailDomain.replacingOccurrences(of: "_dot_", with: ".") //NOTE: must use this because email domain can have multiple "."
        return emailName + newEmailDomain
    }
    
    func replacingLastOccurrenceOfString(_ searchString: String, with replacementString: String, caseInsensitive: Bool = true) -> String { //a string method that replace the last occurence of the searchString argument with replacementString argument. Used to convert _at_ back to @
        let options: String.CompareOptions
        if caseInsensitive { //search backwards, or search backwards and case sensitive
            options = [.backwards, .caseInsensitive]
        } else {
            options = [.backwards]
        }
        if let range = self.range(of: searchString,
                options: options,
                range: nil,
                locale: nil) { //get the range of index of the characters in the searchString
            return self.replacingCharacters(in: range, with: replacementString) //replace searchString's range with the replacementString argument
        }
        return self
    }
    
    var isValidEmail: Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}" //\\. is escape character for dot
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: self)
    }
    
    var isValidName: Bool {
        let regex = "[A-Za-z]*[ ]?[A-Za-z]*[.]?[ ]?[A-Za-z]{1,30}" //regex for full name //will take the following name formats, Samuel || Samuel P. || Samuel P. Folledo || Samuel Folledo
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        return test.evaluate(with: self) //evaluate
    }
    
    var isValidUsername: Bool {
        let regex = "[A-Z0-9a-zâéè._+-]{1,15}" //regex for user name //accept any US characters, other characters, and symbols like (. _ + -)
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        return test.evaluate(with: self) //evaluate
    }
    
    func trimmedString() -> String { //method that removes string's left and right white spaces and new lines
        let newWord: String = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return newWord
    }
}



extension CATransition {
    //New viewController will appear from bottom of screen.
    func segueFromBottom() -> CATransition {
        self.duration = 0.375 //set the duration to whatever you'd like.
        self.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.type = CATransitionType.moveIn
        self.subtype = CATransitionSubtype.fromTop
        return self
    }
    //New viewController will appear from top of screen.
    func segueFromTop() -> CATransition {
        self.duration = 0.375 //set the duration to whatever you'd like.
        self.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.type = CATransitionType.moveIn
        self.subtype = CATransitionSubtype.fromBottom
        return self
    }
     //New viewController will appear from left side of screen.
    func segueFromLeft() -> CATransition {
        self.duration = 0.1 //set the duration to whatever you'd like.
        self.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.type = CATransitionType.moveIn
        self.subtype = CATransitionSubtype.fromLeft
        return self
    }
    //New viewController will appear from left side of screen.
   func segueFromRight() -> CATransition {
       self.duration = 0.3 //set the duration to whatever you'd like.
       self.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
       self.type = CATransitionType.push
       self.subtype = CATransitionSubtype.fromRight
       return self
   }
    //New viewController will pop from right side of screen.
    func popFromRight() -> CATransition {
        self.duration = 0.1 //set the duration to whatever you'd like.
        self.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.type = CATransitionType.reveal
        self.subtype = CATransitionSubtype.fromRight
        return self
    }
    //New viewController will appear from left side of screen.
    func popFromLeft() -> CATransition {
        self.duration = 0.1 //set the duration to whatever you'd like.
        self.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.type = CATransitionType.reveal
        self.subtype = CATransitionSubtype.fromLeft
        return self
    }
}



extension UIImageView {
    func downloaded(fromURL url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) { //method that will download its own image from a url
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                //let mimeType = response?.mimeType, mimeType.hasPrefix("image"), //error here
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
                DispatchQueue.main.async() {
                    self.image = image
                }
            }.resume()
    }
    func downloaded(fromLink link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) { //method that will download its own image from a url
        guard let url = URL(string: link) else { return }
        downloaded(fromURL: url, contentMode: mode)
    }
    func rounded(){
        self.layer.cornerRadius = self.frame.height / 2 //half of the imageView to make it round
        self.layer.masksToBounds = true
    }
}



extension UnderlinedTextField {
    //    @discardableResult
    func hasError() {
        self.setUnderlineColor(color: .systemRed)
    }
//    @discardableResult
    func hasNoError() {
        self.setDefaultUnderlineColor()
    }
}
