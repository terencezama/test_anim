//
//  User.swift
//  CalorieCount
//
//  Created by Terence Zama on 27/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import Foundation
import JWTDecode

struct AppUser:Codable {
    
    static var intemediate_user_id:String?
    
    var kind:String
    var idToken:String
    var displayName:String
    var localId:String
    var refreshToken:String
    var registered:Bool
    var email:String
    var expiresIn:String
    var jwt:FirebaseJwt
    
    
    init(from decoder: Decoder) throws{
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        kind            = try! container.decode(String.self, forKey: .kind)
        idToken         = try! container.decode(String.self, forKey: .idToken)
        displayName     = try! container.decode(String.self, forKey: .displayName)
        localId         = try! container.decode(String.self, forKey: .localId)
        refreshToken    = try! container.decode(String.self, forKey: .refreshToken)
        registered      = try! container.decode(Bool.self, forKey: .registered)
        email           = try! container.decode(String.self, forKey: .email)
        expiresIn       = try! container.decode(String.self, forKey: .expiresIn)

        let decodedJwt = try! decode(jwt: idToken)
        let data = try! JSONSerialization.data(withJSONObject: decodedJwt.body, options: .prettyPrinted)
        jwt = try! JSONDecoder().decode(FirebaseJwt.self, from: data)
    }
    
    //MARK: - Saving user state
    func persist(){
        if let encodedData = try? JSONEncoder().encode(self){
            UserDefaults.standard.set(encodedData, forKey: UserDefaultsKeys.AppUser.rawValue)
        }
    }
    func delete(){
        UserDefaults.standard.set(nil, forKey: UserDefaultsKeys.AppUser.rawValue)
    }
    static func current() -> AppUser?{
        if let decoded = UserDefaults.standard.value(forKey: UserDefaultsKeys.AppUser.rawValue) as? Data{
            if let decodedSelf = try? JSONDecoder().decode(AppUser.self, from: decoded){
                return decodedSelf
            }
        }
        return nil
    }
}
