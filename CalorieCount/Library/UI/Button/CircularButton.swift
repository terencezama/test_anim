//
//  CircularButton.swift
//  CalorieCount
//
//  Created by Terence Zama on 27/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit

@IBDesignable
class CircularButton: UIButton {
    private let buttonHeight:CGFloat = 50
    private let imageInset:CGFloat = 12
    @IBInspectable var image:String!{
        didSet{
            let uiimage = UIImage(named: image)?.withRenderingMode(.alwaysTemplate)
            self.setImage(uiimage!, for: .normal)
            self.setImage(uiimage!, for: .selected)
            self.setImage(uiimage!, for: .highlighted)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.imageEdgeInsets = UIEdgeInsets(top: imageInset, left: imageInset, bottom: imageInset, right: imageInset)
    }
    
    override var intrinsicContentSize: CGSize{
        get{
            return CGSize(width: buttonHeight, height: buttonHeight)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius     = buttonHeight/2
        self.layer.shadowColor      = UIColor.black.cgColor
        self.layer.shadowRadius     = 1
    }

}
