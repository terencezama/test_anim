//
//  UsersRequest.swift
//  CalorieCount
//
//  Created by Terence Zama on 29/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import Foundation
import Result
class UsersRequest {
    static let shared = UsersRequest()
    private init(){}
    func create(data:[String:String], completion:@escaping(Result<[String:Any],NetworkError>)->Void){
        let realm = DBLayer.shared.realm
        NetworkAdapter<UsersService>.shared.request(.create(data:data)) { result in
            NetworkResponse.handleJSONResponse(result: result, completion: { json in
                switch json{
                case .success(let val):
                    try! realm.write {
                        var obj = val
                        obj["customClaims"] = ["role":val["role"]]
                        realm.create(User.self, value: obj, update: false)
                    }
                    completion(json)
                case .failure:
                    completion(json)
                }
            })
        }
    }
    func update(userId:String, data:[String:String], completion:@escaping(Result<[String:Any],NetworkError>)->Void){
        NetworkAdapter<UsersService>.shared.request(.update(userId: userId, data: data)) { result in
            NetworkResponse.handleJSONResponse(result: result, completion: completion)
        }
    }
    func get( completion:@escaping(Result<[String:Any],NetworkError>)->Void){
        NetworkAdapter<UsersService>.shared.request(.get) { result in
            switch result{
            case .success(let value):
                let users = try! value.mapJSON() as! Array<Any>
                let realm = DBLayer.shared.realm
                try! realm.write {
                    users.forEach({ user in
                        let obj     = user as! [String:Any]
                        realm.create(User.self, value: obj, update: true)
                    })
                }
            case .failure:break
            }
        }
    }
    
    func delete(ids:[String], users:[User], completion:@escaping(Result<[String:Any],NetworkError>)->Void){
        let realm = DBLayer.shared.realm
        try! realm.write {
            realm.delete(users)
        }
        NetworkAdapter<UsersService>.shared.request(.delete(ids)) { result in
            NetworkResponse.handleJSONResponse(result: result, completion: completion)
        }
    }
}
