//
//  UIViewController.swift
//  CalorieCount
//
//  Created by Terence Zama on 20/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit

extension UIViewController{
    func dismissKeyboardOnViewTapped(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc fileprivate func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    func hideAllViews(){
        self.view.subviews.forEach { (view) in
            view.isHidden = true
        }
    }
}
