//
//  UserCellAdapter.swift
//  CalorieCount
//
//  Created by Terence Zama on 29/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import Foundation
class UserCellAdapter{
    class func configure(cell:UserCell,for user:User){
        
        var initials = "XX"
        let displayName = Array(user.displayName)
        if displayName.count > 0 {
            let index = displayName.firstIndex(of: " ")
            initials = String(displayName[0])
            if index == nil && displayName.count > 1 {
                initials = String(displayName[0]).uppercased() + String(displayName[1]).uppercased()
            }else if index! + 1 < displayName.count{
                initials = String(displayName[0]).uppercased() + String(displayName[index!+1]).uppercased()
            }
        }
        
        let userRole = UserRole(rawValue: user.customClaims?.role ?? "user")!
        cell.initialsLabel.text                 = initials
        cell.displayNameLabel.text              = user.displayName
        cell.emailLabel.text                    = user.email
        cell.userCircularView.backgroundColor   = userRole.getColor()
        cell.badgeLabel.badgeColor              = userRole.getColor()
        cell.badgeLabel.text                    = userRole.rawValue
        
    }
}
