//
//  Label.swift
//  CalorieCount
//
//  Created by Terence Zama on 19/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit

@IBDesignable class Label: UILabel {

    fileprivate var cachedFont:UIFont!
    
    @IBInspectable var letterSpacing:CGFloat = 1 {
        didSet {
            updateText()
        }
        
    }
    
    //MARK: Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self._init()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self._init()
    }
    fileprivate func _init(){
        self.cachedFont = self.font
    }
    
    //MARK: - UI Updates
    func updateText(){
        let title = NSMutableAttributedString(string: self.text!)
        let range =  NSRange(location: 0, length: title.length)
        let font = UIFont(name: cachedFont.fontName, size: cachedFont.pointSize * UI.heightRatio)!
        title.addAttributes([
            NSAttributedString.Key.kern:self.letterSpacing,
            NSAttributedString.Key.font:font,
            NSAttributedString.Key.foregroundColor:self.textColor
            ], range: range)
        self.attributedText = title
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        updateText()
    }
    

}
