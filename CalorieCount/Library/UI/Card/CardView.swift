//
//  CardStackView.swift
//  CalorieCount
//
//  Created by Terence Zama on 20/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit

@IBDesignable
class CardView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = UI.cornerRadius
//        self.clipsToBounds = true
        self.backgroundColor = UIColor.white
    }
}
