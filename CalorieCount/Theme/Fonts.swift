//
//  Fonts.swift
//  CalorieCount
//
//  Created by Terence Zama on 19/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit
class Fonts {
    static var bold = "HelveticaNeue-Bold"
    class var button:UIFont?{
        get{
            return UIFont(name: bold, size: 15 * UI.heightRatio)
        }
    }
    
    class var textField:UIFont?{
        get{
            return UIFont(name: bold, size: 17 )
        }
    }
    class var reducedPlaceholder:UIFont?{
        get{
            return UIFont(name: bold, size: 15 )
        }
    }
}
