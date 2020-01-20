//
//  UsersAddViewController.swift
//  CalorieCount
//
//  Created by Terence Zama on 29/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit
import SwiftSpinner

class UsersEditViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {
    var updateUser:User?
    var roles = ["user","manager","admin"]
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var displayNameTextField: TextField!
    @IBOutlet weak var emailTextField: TextField!
    @IBOutlet weak var passwordTextField: TextField!
    @IBOutlet weak var submitButton: Button!
    @IBOutlet var cardConstraints: Constraints!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var roleTextField: TextField!
    
    var animationController = AnimationController([])
    var selectedDate:Date?
    var selectedTime:Date?
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.layoutIfNeeded()
        cardConstraints.top?.constant = (self.view.bounds.height - self.cardView.bounds.height)/2
        cardConstraints.original.top  = (self.view.bounds.height - self.cardView.bounds.height)/2
        setupUI()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animationEntrance()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setKeyboardListeners()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    //MARK: - UI Setup
    func setupUI(){
        self.roleTextField.text = "user"
        if let update = self.updateUser{
            self.titleLabel.text                = "Update User"
            self.submitButton.setTitle("Update", for: .normal)
            self.submitButton.updateText()
            
            displayNameTextField.text           = update.displayName
            emailTextField.text                 = update.email
            self.roleTextField.text             = update.customClaims?.role
            emailTextField.isEnabled            = false
        }else{
            emailTextField.isEnabled            = true
        }
        
        
        let rolePicker          = UIPickerView()
        rolePicker.delegate     = self
        rolePicker.dataSource   = self
        roleTextField.inputView = rolePicker
    }

    //MARK: - Animations
    func animationEntrance(){
        animationController.animations = [
            Animation(cardView, type: .zoomIn).setDuration(0.7)
        ]
        
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundView.alpha = 1
        }) { (completed) in
            self.cardView.isHidden = false
            self.animationController.execute(nil)
        }
    }
    

    
    //MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: Any) {
        if self.closeButton.titleLabel?.text == "Close"{
            self.dismiss(animated: true, completion: nil)
        }else{
            self.view.endEditing(true)
        }
    }
    @IBAction func submitButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        if self.isValid(){
            if let _ = updateUser{
                self.updateUserRequest()
            }else{
                self.createUserRequest()
            }
        }
    }
    //MARK: - Requests
    func createUserRequest(){
        SwiftSpinner.show("Adding User...")
        UsersRequest.shared.create(data: [
            "username":emailTextField.text!,
            "displayName":displayNameTextField.text!,
            "password":passwordTextField.text!,
            "role":roleTextField.text!
        ]) { result in
            switch result{
            case .success:
                SwiftSpinner.show("Success", animated: false)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                    SwiftSpinner.hide()
                    self.dismiss(animated: false, completion: nil)
                })
            case .failure(let error):
                SwiftSpinner.hide({
                    NetworkRequest.notifyError(error, in: self, completion: {
                        
                    })
                })
            }

        }
    }
    func updateUserRequest(){
        SwiftSpinner.show("Updating User...")
        let user        = updateUser!
        let realm       = DBLayer.shared.realm
        try? realm.write {
            user.displayName    = displayNameTextField.text!
            user.email          = emailTextField.text!
            user.customClaims?.role = roleTextField.text!
        }
        var data = [
            "displayName":displayNameTextField.text!,
            "email":emailTextField.text!,
            "role":roleTextField.text!,
        ]
        if let password = passwordTextField.text, password.count > 6{
            data["password"] = password
        }
        UsersRequest.shared.update(userId: user.uid, data: data) { result in
            switch result{
            case .success:
                SwiftSpinner.show("Success", animated: false)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                    SwiftSpinner.hide()
                    self.dismiss(animated: false, completion: nil)
                })
            case .failure(let error):
                SwiftSpinner.hide({
                    NetworkRequest.notifyError(error, in: self, completion: {
                        
                    })
                })
                
            }
        }
        
    }
    
    //MARK: - KeyboardListener
    func setKeyboardListeners(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyBoardWillShow(notification: Notification) {
        self.closeButton.isSelected = true
        self.cardConstraints.top?.constant      = 0
        self.cardConstraints.right?.constant    = 0
        self.cardConstraints.left?.constant     = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.backgroundView.backgroundColor = UIColor.white
        }
        
    }
    
    @objc func keyBoardWillHide(notification: Notification) {
        self.closeButton.isSelected = false
        self.cardConstraints.top?.constant      = self.cardConstraints.original.top
        self.cardConstraints.right?.constant    = self.cardConstraints.original.right
        self.cardConstraints.left?.constant     = self.cardConstraints.original.left
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.backgroundView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.702349101)
        }
        
    }
    
    //MARK: - Validation
    func isValid()->Bool{
        var error = ""
        if displayNameTextField.text?.count == 0 {
            error = "Please enter the description of your meal."
        }else if emailTextField.text?.count == 0{
            error = "Please enter a Date for your meal."
        }else if passwordTextField.text?.count == 0 && self.updateUser == nil{
            error = "Please enter the Time of your meal."
        }else if roleTextField.text?.count == 0{
            error = "Please enter the Number of Calories of your meal."
        }
        
        if error.count > 0 {
            let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        return error.count == 0
    }

    //MARK: - PICKERVIEW DATASOURCE ROLE
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return roles.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return roles[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        roleTextField.text = roles[row]
    }

}
