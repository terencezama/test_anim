//
//  AuthenticationService.swift
//  CalorieCount
//
//  Created by Terence Zama on 25/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import Foundation
import Moya
enum AuthenticationService{
    case register(username:String, password:String, displayName:String)
    case login(email:String, password:String)
    case forgotPassword(email:String)
    case verifyCode(email:String, code:String, type:String)
    case reset(password:String, code:String)
}

extension AuthenticationService: TargetType{
    var baseURL: URL {
        switch self {
        case .login: //default firebase rest login url
            return URL(string: "https://www.googleapis.com")!
        default:
            //custom cloud function url
            return URL(string: "https://us-central1-kcal-298a5.cloudfunctions.net")!
        }
    }
    
    var path: String {
        switch self {
        case .register:
            return "/app/register"
        case .login:
            return "/identitytoolkit/v3/relyingparty/verifyPassword"
        case .forgotPassword:
            return "/app/forgotpassword"
        case .verifyCode:
            return "/app/verify"
        case .reset:
            return "/app/reset"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .register:
            return .post
        case .login:
            return .post
        case .forgotPassword:
            return .get
        case .verifyCode:
            return .get
        case .reset:
            return .put
        }
    }
    
    var sampleData: Data {
        return "".data(using: .utf8)!
    }
    
    var task: Task {
        switch self {
        case .register(let username,let password, let displayName):
            return .requestParameters(parameters: [
                "username":username,
                "password":password,
                "role":"user",
                "displayName":displayName
                ], encoding: JSONEncoding.default)
            
        case .login(let email, let password):
    
            return .requestCompositeParameters(bodyParameters: [
            "email":email,
            "password":password,
            "returnSecureToken":true
                ], bodyEncoding: JSONEncoding.default,
                   urlParameters: [
                    "key":ConfigsSecurity.reveal(NetworkConfigs.accessToken)
                ])
            
        case .forgotPassword(let email):
            return .requestParameters(parameters: [
                "email":email
                ], encoding: URLEncoding.queryString)
            
        case .verifyCode(let email, let code, let type):
            return .requestParameters(parameters: [
                "email":email,
                "code":code,
                "type":type
                ], encoding: URLEncoding.queryString)
            
        case .reset(let password, let code):
            return .requestParameters(parameters: [
                "password":password,
                "code":code
                ], encoding:JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        var _headers = ["Content-type": "application/json"]
        switch self {
        case .login:break
        default:
            _headers["Authorization"]   = "Bearer "+ConfigsSecurity.reveal(NetworkConfigs.accessToken)
            _headers["Access-Type"]     = "apikey"
        }
        return _headers
    }
    
    
}
