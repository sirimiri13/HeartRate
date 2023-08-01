//
//  VerifyPhoneNumberViewController.swift
//  GetColor
//
//  Created by Hương Lâm Quỳnh on 29/07/2023.
//

import UIKit
import FirebaseAuth

class VerifyPhoneNumberViewController: UIViewController {

    var phoneNumber: String = ""
    
    
    @IBOutlet weak var vertifyTitleLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var verifyCodeTextField: VerifyCodeTextField!
    @IBOutlet weak var errorCodeLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var resendButton: UIButton!
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setElements()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.navigationController!.navigationBar.barTintColor = AppColor.colorTheme
            self.navigationController!.navigationBar.topItem?.title = "Verify Phone Number"
            self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,  NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .bold)]
        }
        
    }
    
    func setElements() {
        vertifyTitleLabel.text = "Enter the 6-digit code we sent to"
        phoneNumberLabel.text = phoneNumber
        phoneNumberLabel.textColor = AppColor.colorTheme
        phoneNumberLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(phoneTapped(_:)))
        phoneNumberLabel.addGestureRecognizer(tap)
        
        
        continueButton.setTitle("CONTINUE", for: .normal)
        continueButton.backgroundColor = UIColor.gray
        continueButton.tintColor = UIColor.lightGray
        continueButton.isUserInteractionEnabled = false
//        continueButton.setShadow()
        
        verifyCodeTextField.configure()
        verifyCodeTextField.didEnterLastDigit = {[weak self] code in
            self!.continueButton.backgroundColor = AppColor.colorTheme
            self!.continueButton.tintColor = UIColor.white
            self!.continueButton.isUserInteractionEnabled = true
        }
        verifyCodeTextField.notendOfDigit = {[weak self] code in
            self!.continueButton.backgroundColor = UIColor.gray
            self!.continueButton.tintColor = UIColor.lightGray
            self!.continueButton.isUserInteractionEnabled = false
        }
        
        errorCodeLabel.alpha = 0
        resendButton.setTitle("Resend code", for: .normal)
        resendButton.tintColor = AppColor.colorTheme
        
       
    }
    
    
    @IBAction func VerifyTapped(_ sender: Any) {
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID!, verificationCode: verifyCodeTextField.text!)
        Auth.auth().signIn(with: credential) {(authResult, error) in
            if error != nil {
                self.errorCodeLabel.alpha = 1
                self.errorCodeLabel.textColor = UIColor.red
                self.errorCodeLabel.text = "Wrong digit. Try Again"
            }
            else {
                let vc = (self.storyboard?.instantiateViewController(identifier: "MainViewController"))! as MainViewController
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func resendCodeTapped(_ sender: Any) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumberLabel.text!, uiDelegate: nil) { (verificationId, err) in
            if err == nil {
            }
            else {
                print("Unable to send verication Code \(err?.localizedDescription ?? "")")
            }
        }
    }
    
    @objc func phoneTapped(_ sender: UITapGestureRecognizer){
        print("phone tap")
        self.dismiss(animated: true, completion: nil)
    }
    

}
