//
//  NetworkRequest.swift
//  CalorieCount
//
//  Created by Terence Zama on 25/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import Foundation
import Moya
import Result
enum NetworkError:Error{
    case moya(_ error:ErrorResponse)
    case server(_ error:ErrorResponse)
}
extension MoyaError{
    func data() -> [String:Any]{
        do{
            let _data = try self.response!.mapJSON() as? [String:Any]
            return _data!
        }catch{
            return ["error":["message":"Something went wrong. Please try again later."]]
        }
    }
    
    func errorResponse() -> ErrorResponse{
        do {
            if let response = self.response{
                let res = try response.map(ErrorResponse.self)
                return res
            }else{
                //moya error timeout or network..
                return ErrorResponse(code: "unknown", message: self.localizedDescription)
            }
            
        } catch {
            return ErrorResponse(code: "unknown", message: "Something went wrong. Please try again later.")
        }
    }
    func debug(){
        do {
            let _data = try self.response!.mapJSON() as? [String:Any]
            let data1 =  try JSONSerialization.data(withJSONObject: _data!, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) // the data will be converted to the string
            print(convertedString!, terminator:"") // <-- here is ur string
            
        } catch let myJSONError {
            print(myJSONError)
        }
    }
}
class NetworkAdapter<Target: TargetType>{
    let provider = MoyaProvider<Target>(plugins:[NetworkLoggerPlugin(verbose:true)])
    static var shared:NetworkAdapter {
        return NetworkAdapter<Target>()
    }
    private init(){}
    
    func request(_ target:Target, completion:@escaping(Result<Moya.Response,NetworkError>)->Void){
        provider.request(target) { result in
            var finalResult:Result<Moya.Response,NetworkError>!
            switch result{
            case let .success(res):
                do {
                    let _ = try res.filterSuccessfulStatusCodes()
                    finalResult = .success(res)
                }catch{
                    finalResult = .failure(.moya((error as! MoyaError).errorResponse()))
                }
            case let .failure(error):
                finalResult = .failure(.moya(error.errorResponse()))
            }
            completion(finalResult)
        }
    }
}


struct NetworkRequest {
    static func notifyError(_ error:NetworkError,in viewcontroller:UIViewController, completion:@escaping (()->Void)){
        var errorResponse:ErrorResponse!
        switch error{
        case let .moya(er):
            errorResponse = er
        case let  .server(er):
            errorResponse = er
        }
        let alertController = UIAlertController(title: "Error", message: errorResponse.getMessage(), preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title: "Ok", style: .cancel, handler: { action in
            completion()
        }))
        viewcontroller.present(alertController, animated: true, completion: nil)
    }
    
}
