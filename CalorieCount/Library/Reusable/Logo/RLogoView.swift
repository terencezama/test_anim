//
//  LogoView.swift
//  CalorieCount
//
//  Created by Terence Zama on 19/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit

class RLogoView: UIView {
    
    @IBOutlet weak var logoView: CircularView!
    @IBOutlet weak var descLabel: Label!
    
    let animationController = AnimationController([])
    //MARK: Initialization
    func setupFromNib(){
        let nib = UINib(nibName: "RLogoView", bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { fatalError("Error loading \(self) from nib") }
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        view.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        view.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        view.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
    }
    override init(frame: CGRect) {
        super.init(frame:frame)
        setupFromNib()
        _init()
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
        _init()
    }
    fileprivate func _init(){
        self.backgroundColor = UIColor.clear
    }
    
    func animate(_ completion:(()->())?){
        animationController.animations = [
            Animation(logoView, type: .zoomIn).setDuration(1),
            Animation(descLabel, type: .fadeIn).setDuration(1)
        ]
        animationController.execute(completion)
    }
    
    func show(_ completion:(()->())?){
        animationController.animations = AnimationsBuilder.build([logoView,descLabel], type: .fadeIn, properties: ["duration":0.1])
        animationController.executeAll(completion)
    }
    
    func hide(_ completion:(()->())?){
        animationController.animations = [
            Animation(logoView, type: .fadeOut).setDuration(1),
            Animation(descLabel, type: .fadeOut).setDuration(1)
        ]
        animationController.executeAll(completion)
    }
    
    

}
