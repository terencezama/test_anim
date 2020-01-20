//
//  Meal.swift
//  CalorieCount
//
//  Created by Terence Zama on 28/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import Foundation
import RealmSwift

class Meal:Object, Codable{
    @objc dynamic var id            = ""
    @objc dynamic var text          = ""
    @objc dynamic var date          = Date(timeIntervalSince1970: 1)
    @objc dynamic var time          = ""
    @objc dynamic var calories      = 0
    @objc dynamic var userId        = ""
    
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func toDictionary() -> [String:Any]{
        let dateFormatter   = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return [
            "text":         self.text,
            "date":         dateFormatter.string(from: self.date),
            "time":         self.time,
            "calories":     self.calories,
            "userId":       self.userId
        ]
    }
}
