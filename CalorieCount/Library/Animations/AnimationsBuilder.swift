//
//  AnimationsBuilder.swift
//  CalorieCount
//
//  Created by Terence Zama on 21/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit

struct AnimationsBuilder {
    static func build(_ views:Array<UIView>, type:AnimationType, properties:[String:Any]?) -> Array<Animation>{
        return views.map({ (view) -> Animation in
            let animation = Animation(view, type: type)
            properties?.forEach({ (key, value) in
                
                animation.setValue(value, forKeyPath: key)
            })
            return animation
        })
    }
}
