//
//  UsersService.swift
//  CalorieCount
//
//  Created by Terence Zama on 29/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import Foundation
import Moya
enum UsersService{
    //    case register(username:String, password:String, displayName:String)
    case create(data:[String:String])
    case update(userId:String, data:[String:String])
    case get
    case delete(_ ids:[String])
}

extension UsersService: TargetType{
    var baseURL: URL {
        return URL(string: "https://us-central1-kcal-298a5.cloudfunctions.net")!
    }
    
    var path: String {
        switch self {
        case .create:
            return "/app/users"
        case let .update(userId,_):
            return "/app/user/\(userId)"
        case .get:
            return "/app/users"
        case .delete:
            return "/app/users"
        }
        
    }
    
    var method: Moya.Method {
        switch self {
        case .create:
            return .post
        case .update:
            return .put
        case .get:
            return .get
        case .delete:
            return .delete
        }
    }
    
    var sampleData: Data {
        return "".data(using: .utf8)!
    }
    
    var task: Task {
        switch self {
        case let .create(data):
            return .requestParameters(parameters:data, encoding:JSONEncoding.default)
        case let .update(_,data):
            return .requestParameters(parameters:data, encoding:JSONEncoding.default)
        case .get:
            return .requestPlain
        case let .delete(ids):
            return .requestParameters(parameters: ["ids":ids], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        var _headers = ["Content-type": "application/json"]
        _headers["Authorization"]   = "Bearer "+ConfigsSecurity.reveal(NetworkConfigs.accessToken)
        _headers["Access-Type"]     = "apikey"
        return _headers
    }
    
    
}
