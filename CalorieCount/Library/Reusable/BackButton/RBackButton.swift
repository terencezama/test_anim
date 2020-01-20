//
//  RBackButton.swift
//  CalorieCount
//
//  Created by Terence Zama on 19/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit

class RBackButton: UIControl {
    let size:CGFloat = 40
    var animationController = AnimationController([])
    
    //MARK: - Initialization
    func _init(){
        self.clipsToBounds = true
        self.backgroundColor = Colors.background
        self.heightAnchor.constraint(equalToConstant: size).isActive = true
        self.widthAnchor.constraint(equalToConstant: size).isActive = true
        
        let image = UIImage(named: "left-arrow")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = Colors.primaryColor
        imageView.frame = CGRect(x: UI.spacing, y: UI.spacing, width: size-UI.spacing*2, height: size-UI.spacing*2)
        imageView.contentMode = .scaleAspectFill
        self.addSubview(imageView)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
       _init()
        
    }
    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview != nil{
            animationController.animations = [
                Animation(self, type: .zoomIn).setDuration(1)
            ]
        }else{
            animationController.animations = [
                Animation(self, type: .fadeOut).setDuration(1)
            ]
        }
        animationController.execute(nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = size/2
    }
    
    override var intrinsicContentSize: CGSize{
        get{
            return CGSize(width: size, height: size)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !animationController.isAnimating{
            animationController.animations = [
                Animation(self, type: .zoomOut).setDuration(1)
            ]
            animationController.execute(nil)
        }
        super.touchesBegan(touches, with: event)
    }

}
