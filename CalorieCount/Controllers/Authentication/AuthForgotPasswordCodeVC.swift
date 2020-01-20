//
//  ForgotPasswordCodeViewController.swift
//  CalorieCount
//
//  Created by Terence Zama on 19/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit
import SwiftSpinner
class AuthForgotPasswordCodeVC: AuthFormVc {
    
    @IBOutlet weak var codeTextField: TextField!
    
    //MARK: - Actions
    @IBAction func submitAction(_ sender: Any) {
        let code = codeTextField.text!
        AppSettings.Current.forgotCode = code
        SwiftSpinner.show("Please wait ...")
        AuthenticationRequest.shared.verifyCode(email: AppSettings.Current.email, code: code, type: "forgot_password") { result in
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
        animationController.animations = AnimationsBuilder.build(self.hideable, type: .fadeOut, properties: ["duration":0.3])
        animationController.executeAll {
            self.performSegue(withIdentifier: "authResetPasswordSegue", sender: nil)
        }
    }

}
