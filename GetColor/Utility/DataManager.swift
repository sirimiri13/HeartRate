//
//  DataManagement.swift
//  GetColor
//
//  Created by Hương Lâm Quỳnh on 10/08/2023.
//

import Foundation

class DataManager {
    static let shared = DataManager()
    
    var token: String = "" {
        didSet {
            UserDefaults.standard.set(token, forKey: UserConstants.tokenKey)
        }
    }
    
    var phone: String {
        didSet {
            UserDefaults.standard.set(phone, forKey: UserConstants.phoneKey)
        }
    }
    var password: String {
        didSet {
            UserDefaults.standard.set(password, forKey: UserConstants.passwordKey)
        }
    }
    
    var activityLastSync: Int64 {
        didSet {
            UserDefaults.standard.set(activityLastSync, forKey: UserConstants.activityLastSync)
        }
    }
    
    
    init() {
        token = UserDefaults.standard.string(forKey: UserConstants.tokenKey) ?? ""
        phone = UserDefaults.standard.string(forKey: UserConstants.phoneKey) ?? ""
        password = UserDefaults.standard.string(forKey: UserConstants.passwordKey) ?? ""
        activityLastSync = Int64(UserDefaults.standard.integer(forKey: UserConstants.activityLastSync))    }
    
    func clearAccessToken() {
        UserDefaults.standard.removeObject(forKey: UserConstants.tokenKey)
    }
    
    func cleanUp() {
//        phone = ""
//        token = ""
//        activityLastSync = 0
//        let defaults = UserDefaults.standard
//        let dictionary = defaults.dictionaryRepresentation()
//        dictionary.keys.forEach { key in
//            defaults.removeObject(forKey: key)
//        }
//
//        let realm = try! Realm()
//        try! realm.write {
//            realm.deleteAll()
//        }
    }
    
    func set(phone: String, password: String) {
        self.phone = phone
        self.password = password
    }
    
    func updateActivityLastSync() {
        activityLastSync = Int64(NSDate().timeIntervalSince1970)
    }
    
    func fetchUserInfo(completion: @escaping (User?) -> Void) {
        //        AccountService().fetchUserInfo { (userInfo) in
        //            if let user = userInfo {
        //                let realm = try! Realm()
        //                try! realm.write {
        //                    realm.delete(realm.objects(User.self))
        //                    realm.add(user)
        //                    self.carerId = user.id
        //                }
        //                completion(userInfo)
        //            }
        //            else {
        //                print("ERROR: Not able to fetch user !!!")
        //                completion(nil)
        //            }
        //        }
    }
    
    
    
    func getUserInfo(completion: @escaping (User?) -> Void) {
//        let realm = try! Realm()
//        let users = realm.objects(User.self)
//        if let user = users.first {
//            return completion(user)
//        }else {
//            self.fetchUserInfo(completion: completion)
//        }
    }
    
    func updateUser(_ userInfo: User, completion: @escaping () -> Void) {
        
    }
    
    func addUser(_ userInfo: User, completion: @escaping (Bool) -> Void){
        
    }
    
    func writeUserInfo(_ userInfo: User) {
//        let realm = try! Realm()
//        do {
//            let users = realm.objects(User.self)
//            if let user = users.first {
//                try! realm.write {
//                    user.title = userInfo.title
//                    user.givenNames = userInfo.givenNames
//                    user.lastName = userInfo.lastName
//                    user.phoneNumber = userInfo.phoneNumber
//                    user.email = userInfo.email
//                    user.gender = userInfo.gender
//                    user.yob = userInfo.yob
//                    user.address?.formatted = userInfo.address?.formatted ?? ""
//                    user.address?.streetNo = userInfo.address?.streetNo ?? ""
//                    user.address?.street = userInfo.address?.street ?? ""
//                    user.address?.suburb = userInfo.address?.suburb ?? ""
//                    user.address?.postcode = userInfo.address?.postcode ?? ""
//                    user.address?.state = userInfo.address?.state ?? ""
//                    user.address?.country = userInfo.address?.country ?? ""
//                }
//            }
//        }
    }
}
    
    
    
