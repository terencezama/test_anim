//
//  ForgotPasswordViewController.swift
//  CalorieCount
//
//  Created by Terence Zama on 19/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit
import SwiftSpinner
class AuthForgotPasswordVC: AuthFormVc {
    @IBOutlet weak var emailTextField: TextField!
    
    //MARK: - ViewLifeCycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        emailTextField.text = AppSettings.Current.email
        emailTextField.setTextAndNotify(text: AppSettings.Current.email)

    }
    
    //MARK: - Actions
    @IBAction func submitAction(_ sender: Any) {
        let email = emailTextField.text!
        AppSettings.Current.email = email
        SwiftSpinner.show("Please wait ...")
        AuthenticationRequest.shared.forgotPassword(email: email) { result in
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
    func showNextScreen() {
        animationController.animations = AnimationsBuilder.build(self.hideable, type: .fadeOut, properties: ["duration":0.3])
        animationController.executeAll {
            self.performSegue(withIdentifier: "authForgotCodeSegue", sender: nil)
        }
    }
    
}
