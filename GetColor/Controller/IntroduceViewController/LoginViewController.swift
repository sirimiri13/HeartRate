//
//  LoginViewController.swift
//  GetColor
//
//  Created by Hương Lâm Quỳnh on 13/07/2023.
//

import UIKit
import Firebase
import FirebaseAuth
import CountryPicker
import GoogleSignIn

class LoginViewController: UIViewController, UITextFieldDelegate,  CountryPickerDelegate {
    
    
    func countryPicker(didSelect country: CountryPicker.Country) {
        countryCodeTextField.text = country.isoCode.getFlag() + " +" + country.phoneCode
        selectedCode = "+"+country.phoneCode
    }
    
    
    
    
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var countryCodeTextField: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    let currentCountryCode: String? = Locale.current.regionCode
    var selectedCode : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.facebookLoginButton.tintColor = AppColor.colorFaceBookButton
        setElements()
        let  phoneCode = (GlobalConstants.Constants.codePrefixes[self.currentCountryCode ?? "US"]?[1]) ?? "+1"
        
        countryCodeTextField.text = currentCountryCode!.getFlag() + " +" + phoneCode
        selectedCode = "+"+phoneCode
        
    }
    
    
    func setElements(){
        signinButton.backgroundColor = AppColor.colorButton
        warningLabel.alpha = 0
        phoneTextField.tintColor = AppColor.colorTheme
        warningLabel.textColor = UIColor.red
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showAlert(button:)))
        self.countryCodeTextField.addGestureRecognizer(tap)
    }
    
    
    @IBAction func verifyTapped(_ sender: Any) {
        //        if (Connectivity.isConnectedToInternet) {
        let phoneNumber = selectedCode + phoneTextField.text!
        print("===> phoneNumber: ",phoneNumber)
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
                    UserDefaults.standard.set("login",forKey:"userStatus")
                    UserDefaults.standard.set(verificationId, forKey: "authVerificationID")
                    let phone  = Utilities.getPhoneNumber(from: phoneNumber)
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "VerifyPhoneNumberViewController") as! VerifyPhoneNumberViewController
                    vc.phoneNumber = countryCodeTextField.text! + String(phone!.nationalNumber)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
        }
        
    }
    @IBAction func loginByFacebookTapped(_ sender: Any) {
    }
    @IBAction func loginByGoogleTapped(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                return          }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            print("credential: \(credential)")
            Auth.auth().signIn(with: credential) { [unowned self] (result, error) in
                
               if let error = error {
                 print(error.localizedDescription)
               } else {
                   UserDefaults.standard.set("login",forKey:"userStatus")
                   let vc = (self.storyboard?.instantiateViewController(identifier: "MainViewController"))! as MainViewController
                   self.navigationController?.pushViewController(vc, animated: true)

               }
             }
        }
        }
        
        @objc func showAlert(button: UIButton) {
            let countryPicker = CountryPickerViewController()
            countryPicker.selectedCountry = currentCountryCode ?? "US"
            countryPicker.delegate = self
            self.present(countryPicker, animated: true)
        }
        
        
    }
    
    
    
    
    
