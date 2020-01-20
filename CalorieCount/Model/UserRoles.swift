//
//  UserRoles.swift
//  CalorieCount
//
//  Created by Terence Zama on 27/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit

enum UserRole:String{
    case admin
    case manager
    case user
    
    func getColor()->UIColor{
        switch self {
        case .admin:
            return #colorLiteral(red: 0.9475007653, green: 0.2240420878, blue: 0.1897725463, alpha: 1)
        case .manager:
            return #colorLiteral(red: 0.9596324563, green: 0.5826337337, blue: 0.007959574461, alpha: 1)
        case .user:
            return #colorLiteral(red: 0.300606966, green: 0.8519598246, blue: 0.3905641139, alpha: 1)
        }
    }
}
