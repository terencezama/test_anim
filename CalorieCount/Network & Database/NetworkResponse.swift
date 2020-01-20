//
//  NetworkResponse.swift
//  CalorieCount
//
//  Created by Terence Zama on 27/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import Foundation
import Result
import Moya

struct NetworkResponse{
    static func handleJSONResponse(result:Result<Moya.Response,NetworkError>, completion:@escaping(Result<[String:Any],NetworkError>)->Void){
        var finalResult:Result<[String:Any],NetworkError>!
        switch result{
        case let .success(res):
            finalResult = try! .success(res.mapJSON() as! [String:Any])
        case let .failure(error):
            finalResult = .failure(error)
        }
        completion(finalResult)
    }
    
    static func handleResponse<T:Codable>(result:Result<Moya.Response,NetworkError>, completion:@escaping(Result<T,NetworkError>)->Void){
        var finalResult:Result<T,NetworkError>!
        switch result{
        case let .success(res):
            finalResult = .success(try! res.map(T.self))
        case let .failure(error):
            finalResult = .failure(error)
        }
        completion(finalResult)
        
    }
}
