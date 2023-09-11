//
//  KeyConstant.swift
//  GetColor
//
//  Created by Hương Lâm Quỳnh on 16/08/2023.
//

import Foundation
import FirebaseDatabase
import UIKit

struct UserConstants {
    static let tokenKey = "ACCESS_TOKEN_KEY"
    static let firebaseTokenKey = "FIREBASE_TOKEN_KEY"
    static let phoneKey = "USER_PHONE_KEY"
    static let passwordKey = "USER_PASSWORD_KEY"
    static let activityLastSync = "ACTIVITY_LAST_SYNC"
}


public let firDatabase = Database.database().reference()
public let kVERIFICATIONCODE = "authVerificationID" //for phone auth

//ids and keys for one signal
public let kONESIGNALAPPID: String = "586d3ef3-6411-41d0-ab81-2a797a16a50b"
public let kONESIGNALID: String = "OneSignalId"
public let kUSERID: String = "userId"
public let kUSERNAME: String = "username"
public let kFIRSTNAME: String = "firstName"
public let kLASTNAME: String = "lastName"
public let kFULLNAME: String = "fullName"
public let kEMAIL: String = "email"
public let kIMAGEURL: String = "imageUrl"
public let kCURRENTUSER: String = "currentUser" //for userDefaults
public let kUSERIMAGE: String = "userImage"
public let kAUTHTYPES: String = "authenticationTypes"
public let kPHONEAUTH: String = "phoneAuth"
public let kEMAILAUTH: String = "emailAuth"
public let kFACEBOOKAUTH: String = "facebookAuth"
public let kGMAILAUTH: String = "gmailAuth"
public let kANONYMOUSAUTH: String = "anonymousAuth"
public let kAPPLEAUTH: String = "appleAuth"
public let kCREATEDAT: String = "createdAt"
public let kUPDATEDAT: String = "updatedAt"
public let kREGISTEREDUSERS: String = "registeredUsers"
public let kPHONENUMBER: String = "phoneNumber"

public let kFINISHREGISTRATIONVC: String = "finishRegistrationVC"
public let kAUTHENTICATIONVC: String = "authenticationVC"

//Storyboard Identifiers
public let kTOAUTHENTICATIONVC: String = "toAuthenticationVC"
public let kTONAMEVC: String = "toNameVC"
public let kTOAUTHMENUVC: String = "toAuthMenuVC"
public let kMENUCONTROLLER: String = "menuController"




//Other properties for user
public let kUSER: String = "user"
public let kMESSAGES: String = "message"
public let kPUSHID: String = "pushId"
public let kPROFILEIMAGE: String = "profileImage"
public let kDEFAULTPROFILEIMAGE: UIImage = UIImage(named: "profile_photo")!
