//
//  ReplaceSegue.swift
//  CalorieCount
//
//  Created by Terence Zama on 28/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//
/*
 It should be noted it doesnt replace with a new stack but look for source
 */
import UIKit

class ReplaceSegue: UIStoryboardSegue {
    override func perform() {
        if var viewControllers = source.navigationController?.viewControllers{
            viewControllers.remove(at: viewControllers.count-1)
            let nvc = viewControllers + [destination]
            source.navigationController?.setViewControllers(nvc, animated: false)
        }
        
    }
}
