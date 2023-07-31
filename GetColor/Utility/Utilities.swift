//
//  Utilities.swift
//  GetColor
//
//  Created by Hương Lâm Quỳnh on 29/07/2023.
//

import Foundation
import PhoneNumberKit


class Utilities {
    static func getAllCountryCodes() -> [[String]] {
          var countrys = [[String]]()
          let countryList = GlobalConstants.Constants.codePrefixes
          for item in countryList {
              countrys.append(item.value)
          }
          let sorted = countrys.sorted(by: {$0[0] < $1[0]})
          return sorted
      }
    
   static func isValidPhoneNumber(_ number: String) -> Bool {
        let numberKit = PhoneNumberKit()
        return numberKit.isValidPhoneNumber(number)
    }


    static func getPhoneNumber(from phone: String) -> PhoneNumber? {
        let phoneNumberKit = PhoneNumberKit()
        do {
            let phoneKit = try phoneNumberKit.parse(phone)
            return phoneKit
        }catch {
            print("Parse Phone Number failed !!!")
            return nil
        }
    }

   
}
