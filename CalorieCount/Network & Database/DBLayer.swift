//
//  DaoLayer.swift
//  CalorieCount
//
//  Created by Terence Zama on 28/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import Foundation
import RealmSwift
class DBLayer {
    static let shared = DBLayer()
    
    let realm:Realm
    private init(){
        self.realm = try! Realm()
    }
    
    
}
