//
//  User.swift
//  CalorieCount
//
//  Created by Terence Zama on 29/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import Foundation
import RealmSwift
class Claims:Object , Codable{
    @objc dynamic var role = ""
}
class User:Object, Codable{
    @objc dynamic var uid = ""
    @objc dynamic var email = ""
    @objc dynamic var emailVerified = false
    @objc dynamic var displayName = ""
    @objc dynamic var disabled = false
    @objc dynamic var customClaims:Claims? = nil
    @objc dynamic var tokensValidAfterTime = ""
    
    override static func primaryKey() -> String? {
        return "uid"
    }
}
