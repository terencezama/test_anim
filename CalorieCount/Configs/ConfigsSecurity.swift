//
//  ConfigsSecurity.swift
//  CalorieCount
//
//  Created by Terence Zama on 25/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import Foundation
struct ConfigsSecurity {
    static let shared = ConfigsSecurity()
    let obfuscator = Obfuscator(withSalt:[AppDelegate.self,ConfigsSecurity.self,NetworkConfigs.self])
    private init(){}
    
    func printObfuscatedValues(values:[String:String]){
        values.forEach { (dic) in
            print(dic.key,dic.value,self.obfuscator.bytesByObfuscatingString(string: dic.value))
        }
    }
    
    static func reveal(_ key:[UInt8]) -> String{
        return ConfigsSecurity.shared.obfuscator.reveal(key: key)
    }
}
