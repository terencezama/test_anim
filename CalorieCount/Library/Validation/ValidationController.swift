//
//  ValidationController.swift
//  CalorieCount
//
//  Created by Terence Zama on 22/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit

class ValidationController: NSObject, UITextFieldDelegate {
    @IBOutlet var textFields:Array<TextField>!{
        didSet{
            textFields.forEach { (textField) in
                textField.delegate = self
            }
        }
    }
    @IBOutlet var submitButton:Button?{
        didSet{
            submitButton?.isEnabled = false
        }
    }
    
    //Delegate Handling
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            if let textField = textField as? TextField{
                validateTextField(text: updatedText, textField: textField)
            }
            DispatchQueue.global(qos: .background).async {
                self.isFormValidated()
            }
        }

        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.textFields.forEach({ (textField) in
            if textField.text!.count > 0 {
                self.validateTextField(text: textField.text!, textField: textField)
            }
        })
        self.isFormValidated()
        //as
    }

    
    //MARK: - Validation check
    func validateTextField(text:String, textField:TextField){
        do {
            try ValidationFactory.validator(value: text, current: textField, textFields: textFields).validate()
            textField.errorMessage  = nil
            textField.lineColor     = Colors.green
            textField.titleColor    = Colors.green
            textField.isValidated   = true
        } catch {
            textField.isValidated   = false
            textField.errorMessage = (error as! ValidationError).message
        }
    }
    func isFormValidated(){
        var isValidated = true
        for index in 0..<textFields.count{
            let textField = textFields[index]
            if !textField.isValidated{
                isValidated = false
                break
            }
        }
        DispatchQueue.main.async {
            self.submitButton?.isEnabled = isValidated
        }
    }
}
