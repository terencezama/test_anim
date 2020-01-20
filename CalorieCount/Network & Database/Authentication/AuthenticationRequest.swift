//
//  AuthenticationRequest.swift
//  CalorieCount
//
//  Created by Terence Zama on 25/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import Foundation
import Moya
import Result



class AuthenticationRequest {
    static let shared = AuthenticationRequest()
    private init(){}
    
    //MARK: - Request
    func login(email:String, password:String, completion:@escaping(Result<AppUser,NetworkError>)->Void){
        NetworkAdapter<AuthenticationService>.shared.request(.login(email: email, password: password)) { result in
            NetworkResponse.handleResponse(result: result, completion: { (result:Result<AppUser,NetworkError>) in
                switch result{
                case let .success(user):
                    user.persist()
                    print(AppUser.current())
                default:break
                }
                completion(result)
            })
        }
    }
    
    func register(email:String, password:String, displayName:String, completion:@escaping(Result<[String:Any],NetworkError>)->Void){
        NetworkAdapter<AuthenticationService>.shared.request(.register(username: email, password: password, displayName:displayName)) { result in
            NetworkResponse.handleJSONResponse(result: result, completion: completion)
        }
    }
    
    func forgotPassword(email:String, completion:@escaping(Result<[String:Any],NetworkError>)->Void){
        NetworkAdapter<AuthenticationService>.shared.request(.forgotPassword(email: email)) { result in
            NetworkResponse.handleJSONResponse(result: result, completion: completion)
        }
    }
    
    func verifyCode(email:String, code:String, type:String,
                    completion:@escaping(Result<[String:Any],NetworkError>)->Void){
        NetworkAdapter<AuthenticationService>.shared.request(.verifyCode(email: email, code: code, type: type)) { result in
            NetworkResponse.handleJSONResponse(result: result, completion: completion)
        }
    }
    
    func reset(password:String, code:String, completion:@escaping(Result<[String:Any],NetworkError>)->Void){
        NetworkAdapter<AuthenticationService>.shared.request(.reset(password: password, code: code)) { result in
            NetworkResponse.handleJSONResponse(result: result, completion: completion)
        }
    }
    
    
}
