//
//  OnboardingViewController.swift
//  CalorieCount
//
//  Created by Terence Zama on 19/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit

class AuthOnboardingVC: UIViewController {
    
    let animationController = AnimationController([])
    @IBOutlet var hideable:Array<UIView>!
    @IBOutlet weak var logoView: RLogoView!
    fileprivate var currentSender:UIView!
    var viewAppeared = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Colors.primaryColor
        // Do any additional setup after loading the view.
    }
    
    //MARK: - View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !viewAppeared{
            viewAppeared = true
            animateViewWillAppear()
        }else{
            animationController.animations = AnimationsBuilder.build(hideable, type: .fromLeft, properties: [
                "duration":0.3,
                "useable":true
                ])
            animationController.execute(nil)
        }
        
        
    }
    
    //MARK: - Actions
    @IBAction func hideableTapped(_ sender: Any) {
        currentSender = sender as? UIView
        
        var targets = hideable
        let index = targets!.firstIndex(of: sender as! UIView)!
        if index > 1{return}
        targets?.remove(at: index)
        animationController.animations =
            AnimationsBuilder.build(targets!, type: .fadeOut, properties: ["duration":0.3])
        animationController.executeAll {
            switch index {
            case 0: //registration
                self.performSegue(withIdentifier: "authRegisterSegue", sender: nil)
            case 1: //login
                self.performSegue(withIdentifier: "authLoginSegue", sender: nil)
            case 3: // facebook
                break
            case 4: // google
                break
            default:
                break
            }
            self.animationController.animations = [Animation(self.currentSender, type: .fadeOut)]
            self.animationController.executeAll(nil)
        }
        
    }
    
    
    
    //MARK: - Animations
    func animateViewWillAppear(){
        let animations = hideable.map { (target) -> Animation in
            return Animation(target, type: .fadeIn).setDuration(0.2)
        }
        animationController.animations = animations
        self.logoView.animate({
            self.animationController.execute {
                
            }
        })
        
    }
    
    //MARK: - Prepare Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AuthFormVc{
            vc.fakeCardOriginalFrame = self.view.convert(self.currentSender.frame, from: self.currentSender)
        }
    }
    

}
