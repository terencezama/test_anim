//
//  FirebaseJwt.swift
//  CalorieCount
//
//  Created by Terence Zama on 27/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import Foundation
struct FirebaseJwt:Codable{
    struct FirebaseObject:Codable{
        struct FirbaseIdentities:Codable{
            var email:Array<String>
        }
        var identities:FirbaseIdentities
        var sign_in_provider:String
    }
    var role:String
    var iss:String
    var aud:String
    var auth_time:Int
    var user_id:String
    var sub:String
    var iat:Int
    var exp:Int
    var email:String
    var email_verified:Bool
    var firebase:FirebaseObject
}
