//
//  AuthType.swift
//  GetColor
//
//  Created by Hương Lâm Quỳnh on 16/08/2023.
//



import Foundation

enum AuthType: String {
    case email, phone, facebook, gmail, apple, unknown
    var asText: String {
        switch self {
        case .email:
            return "email"
        case .phone:
            return "phone"
        case .facebook:
            return "facebook"
        case .gmail:
            return "gmail"
            
        case .apple:
            return "apple"
        case .unknown:
            return "unknown"
            
            
        }
    }
    
    init(type: String) {
        switch type {
        case "email":
            self = AuthType.email
        case "phone":
            self = AuthType.phone
        case "facebook":
            self = AuthType.facebook
        case "gmail":
            self = AuthType.gmail
        case "apple":
            self = AuthType.apple
        case "unknown":
            self = AuthType.unknown
        default:
            print("Unknown auth type")
            self = AuthType.unknown
        }
    }
}

func authTypesToString(types: [AuthType]) -> [String] {
    var resultTypes: [String] = []
    for authType in types {
        resultTypes.append(authType.asText)
    }
    return resultTypes
}

func getAuthTypesFrom(providerId: String) -> [AuthType] { //used at User.authenticateUser to get the AuthType array from providerId
    var authTypes: [AuthType] = []
    switch providerId {
    case "facebook.com":
        authTypes.append(.facebook)
    case "google.com":
        authTypes.append(.gmail)
    case "apple.com":
        authTypes.append(.apple)
    case "phone":
        authTypes.append(.phone)
    case "email":
        authTypes.append(.email)
    default:
        authTypes.append(.unknown)
    }
    print("GET AUTHTYPES FROM ID \(providerId) = \(authTypes)")
    return authTypes
}
