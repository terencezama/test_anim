//
//  Animations.swift
//  CalorieCount
//
//  Created by Terence Zama on 18/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit

enum AnimationType {
    case fillSize
    case cornerRadius
    case composite
    case zoomOut
    case zoomIn
    case highlight
    case fadeIn
    case fadeOut
    case fromLeft
    case toLeft
    case fromRight
    case toRight
}

class Animation: NSObject {
    static let force:CGFloat = 1.5
    
    let type:AnimationType!
    let view:UIView!
    @objc dynamic var duration:CFTimeInterval = 0.4 //default apple
    @objc dynamic var delay:CFTimeInterval = 0
    @objc dynamic var to:Any!
    @objc dynamic var timingFunction = CAMediaTimingFunction(controlPoints: 0.5, 1.1+Float(Animation.force/3), 1, 1)
    @objc dynamic var fillMode:CAMediaTimingFillMode = .forwards
    @objc dynamic var useable:Bool = false
    var composition:[Animation]?
    
    //MARK: - Initialization
    init(_ view:UIView, fillSize:CGSize) {
        self.view = view
        self.type = .fillSize
        self.to = fillSize
    }
    
    init(_ view:UIView, cornerRadius:CGFloat){
        self.view   = view
        self.type   = .cornerRadius
        self.to     = cornerRadius
    }
    
    init(_ view:UIView, composition:[Animation]) {
        self.view = view
        self.type = .composite
        self.composition = composition
    }
    
    init(_ view:UIView, type:AnimationType!){
        self.view = view
        self.type = type
        
        switch type! {
        case .zoomIn:
            self.view.layer.opacity = 0
        case .fadeIn:
            self.view.layer.opacity = 0
        default:break
        }
    }
    //MARK: - Prepare View
    func makeViewUseable(){
        self.view.isHidden = false
        self.view.isUserInteractionEnabled = true
    }
    //MARK: - Equatable
    static func == (lhs: Animation, rhs: Animation) -> Bool {
        return lhs === rhs
    }
    
    //MARK: - Builder Pattern
    func setDuration(_ duration:CFTimeInterval) -> Self{
        self.duration = duration
        return self
    }
    
    func setDelay(_ delay:CFTimeInterval) -> Self{
        self.delay = delay
        return self
    }
    
    func setFillMode(_ fillMode:CAMediaTimingFillMode) -> Self{
        self.fillMode = fillMode
        return self
    }
}
