//
//  LoginViewController.swift
//  GetColor
//
//  Created by Hương Lâm Quỳnh on 13/07/2023.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
   
    
    
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var countryTextFields: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    var countryCodes = [[String]]()
    let currentCountryCode: String? = Locale.current.regionCode
    override func viewDidLoad() {
        super.viewDidLoad()
        self.facebookLoginButton.tintColor = AppColor.colorFaceBookButton
        picker()
        self.countryCodes = Utilities.getAllCountryCodes()
        countryTextFields.isUserInteractionEnabled = true
        setElements()
    }
    
    func picker(){
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        countryTextFields.inputView = picker
        let code = GlobalConstants.Constants.codePrefixes[currentCountryCode ?? "US"]

        countryTextFields.text = "+\(code![1])"
        picker.selectRow(0, inComponent: 0, animated: true)
    }
    

    
    
    
    override func viewDidLayoutSubviews() {
//        countryTextFields.borderStyle = colorTheme
//        countryTextFields.styleTextField(color: colorTheme)
//        phoneTextField.styleTextField(color: colorTheme)
    }
    
    func setElements(){
        signinButton.backgroundColor = AppColor.colorButton
        warningLabel.alpha = 0
//        phoneTextField.text = ''
        phoneTextField.tintColor = AppColor.colorTheme
        let rightView = UIImageView(image: UIImage(systemName:"arrowtriangle.down.fill")!)
//        countryTextFields.setRightView(image: UIImage(systemName:"arrowtriangle.down.fill")!,color: UIColor.gray)
        countryTextFields.rightView = rightView
        warningLabel.textColor = UIColor.red
        
      
       
    }
    
    
   
    @IBAction func verifyTapped(_ sender: Any) {
//        if (Connectivity.isConnectedToInternet) {
            let phoneNumber = countryTextFields.text! + phoneTextField.text!
        if !Utilities.isValidPhoneNumber(phoneNumber) {
                warningLabel.text = "Invalid phone number"
                warningLabel.alpha = 1
            }
        else {
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [self] (verificationId, error) in
                if let err = error {
                    print("Unable to send verication Code \(err.localizedDescription)")
                    warningLabel.alpha = 1
                    warningLabel.text = err.localizedDescription
                }
                else {
                    warningLabel.alpha = 0
                    UserDefaults.standard.set(verificationId, forKey: "authVerificationID")
                    let phone  = Utilities.getPhoneNumber(from: phoneNumber)
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "VerifyPhoneNumberViewController") as! VerifyPhoneNumberViewController
                    vc.phoneNumber = countryTextFields.text! + String(phone!.nationalNumber)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }

        }
        
    }
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryCodes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let code = countryCodes[row]
        return "\(code[0]) +\(code[1])"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let code = countryCodes[row]
        countryTextFields.text = "+\(code[1])"
    }
}





