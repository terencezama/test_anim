//
//  Notifications.swift
//  CalorieCount
//
//  Created by Terence Zama on 21/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit
extension Notification {
    var keyboardSize: CGSize? {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
    }
    var keyboardAnimationDuration: Double? {
        return userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
    }
    
}
