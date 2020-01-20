//
//  Button.swift
//  CalorieCount
//
//  Created by Terence Zama on 19/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit

@IBDesignable
class Button: UIButton {
    
    @IBInspectable var color:UIColor = Colors.primaryColor
    @IBInspectable var characterSpacing:CGFloat = 2 {
        didSet {
            updateText()
        }
    }
    @IBInspectable var outlined:Bool = false
    override var isEnabled: Bool{
        didSet{
            self.alpha = isEnabled ? 1.0 : 0.3
        }
    }
    
    //MARK: - INIT
    func _init(){
        self.layer.borderWidth  = UI.borderWidth
        self.layer.cornerRadius = UI.cornerRadius
        self.titleLabel?.font   = Fonts.button
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self._init()
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        self._init()
    }
    
    
    //MARK: - UI Update
    override func layoutSubviews() {
        super.layoutSubviews()
        if outlined {
            self.backgroundColor    = Colors.background
            self.layer.borderColor  = color.cgColor
            self.titleLabel?.textColor = color
        }else{
            self.backgroundColor    = color
            self.layer.borderColor  = color.cgColor
            self.titleLabel?.textColor = Colors.background
        }
    }
    func updateText(){
        let title = NSMutableAttributedString(string: self.title(for: .normal)!)
        let range = NSRange(location: 0, length: title.length)
        title.addAttributes([
            NSAttributedString.Key.kern : characterSpacing,
            NSAttributedString.Key.font : Fonts.button!,
            ], range: range)
        self.setAttributedTitle(title, for: .normal)
    }
    override var intrinsicContentSize: CGSize{
        get{
            return CGSize(width: UIScreen.main.bounds.width-(UI.spacing*2), height: UI.buttonHeight * UI.heightRatio)
        }
    }
    
    

}
