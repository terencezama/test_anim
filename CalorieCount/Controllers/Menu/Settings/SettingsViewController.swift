//
//  SettingsViewController.swift
//  CalorieCount
//
//  Created by Terence Zama on 27/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var caloriesTextField: TextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.caloriesTextField.text  = String(AppSettings.Current.caloriesPerDay)
        
    }
    
    //MARK: - Acitons
    @IBAction func caloriesTextFieldEditingChanged(_ sender: TextField) {
        if let value = Int(sender.text ?? "0"){
            AppSettings.Current.caloriesPerDay = value
        }
        
    }
    
    @IBAction func viewDidTapped(_ sender: Any) {
        self.view.endEditing(true)
    }
    @IBAction func logoutButtonTapped(_ sender: Any) {
        AppUser.current()?.delete()
        let realm = DBLayer.shared.realm
        try! realm.write {
            realm.deleteAll()
        }
 self.tabBarController?.navigationController?.popToRootViewController(animated: false)
    }
    
    

}
