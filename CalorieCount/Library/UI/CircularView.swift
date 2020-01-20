//
//  CircularView.swift
//  CalorieCount
//
//  Created by Terence Zama on 18/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit


@IBDesignable class CircularView: UIView {
    @IBInspectable var diameter:CGFloat = 0 {
        didSet{
            self.layer.cornerRadius     = diameter/2
            self.clipsToBounds          = true
        }
    }
    
    override var frame: CGRect{
        didSet{
            self.diameter = max(frame.size.width, frame.size.height)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.diameter = max(frame.size.width, frame.size.height)
        self.layer.cornerRadius     = diameter/2
        self.clipsToBounds          = true
    }
    
    
    override var intrinsicContentSize: CGSize{
        return CGSize(width: diameter, height: diameter)
    }
}
