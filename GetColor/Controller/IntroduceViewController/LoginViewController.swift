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
import FacebookLogin
import FacebookCore



class LoginViewController: UIViewController, UITextFieldDelegate,  CountryPickerDelegate  {
    func countryPicker(didSelect country: CountryPicker.Country) {
        countryCodeTextField.text = country.isoCode.getFlag() + " +" + country.phoneCode
        selectedCode = "+"+country.phoneCode
    }
    
    
    
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var countryCodeTextField: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var facebookLoginButton: FBLoginButton!
    @IBOutlet weak var signinButton: UIButton!
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
        setupGoogleButton()
        setupFacebookButton()
        
    }
    
    override func viewDidLayoutSubviews() {
        countryCodeTextField.styleTextField(color: AppColor.pinkBackground)
        phoneTextField.styleTextField(color: AppColor.pinkBackground)
        signinButton.tintColor = AppColor.pinkBackground
        signinButton.setShadow()
    }
    
    
    func setupGoogleButton() {
        googleLoginButton.isAuthButton()
        googleLoginButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        googleLoginButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        googleLoginButton.layer.shadowOpacity = 1.0
        googleLoginButton.layer.shadowRadius = 0.0
        googleLoginButton.layer.masksToBounds = false //needed or shadow wont show
    }
    
    
    func setupFacebookButton() { //setup facebook button and its font size
        facebookLoginButton.isAuthButton()
//        let fbButton = FBLoginButton(frame: facebookButton.center, permissions: [.publicProfile]) //programmatically create one
        facebookLoginButton.permissions = [ "public_profile", "email", "user_photos"] //get public profile, email, photos, and about me
        let font = UIFont.boldSystemFont(ofSize: 18) //bold system, size 18
        let fbTitle = NSAttributedString.init(string: "Continue with Facebook", attributes: [NSAttributedString.Key.font : font])
        facebookLoginButton.setAttributedTitle(fbTitle, for: .normal)
        facebookLoginButton.delegate = self
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
        let loginManager = LoginManager()
        loginManager.logIn(permissions: [ "public_profile", "email", "user_photos"], from: self) { (result, error) in
            if error != nil {
                print("===> login facebook failed")
                return
            }
            guard let token = AccessToken.current else {
                print("Failed to get access token")
                //                self.showPopup(isSuccess: false)
                return
            }
            Auth.auth().signIn(with: FacebookAuthProvider.credential(withAccessToken: token.tokenString)) { [unowned self] (result, error) in
                
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
    @IBAction func loginByGoogleTapped(_ sender: Any) {
//      
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
                
        let config = GIDConfiguration(clientID: clientID)

        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(
            withPresenting: self) { user, error in
                
            if let error = error {
                // Handle error if sign-in fails
                print("Google Sign-In error: \(error.localizedDescription)")
                return
            }
            
            // User is signed in successfully
                guard let idToken = user?.user.idToken,
                      let accessToken = user?.user.accessToken else {
                // Handle case when authentication data is missing
                print("Google Sign-In failed: No authentication data")
                return
            }
//            let currentUser = user?.user
//
//            let userId = user?.user.userID // For client-side use only!
//            print("USER = \(user)")
//            print("USER PROFILE = \(user.user.profile.debugDescription)")
//            print("USER DESCRIPTION = \(user.user.profile.description.debugDescription)")
//            print("USER ID \(user?.user.userID)\nAUTH AUTH ID \(user.user.idToken)\nACCESSTOKEN \(user.user.accessToken)") //access token is what allows you to get into the database. //idToken is
            let firstName = user!.user.profile?.givenName ?? ""
            let lastName = user!.user.profile?.familyName ?? ""
            let email = user!.user.profile?.email ?? ""
            var userDetails = [kFIRSTNAME: firstName, kLASTNAME: lastName, kEMAIL: email]
//            if ((user!.user.profile?.hasImage) != nil) {
//                let imageUrl = user!.user.profile?.imageURL(withDimension: 100)
//                print("\(firstName)'s Image URL from Google = \(String(describing: imageUrl))")
//                userDetails[kIMAGEURL] = imageUrl?.absoluteString
//            }
//
                let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString) //are we goin to need a session token
            User.authenticateUser(credential: credential, userDetails: userDetails) { (user, error) in //authenticate user with credentials and get user
                if let error = error {
                    Service.presentAlert(on: self, title: "Google Error", message: error)
                    return
                }
                goToNextController(vc: self, user: user!)
            }
            // Create a GoogleAuthProvider credential using the obtained tokens
//            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString,
//                                                           accessToken: accessToken.tokenString)
            
            // Perform sign-in with the credential using your own services or backend
          
        }
    }
    
    @objc func showAlert(button: UIButton) {
        let countryPicker = CountryPickerViewController()
        countryPicker.selectedCountry = currentCountryCode ?? "US"
        countryPicker.delegate = self
        self.present(countryPicker, animated: true)
    }
    
    
}





//MARK: Facebook Auth
extension LoginViewController: LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) { //Delegate method that will run once login has been completed with Facebook button. Result can be, fail, cancel, or success
        if let error = error {
            Service.presentAlert(on: self, title: "Facebook Error", message: error.localizedDescription)
            return
        }
        guard let result = result else { return }
        if result.isCancelled { //if user canceled login
            print("User canceled Facebook Login")
        } else { //if fb login is successful
            if result.grantedPermissions.contains("email") { //make sure they gave us permissions
                let graphRequest = GraphRequest(graphPath: "me", parameters: ["fields":"id, email, first_name, last_name, picture.type(large)"])
                graphRequest.start { (connection, graphResult, error) in //start a connection with Graph API
                    if let error = error {
                        Service.presentAlert(on: self, title: "Facebook Error", message: error.localizedDescription)
                        return
                    } else {
                        guard let userDetails: [String: AnyObject] = graphResult as? [String: AnyObject] else { //contain user's details
                            print("No User Details")
                            return
                        }
                        print("USER DETAILS = \(userDetails)")
                        self.fetchFacebookUserWithUserDetails(userDetails: userDetails)
                    }
                }
            } else { //result.grantedPermissions = false
                Service.presentAlert(on: self, title: "Facebook Error", message: "Facebook failed to grant access")
                return
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) { //Delegate Method - Logout
        print("User logged out!")
    }
    
    fileprivate func fetchFacebookUserWithUserDetails(userDetails: [String: AnyObject]) { //fetch user's details from facebook and create that user class and go to next controller
        let spinner: UIActivityIndicatorView = UIActivityIndicatorView() as UIActivityIndicatorView //spinner
        spinner.style = .large
        spinner.center = view.center
        self.view.addSubview(spinner)
        spinner.startAnimating()
        guard let accessToken = AccessToken.current?.tokenString else { print("Failed to get current Facebook token"); return }
        getFacebookUser(userDetails: userDetails, accessToken: accessToken) { (user, error) in
            if let error = error {
                LoginManager().logOut() //Do not log user in
                Service.presentAlert(on: self, title: "Facebook Error", message: error)
                return
            }
            goToNextController(vc: self, user: user!)
        }
        spinner.stopAnimating()
    }
}

//
//extension LoginViewController: GIDSignInDelegate {
//    func signInWillDispatch(_ signIn: GIDSignIn!, error: Error!) {
//        print("GOOGLE SIGNINWILLDISPATCH?")
//    }
//
//    func signIn(_ signIn: GIDSignIn!,
//                presentViewController viewController: UIViewController!) { //presents the google signin screen
//        self.present(viewController, animated: true, completion: nil)
//    }
//
//    func signIn(_ signIn: GIDSignIn!,
//                dismissViewController viewController: UIViewController!) { //when user dismisses the google signin screen
//        self.dismiss(animated: true, completion: nil)
//    }
//
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
//              withError error: Error!) {
//        if let error = error {
//            Service.presentAlert(on: self, title: "Google Authentication Error", message: error.localizedDescription)
//            return
//        } else {
//            //MARK: USE user.userID as password and objectId
//            let userId = user.userID // For client-side use only!
//            let idToken = user.authentication.idToken // Safe to send to the server
//            let fullName = user.profile.name
//            print("USER = \(user)")
//            print("USER PROFILE = \(user.profile.debugDescription)")
//            print("USER DESCRIPTION = \(user.profile.description.debugDescription)")
//            print("USER ID \(user.userID)\nAUTH AUTH ID \(user.authentication.idToken)\nACCESSTOKEN \(user.authentication.accessToken)") //access token is what allows you to get into the database. //idToken is
//            let firstName = user.profile?.givenName ?? ""
//            let lastName = user.profile?.familyName ?? ""
//            let email = user.profile?.email ?? ""
//            var userDetails = [kFIRSTNAME: firstName, kLASTNAME: lastName, kEMAIL: email]
//            if user.profile?.hasImage {
//                let imageUrl = user.profile.imageURL(withDimension: 100)
//                print("\(firstName)'s Image URL from Google = \(String(describing: imageUrl))")
//                userDetails[kIMAGEURL] = imageUrl?.absoluteString
//            }
//            guard let authentication = user.authentication else { return }
//            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken) //are we goin to need a session token
//            User.authenticateUser(credential: credential, userDetails: userDetails) { (user, error) in //authenticate user with credentials and get user
//                if let error = error {
//                    Service.presentAlert(on: self, title: "Google Error", message: error)
//                    return
//                }
//                goToNextController(vc: self, user: user!)
//            }
//        }
//    }
//}
