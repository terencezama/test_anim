//
//  AnimationController.swift
//  CalorieCount
//
//  Created by Terence Zama on 18/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit
extension CAAnimation {
    var persist:Bool {
        set{
            self.isRemovedOnCompletion = !newValue
        }
        get{
            return !self.isRemovedOnCompletion
        }
    }
    func setPersistence() -> Self{
        self.persist = true
        return self
    }
}
class AnimationController:NSObject, CAAnimationDelegate {
    var animations:Array<Animation>!
    fileprivate var completed: (() -> Void)?
    var currentTime:CFTimeInterval = 0
    var isAnimating = false
    var isExecutingAll = false
    var executions = 0
    
    //MARK: - Animation Executions
    init(_ animations:[Animation]) {
        self.animations = animations
    }
    
    func execute(_ completion:(()->())?){
        self.isExecutingAll = false
        self.isAnimating = true
        self.completed = completion
        let animation = animations.remove(at: 0)
        process(animation)
    }
    
    func executeAll(_ completion:(()->())?){
        self.isAnimating = true
        self.completed = completion
        self.isExecutingAll = true
        self.executions = animations.count
        animations.forEach { (animation) in
            process(animation)
        }
    }
    
    func process(_ animation:Animation){
        
        if animation.useable {animation.makeViewUseable()}
        
        let caanimation:CAAnimation!
        switch animation.type! {
        case .composite:
            let groupAnimation = CAAnimationGroup()
            groupAnimation.animations = []
            animation.composition?.forEach({ (a) in
                let caanim      = self.getCAAnimation(a)!
                caanim.persist  = true
                groupAnimation.animations?.append(caanim)
            })
            caanimation = groupAnimation
            
        default:
            caanimation = self.getCAAnimation(animation)!
        }
        
        if animation.type == .composite || caanimation.isKind(of: CAAnimationGroup.self) {
            caanimation.beginTime   =  animation.delay
        }else{
            caanimation.beginTime   =  CACurrentMediaTime() + animation.delay
        }
        caanimation.persist     = true
        caanimation.fillMode    = animation.fillMode
        caanimation.duration    = animation.duration
        caanimation.delegate    = self
        caanimation.timingFunction = animation.timingFunction
        caanimation.setValue(animation, forKey: "animation")
        animation.view.layer.add(caanimation, forKey: nil)
    }
    
    //MARK: - CAAnimationDelegate
    func animationDidStart(_ anim: CAAnimation) {
        
    }
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if isExecutingAll {
            executions -= 1
            if executions == 0{
                self.isAnimating = false
                if let completed = self.completed{
                    completed()
                }
            }
        }else{
            if animations.count > 0 {
                execute(self.completed)
            }else{
                self.isAnimating = false
                if let completed = self.completed{
                    completed()
                }
            }
        }
        
