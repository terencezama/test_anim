//
//  MealsEditViewController.swift
//  CalorieCount
//
//  Created by Terence Zama on 28/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit
import SwiftSpinner
class MealsEditViewController: UIViewController {
    var updateMeal:Meal?

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var dateTextField: TextField!
    @IBOutlet weak var timeTextField: TextField!
    @IBOutlet weak var calorieTextField: TextField!
    @IBOutlet weak var submitButton: Button!
    @IBOutlet var cardConstraints: Constraints!
    @IBOutlet weak var closeButton: UIButton!
    
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
        setupTextFieldPickers()
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
        if let update = self.updateMeal{
            self.titleLabel.text                = "Update Meal"
            self.submitButton.setTitle("Update", for: .normal)
            self.submitButton.updateText()
            
            descTextView.text                   = update.text
            selectedDate                        = update.date
            timeTextField.text                  = update.time
            calorieTextField.text               = String(update.calories)
            
            let dateFormatter           = DateFormatter()
            dateFormatter.dateFormat    = "dd/MMM/yyyy"
            dateTextField.text          = dateFormatter.string(from: selectedDate!)
        }
    }
    func setupTextFieldPickers(){
        
        let timePicker              = UIDatePicker()
        timePicker.datePickerMode   = .time
        timeTextField.inputView     = timePicker
        timePicker.addTarget(self, action: #selector(handleDatePicker(_:)), for: .valueChanged)
        
        let datePicker              = UIDatePicker()
        datePicker.datePickerMode   = .date
        dateTextField.inputView     = datePicker
        datePicker.addTarget(self, action: #selector(handleDatePicker(_:)), for: .valueChanged)
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
    
    //MARK: - DateTimePicker Events
    @objc func handleDatePicker(_ sender:UIDatePicker){
        switch sender.datePickerMode {
        case .date:
            selectedDate                = sender.date
            let dateFormatter           = DateFormatter()
            dateFormatter.dateFormat    = "dd/MMM/yyyy"
            dateTextField.text          = dateFormatter.string(from: selectedDate!)
        case .time:
            selectedTime = sender.date
            let timeFormatter           = DateFormatter()
            timeFormatter.dateFormat    = "HH:mm"
            timeTextField.text          = timeFormatter.string(from: selectedTime!)
        default:break
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
            if let _ = updateMeal{
                self.updateMealRequest()
            }else{
                self.createMealRequest()
            }
        }
    }
    //MARK: - Requests
    func createMealRequest(){
        SwiftSpinner.show("Adding Meal...")
        let userId = AppUser.intemediate_user_id ?? AppUser.current()!.jwt.user_id
        let meal        = Meal()
        meal.text       = descTextView.text
        meal.date       = MealsController.shared.mergeDateAndTime(date: selectedDate!, time: selectedTime!)
        meal.time       = timeTextField.text!
        meal.calories   = Int(calorieTextField.text!)!
        meal.userId     = userId
        
        MealsRequest.shared.create(meal: meal, completion: { result in
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
        })
    }
    func updateMealRequest(){
        SwiftSpinner.show("Updating Meal...")
        let userId = AppUser.intemediate_user_id ?? AppUser.current()!.jwt.user_id
        let meal        = updateMeal!
        let realm       = DBLayer.shared.realm
        try? realm.write {
            meal.text       = descTextView.text
            meal.date       = MealsController.shared.mergeDateAndTime(date: selectedDate!, time: MealsController.shared.timeFormatter.date(from: timeTextField.text!)!)
            meal.time       = timeTextField.text!
            meal.calories   = Int(calorieTextField.text!)!
            meal.userId     = userId
        }
        
        MealsRequest.shared.update(meal: meal, completion: { result in
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
        })
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
        if descTextView.text.count == 0 {
            error = "Please enter the description of your meal."
        }else if dateTextField.text?.count == 0{
            error = "Please enter a Date for your meal."
        }else if timeTextField.text?.count == 0{
            error = "Please enter the Time of your meal."
        }else if calorieTextField.text?.count == 0{
            error = "Please enter the Number of Calories of your meal."
        }
        
        if error.count > 0 {
            let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        return error.count == 0
    }

}
