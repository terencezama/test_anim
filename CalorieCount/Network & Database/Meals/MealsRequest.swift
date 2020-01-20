//
//  MealsRequest.swift
//  CalorieCount
//
//  Created by Terence Zama on 28/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import Foundation
import Result
import RealmSwift
class MealsRequest {
    static let shared = MealsRequest()
    private init(){}
    
    func get(userId:String?, completion:@escaping(Result<[String:Any],NetworkError>)->Void){
        NetworkAdapter<MealsService>.shared.request(.get(userId)) { result in
            switch result{
            case .success(let value):
                let meals = try! value.mapJSON() as! Array<Any>
                let realm = DBLayer.shared.realm
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                
                try! realm.write {
//                    realm.delete(realm.objects(Meal.self))
                    meals.forEach({ meal in
                        var obj     = meal as! [String:Any]
                        obj["date"] = dateFormatter.date(from: (obj["date"] as! String))
                        realm.create(Meal.self, value: obj, update: true)
                    })
                }
                
            case .failure:break
            }
        }
    }
    
    func create(meal:Meal, completion:@escaping(Result<[String:Any],NetworkError>)->Void){
        let realm = DBLayer.shared.realm
        NetworkAdapter<MealsService>.shared.request(.create(meal)) { result in
            NetworkResponse.handleJSONResponse(result: result, completion: { json in
                switch json{
                case .success(let val):
                    meal.id = val["id"] as! String
                    try! realm.write {
                        realm.add(meal)
                    }
                    completion(json)
                case .failure:
                    completion(json)
                }
            })
        }
    }
    
    func update(meal:Meal, completion:@escaping(Result<[String:Any],NetworkError>)->Void){
        NetworkAdapter<MealsService>.shared.request(.update(meal)) { result in
            NetworkResponse.handleJSONResponse(result: result, completion:completion)
        }
    }
    
    func delete(ids:[String], meals:[Meal], completion:@escaping(Result<[String:Any],NetworkError>)->Void){
        let realm = DBLayer.shared.realm
        try! realm.write {
            realm.delete(meals)
        }
        NetworkAdapter<MealsService>.shared.request(.delete(ids)) { result in
            NetworkResponse.handleJSONResponse(result: result, completion: completion)
        }
    }
    
    
    
    
}
