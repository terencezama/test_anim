//
//  RegistrationViewController.swift
//  CalorieCount
//
//  Created by Terence Zama on 19/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit
import SwiftSpinner

class AuthRegistrationVC: AuthFormVc {
    @IBOutlet weak var emailTextField: TextField!
    @IBOutlet weak var passwordTextField: TextField!
    @IBOutlet weak var displayNameTextField: TextField!
    
    //MARK: - View Life Cycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.text = AppSettings.Current.email
    }
    
    
    //MARK: - Actions
    @IBAction func registerButtonTapped(_ sender: Any) {
        let email       = emailTextField.text!
        let password    = passwordTextField.text!
        let displayName = displayNameTextField.text!
        
        SwiftSpinner.show("Registering ...")
        AuthenticationRequest.shared.register(email: email, password: password, displayName: displayName) { result in
            switch result{
            case .success:
                SwiftSpinner.show("Success", animated: false)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                    AppSettings.Current.email = email
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
    
    
    @IBAction func forgotButtonTapped(_ sender: Any) {
        animationController.animations = AnimationsBuilder.build(self.hideable, type: .fadeOut, properties: ["duration":0.3])
        animationController.executeAll {
            self.performSegue(withIdentifier: "authRegisterForgotSegue", sender: nil)
        }
    }
    
    func showNextScreen(){
        self.performSegue(withIdentifier: "loginSegue", sender: nil)
    }
    
}