        if let animation = anim.value(forKey: "animation") as? Animation{
            switch animation.type!{
            case .fadeIn, .zoomIn:
                animation.view.layer.opacity = 1.0
                animation.view.isUserInteractionEnabled = true
            case .fadeOut, .zoomOut:
                animation.view.isUserInteractionEnabled = false
                
            default: break
            }
        }
        
        
    }
    
    //MARK: - Animation Swift
    func getCAAnimation(_ animation:Animation) -> CAAnimation?{
        var anim:CAAnimation?
        switch animation.type! {
        case .fillSize:
            let basicAnim        = CABasicAnimation()
            basicAnim.keyPath    = "bounds.size"
            basicAnim.fromValue  = animation.view.bounds.size
            basicAnim.toValue    = animation.to as! CGSize
            anim = basicAnim
        case .cornerRadius:
            let basicAnim        = CABasicAnimation()
            basicAnim.keyPath    = "cornerRadius"
            basicAnim.fromValue  = animation.view.layer.cornerRadius
            basicAnim.toValue    = animation.to as! CGFloat
            anim = basicAnim
        case .zoomOut:
            let groupAnim           = CAAnimationGroup()
            let scaleAnim           = getScaleAnimation(from: 1, to: 2*Animation.force).setPersistence()
            let opacityAnim         = getOpacityAnimation(from: 1, to: 0).setPersistence()
            scaleAnim.fillMode      = animation.fillMode
            opacityAnim.fillMode    = animation.fillMode
            groupAnim.animations = [scaleAnim,opacityAnim]
            anim = groupAnim
        case .zoomIn:
            let groupAnim           = CAAnimationGroup()
            let scaleAnim           = getScaleAnimation(from: 0, to: 1).setPersistence()
            let opacityAnim         = getOpacityAnimation(from: 0, to: 1).setPersistence()
            scaleAnim.fillMode      = animation.fillMode
            opacityAnim.fillMode    = animation.fillMode
            groupAnim.animations = [scaleAnim,opacityAnim]
            anim = groupAnim
        case .highlight:
            let kanim           = CAKeyframeAnimation()
            kanim.keyPath       = "opacity"
            kanim.values        = [1,0,1]
            kanim.keyTimes      = [0, 0.5, 1]
            anim                = kanim
        case .fadeIn:
            anim = getOpacityAnimation(from: 0, to: 1).setPersistence()
        case .fadeOut:
            anim = getOpacityAnimation(from: 1, to: 0).setPersistence()
        case .fromLeft:
            let groupAnim           = CAAnimationGroup()
            let transAnim           = getTranslationAnimation(from: -100, to: 0)
            let opacityAnim         = getOpacityAnimation(from: 0, to: 1).setPersistence()
            transAnim.fillMode      = animation.fillMode
            opacityAnim.fillMode    = animation.fillMode
            groupAnim.animations = [transAnim,opacityAnim]
            anim = groupAnim
            
        case .toLeft:
            let groupAnim           = CAAnimationGroup()
            let transAnim           = getTranslationAnimation(from: 0, to: -100)
            let opacityAnim         = getOpacityAnimation(from: 1, to: 0).setPersistence()
            transAnim.fillMode      = animation.fillMode
            opacityAnim.fillMode    = animation.fillMode
            groupAnim.animations = [transAnim,opacityAnim]
            anim = groupAnim
        case .fromRight:
            let groupAnim           = CAAnimationGroup()
            let transAnim           = getTranslationAnimation(from: 100, to: 0)
            let opacityAnim         = getOpacityAnimation(from: 0, to: 1).setPersistence()
            transAnim.fillMode      = animation.fillMode
            opacityAnim.fillMode    = animation.fillMode
            groupAnim.animations = [transAnim,opacityAnim]
            anim = groupAnim
        case .toRight:
            let groupAnim           = CAAnimationGroup()
            let transAnim           = getTranslationAnimation(from: 0, to: 100)
            let opacityAnim         = getOpacityAnimation(from: 1, to: 0).setPersistence()
            transAnim.fillMode      = animation.fillMode
            opacityAnim.fillMode    = animation.fillMode
            groupAnim.animations = [transAnim,opacityAnim]
            anim = groupAnim
        default:break
        }
        anim?.fillMode    = animation.fillMode
        return anim
    }
    
    //MARK: - Animation Helpers
    func getOpacityAnimation(from:CGFloat, to:CGFloat) -> CABasicAnimation{
        let animation           = CABasicAnimation()
        animation.keyPath       = "opacity"
        animation.fromValue     = from
        animation.toValue       = to
        return animation
    }
    
    func getScaleAnimation(from:CGFloat, to:CGFloat) -> CABasicAnimation{
        let animation           = CABasicAnimation()
        animation.keyPath       = "transform.scale"
        animation.fromValue     = from
        animation.toValue       = to
        return animation
    }
    func getTranslationAnimation(from:CGFloat, to:CGFloat) -> CABasicAnimation{
        let animation           = CABasicAnimation()
        animation.keyPath       = "transform.translation.x"
        animation.fromValue     = from
        animation.toValue       = to
        return animation
    }
}


