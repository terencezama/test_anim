//
//  AppSettings.swift
//  CalorieCount
//
//  Created by Terence Zama on 25/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import Foundation
struct AppSettings{
    struct Current {
        static var email:String{
            get{
                return UserDefaults.standard.string(forKey:UserDefaultsKeys.AppSettingsEmail.rawValue) ?? ""
            }
            set{
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.AppSettingsEmail.rawValue)
            }
        }
        
        static var forgotCode:String{
            get{
                return UserDefaults.standard.string(forKey: UserDefaultsKeys.AppSettingsForgotCode.rawValue) ?? ""
            }
            set{
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.AppSettingsForgotCode.rawValue)
            }
        }
        
        static var caloriesPerDay:Int{
            get{
                return UserDefaults.standard.integer(forKey: UserDefaultsKeys.AppSettingsCalories.rawValue) 
            }
            set{
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.AppSettingsCalories.rawValue)
            }
        }
    }
}
