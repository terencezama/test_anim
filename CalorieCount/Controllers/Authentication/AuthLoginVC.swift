//
//  LoginViewController.swift
//  CalorieCount
//
//  Created by Terence Zama on 19/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit
import SwiftSpinner
class AuthLoginVC: AuthFormVc {
    
    @IBOutlet weak var emailTextField: TextField!
    @IBOutlet weak var passwordTextField: TextField!
    @IBAction func unwindToLoginVc(segue:UIStoryboardSegue){
        
    }
    //MARK: - View Life Cycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.text = AppSettings.Current.email
    }
    
    
    //MARK: - Actions
    @IBAction func submitButtonTapped(_ sender: Any) {
        let email       = emailTextField.text!
        let password    = passwordTextField.text!
        
        SwiftSpinner.show("Login ...")
        AppSettings.Current.email = email //setting email in Userdefaults for future use
        AuthenticationRequest.shared.login(email: email, password: password) { result in
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
    @IBAction func forgotButtonTapped(_ sender: Any) {
        animationController.animations = AnimationsBuilder.build(self.hideable, type: .fadeOut, properties: ["duration":0.3])
        animationController.executeAll {
            self.performSegue(withIdentifier: "authLoginForgotSegue", sender: nil)
        }
    }
    
    func showNextScreen(){
        let menuStoryboard  = UIStoryboard(name: "Menu", bundle: nil)
        let vc              = menuStoryboard.instantiateInitialViewController()!
        self.show(vc, sender: nil)
    }
}
