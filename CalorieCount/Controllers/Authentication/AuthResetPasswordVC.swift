//
//  ResetPasswordViewController.swift
//  CalorieCount
//
//  Created by Terence Zama on 19/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit
import SwiftSpinner
class AuthResetPasswordVC: AuthFormVc {
    @IBOutlet weak var passwordTextField: TextField!
    
    
    //MARK: - Actions
    @IBAction func submitAction(_ sender: Any) {
        let password = passwordTextField.text!
        let code     = AppSettings.Current.forgotCode
        SwiftSpinner.show("Resetting Password ...")
        AuthenticationRequest.shared.reset(password: password, code:code) { result in
            switch result{
            case .success:
                SwiftSpinner.show("Success", animated: false)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                    SwiftSpinner.hide()
                    self.showNextScreen()
                })
                
            case .failure(let error):
                SwiftSpinner.hide({
                    NetworkRequest.notifyError(error, in: self, completion: {
                        
                    })
                })
                
            }
        }
        
    }
    
    func showNextScreen(){
        self.performSegue(withIdentifier: "unwindToLoginVc", sender: nil)
    }

}
