//
//  MenuTabBarViewController.swift
//  CalorieCount
//
//  Created by Terence Zama on 27/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit

class MenuTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        var viewControllers = self.viewControllers!
        
        if let user = AppUser.current() {
            let role = UserRole.init(rawValue: user.jwt.role)!
            switch role {
            case .admin:break
            case .user:
                viewControllers.remove(at: 1)
            case .manager:
                viewControllers.remove(at: 0)
            }
        }
        self.viewControllers = viewControllers
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
