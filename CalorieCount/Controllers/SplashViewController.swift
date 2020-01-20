//
//  SplashViewController.swift
//  CalorieCount
//
//  Created by Terence Zama on 18/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    @IBOutlet weak var container: CircularView!
    @IBOutlet weak var logoLabel: UILabel!
    private var animationController:AnimationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAnimation()
    }
    
    
    //MARK: - Animations
    func startAnimation(){
        let labelSize = logoLabel.frame.size
        let padding:CGFloat = 32
        let diagonal = sqrt(pow(UIScreen.main.bounds.width, 2)+pow(UIScreen.main.bounds.height,2))

        animationController = AnimationController(
            [
            Animation(container, composition: [
                Animation(container, fillSize:CGSize(width: labelSize.width+padding, height: labelSize.width+padding)),
                Animation(container, cornerRadius: (labelSize.width+padding)/2)
                ]).setDuration(1.5),
             Animation(container, fillSize: CGSize(width: diagonal, height: diagonal)).setDelay(0.5).setDuration(0.3),
             Animation(logoLabel, type: .zoomOut).setDuration(1)
            ])
        animationController.execute {
            self.goToNextScreen()
        }
        
    }

    
    //MARK: - Next Screen
    func goToNextScreen(){
        if AppUser.current() != nil {
            let menuStoryboard  = UIStoryboard(name: "Menu", bundle: nil)
            let vc              = menuStoryboard.instantiateInitialViewController()!
            UIView.performWithoutAnimation {
                self.show(vc, sender: nil)
            }
        }else{
            self.performSegue(withIdentifier: "showAuthentication", sender: nil)
        }
        
    }

    
    //MARK: - Animations
    func hideAllButtons(){
        
    }

}
