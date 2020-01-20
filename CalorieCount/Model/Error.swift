//
//  Error.swift
//  CalorieCount
//
//  Created by Terence Zama on 25/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import Foundation
struct ErrorResponse:Codable{
    struct ErrorBody:Codable{
        var message:String?
        var code:String?
        
        init(from decoder: Decoder) throws{
            let container = try decoder.container(keyedBy: CodingKeys.self)
            message = try? container.decode(String.self, forKey: .message)
            code = try? container.decode(String.self, forKey: .code)
            if code == nil{
                if let codeInt = try?container.decode(Int.self, forKey: .code){
                    code = String(codeInt)
                }
                
            }
            
        }
        init(code:String, message:String) {
            self.code       = code
            self.message    = message
        }
    }
    var error: ErrorBody
    var message:String?
    func getMessage()->String{
        if let _message = error.message {
            return _message
        }else if let _message = message{
            return _message
        }
        return ""
    }
    
    
    //MARK: - Custom Initialization
    init(code:String, message:String) {
        let body    = ErrorBody(code: code, message: message)
        self.error  = body
    }
}


