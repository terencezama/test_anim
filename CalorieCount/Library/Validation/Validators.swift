//
//  Validators.swift
//  CalorieCount
//
//  Created by Terence Zama on 22/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import Foundation
class ValidationError: Error {
    var message: String
    init(_ message: String) {
        self.message = message
    }
}
enum ValidatorType: String {
    case email = "email"
    case password = "password"
    case confirmPassword = "confirmpassword"
    case length6 = "length6"
    case required = "required"
}
protocol Validator {
    var value:String{get set}
    func validate() throws -> Void
}
struct ValidationFactory{
    static func validator(value:String, current:TextField, textFields:Array<TextField>) -> Validator {
        switch current.validatorType {
        case .email: return EmailValidator(value: value)
        case .password: return PasswordValidator(value: value)
        case .confirmPassword:
            let result = textFields.filter { (textField) -> Bool in
                return textField.validatorType == .password
            }
            let passwordTextField = result[0]
            return ConfirmPasswordValidator(value: value, password: passwordTextField.text!)
        case .length6:
            return LengthValidator(value: value, length: 6, field: current.titleLabel.text!)
        case .required: return RequiredFieldValidator(value: value, field: current.titleLabel.text!)
        }
    }
}
struct EmailValidator:Validator {
    var value: String
    func validate() throws {
        guard value != "" else {throw ValidationError("Email is Required")}
        do {
            if try NSRegularExpression(pattern: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$", options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
                throw ValidationError("Invalid e-mail Address")
            }
        } catch {
            throw ValidationError("Invalid e-mail Address")
        }
    }
}
struct PasswordValidator:Validator{
    var value: String
    func validate() throws {
        guard value != "" else {throw ValidationError("Password is Required")}
        if value.count < 6 { throw ValidationError("Password must have at least 6 characters") }
    }
}
struct ConfirmPasswordValidator:Validator{
    var value: String
    var password:String!
    
    func validate() throws {
        guard value != "" else {throw ValidationError("Confirm password is Required")}
        
        if value != self.password{
            throw ValidationError("Confirm password should match password")
        }
    }
}

struct LengthValidator:Validator{
    var value:String
    var length:Int
    var field:String
    
    func validate() throws {
        guard value != "" else {throw ValidationError("\(self.field) is Required")}
        if value.count < length {
            throw ValidationError("\(self.field) must have atleast \(length) characters")
        }
    }
}

struct RequiredFieldValidator: Validator {
    var value:String
    var field:String
    
    func validate() throws {
        guard !value.isEmpty else {
            throw ValidationError("Required field " + field)
        }
    }
}
