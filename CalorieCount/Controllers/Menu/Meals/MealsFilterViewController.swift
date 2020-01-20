//
//  MealsFilterViewController.swift
//  CalorieCount
//
//  Created by Terence Zama on 29/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit

class MealsFilterViewController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var fromDateTextField: TextField!
    @IBOutlet weak var toDateTextField: TextField!
    @IBOutlet weak var fromTimeTextField: TextField!
    @IBOutlet weak var toTimeTextField: TextField!
    @IBOutlet var cardConstraints: Constraints!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var cardView: CardView!
    
    var map:[UIDatePicker:TextField] = [:]
    var pickers:[UIDatePicker]!
    
    
    var animationController = AnimationController([])
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        cardConstraints.top?.constant = (self.view.bounds.height - self.cardView.bounds.height)/2
        cardConstraints.original.top  = (self.view.bounds.height - self.cardView.bounds.height)/2
        self.setupTextFields()
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
    //MARK: - Setup
    
    func getTimePicker() -> UIDatePicker{
        let timePicker              = UIDatePicker()
        timePicker.datePickerMode   = .time
        timePicker.addTarget(self, action: #selector(handleDatePicker(_:)), for: .valueChanged)
        return timePicker
    }
    func getDatePicker() -> UIDatePicker{
        let datePicker              = UIDatePicker()
        datePicker.datePickerMode   = .date
        datePicker.addTarget(self, action: #selector(handleDatePicker(_:)), for: .valueChanged)
        return datePicker
    }
    func setupTextFields(){
       
        if MealsController.shared.pickers == nil{
            pickers = [
                getDatePicker(),
                getDatePicker(),
                getTimePicker(),
                getTimePicker()
            ]
            MealsController.shared.pickers = pickers
        }else{
            pickers = MealsController.shared.pickers!
        }
        
        fromDateTextField.inputView = pickers[0]
        toDateTextField.inputView   = pickers[1]
        fromTimeTextField.inputView = pickers[2]
        toTimeTextField.inputView   = pickers[3]
        
        map = [
            pickers[0]  : fromDateTextField,
            pickers[1]  : toDateTextField,
            pickers[2]  : fromTimeTextField,
            pickers[3]  : toTimeTextField
        ]
        
        map.forEach { (key: UIDatePicker, value: TextField) in
            switch key.datePickerMode {
            case .date:
                value.text          = MealsController.shared.dateFormatter.string(from: key.date)
            case .time:
                value.text          = MealsController.shared.timeFormatter.string(from: key.date)
            default:break
            }
        }
    }
    //MARK: - DateTimePicker Events
    @objc func handleDatePicker(_ sender:UIDatePicker){
        if let textField = map[sender]{
            switch sender.datePickerMode {
            case .date:
                textField.text          = MealsController.shared.dateFormatter.string(from: sender.date)
            case .time:
                textField.text          = MealsController.shared.timeFormatter.string(from: sender.date)
            default:break
            }
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
    @IBAction func filterButtonTapped(_ sender: Any) {
        if isValid(){
            MealsController.shared.applyFilters(pickers: pickers)
            self.view.endEditing(true)
            self.dismiss(animated: true, completion: nil)
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
        if fromDateTextField.text?.count == 0 {
            error = "Please enter From Date"
        }else if toDateTextField.text?.count == 0{
            error = "Please enter To Date"
        }else if fromTimeTextField.text?.count == 0{
            error = "Please enter From Time"
        }else if toTimeTextField.text?.count == 0{
            error = "Please enter To Time"
        }
        
        if(pickers[0].date >= pickers[1].date){
            error = "From date should be less than To date"
        }
        
        if(pickers[2].date >= pickers[3].date){
            error = "From time should be less than To time"
        }
        
        if error.count > 0 {
            let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        return error.count == 0
    }
    
    


}
