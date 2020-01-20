//
//  MealsService.swift
//  CalorieCount
//
//  Created by Terence Zama on 28/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import Foundation
import Moya
enum MealsService{
//    case register(username:String, password:String, displayName:String)
    case create(_ meal:Meal)
    case update(_ meal:Meal)
    case get(_ userId:String?)
    case delete(_ ids:[String])
}

extension MealsService: TargetType{
    var baseURL: URL {
        return URL(string: "https://us-central1-kcal-298a5.cloudfunctions.net")!
    }
    
    var path: String {
        switch self {
        case .create:
            return "/app/meals"
        case let .update(meal):
            return "/app/meal/\(meal.id)"
        case .get:
            return "/app/meals"
        case .delete:
            return "/app/meals"
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
        case let .create(meal):
            return .requestParameters(parameters:meal.toDictionary(), encoding:JSONEncoding.default)
        case let .update(meal):
            return .requestParameters(parameters:meal.toDictionary(), encoding:JSONEncoding.default)
        case let .get(userId):
            if let userId = userId{
                return .requestParameters(parameters: ["id":userId], encoding: URLEncoding.queryString)
            }else{
                return .requestPlain
            }
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
