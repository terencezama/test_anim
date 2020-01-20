//
//  TextField.swift
//  CalorieCount
//
//  Created by Terence Zama on 20/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit

class TextField: SkyFloatingLabelTextField {
    //MARK: - UI Consistency
    override var textColor: UIColor?{
        get{return UIColor.black}
        set{super.textColor = newValue}
    }
    override var selectedTitleColor: UIColor{
        get{return Colors.primaryColor}
        set{super.selectedTitleColor = newValue}
    }
    override var errorColor: UIColor{
        get{return Colors.red}
        set{super.errorColor = newValue}
    }
    override var lineErrorColor: UIColor?{
        get{return Colors.red}
        set{super.lineErrorColor = newValue}
    }
    
    override var selectedLineColor: UIColor{
        get{return Colors.primaryColor}
        set{super.selectedLineColor = newValue}
    }
    
    //MARK: - Validation Handling
    var isValidated = false
    var validatorType:ValidatorType = .required
    @available(*,unavailable,message: "IB ONLY, use validatorType")
    @IBInspectable var ibValidatorType:String?{
        willSet{
            if let newValidatorType = ValidatorType(rawValue: newValue?.lowercased() ?? ""){
                validatorType = newValidatorType
            }
        }
    }
    
    
    //MARK: - Size Fixing
    override var intrinsicContentSize: CGSize{
        get{
            let containerWidth = superview?.bounds.width ?? UIScreen.main.bounds.width
            return CGSize(width: containerWidth-(UI.spacing*2), height: UI.textFieldHeight * UI.heightRatio)
        }
    }
    
    //MARK: - Delegate Trigger While Setting Text
    func setTextAndNotify(text:String){
        self.text = text
        let _ = self.delegate?.textField!(self, shouldChangeCharactersIn: NSRange(location: 0, length: text.count), replacementString: text)
    }

}
