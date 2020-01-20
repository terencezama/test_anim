//
//  AuthFormVc.swift
//  CalorieCount
//
//  Created by Terence Zama on 21/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//
import UIKit
class AuthFormVc: UIViewController {
    var fakeCardOriginalFrame:CGRect!
    var isKeyboardUp = false
    var backButtonTapped = false
    @IBOutlet weak var fakeCard: CardView!
    @IBOutlet weak var logoView: RLogoView!
    @IBOutlet weak var cardView: CardView!
    @IBOutlet var hideable:Array<UIView>!
    fileprivate var viewAppeared = false
    @IBOutlet var cardConstraints: Constraints!
    
    
    var animationController = AnimationController([])
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Colors.primaryColor
        self.dismissKeyboardOnViewTapped()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !viewAppeared{
            self.fakeCard.frame = fakeCardOriginalFrame
            self.fakeCard.isHidden = false
        }else{
            animationController.animations = AnimationsBuilder.build(hideable+[cardView], type: .fromLeft, properties: [
                "duration":0.3,
                "useable":true
                ])
            animationController.executeAll(nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardDidHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.layoutIfNeeded()
        if !viewAppeared{
            viewAppeared = true
            animateViewDidAppear()
        }
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Actions
    @IBAction func backButtonTapped(_ sender: Any) {
        backButtonTapped = true
        if isKeyboardUp {
            self.view.endEditing(true)
        }else{
            showNextScreen()
        }
    }
    
    
    //MARK: - Animation
    func animateViewDidAppear(){
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.fakeCard.frame = self.cardView.convert(self.cardView.bounds, to: self.view)
        }) { (completed) in
            self.cardView.isHidden = false
            self.hideable.forEach({ (view) in
                view.isHidden = false
            })
            self.animationController.animations = AnimationsBuilder.build(self.hideable+[self.cardView], type: .fadeIn, properties: ["duration":1])
            self.animationController.executeAll({
                self.fakeCard.isHidden = true
            })
        }
    }
    
    private func showNextScreen(){
        self.animationController.animations = AnimationsBuilder.build(self.hideable+[self.cardView], type: .toRight, properties: ["duration":0.3])
        self.animationController.executeAll {
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    //MARK: - Segue Preparation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AuthFormVc{
            vc.fakeCardOriginalFrame = self.cardView.convert(self.cardView.bounds, to: self.view)
        }
    }
    
    //MARK: - Keyboard Handling
    @objc func keyBoardWillShow(notification: Notification) {
        if !isKeyboardUp{
            self.logoView.hide(nil)
            isKeyboardUp = true
        }
        self.cardConstraints.bottom?.constant = notification.keyboardSize!.height - UI.buttonHeight*UI.heightRatio - UI.spacing
        self.cardConstraints.left?.constant = 0
        self.cardConstraints.right?.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyBoardWillHide(notification: Notification) {
        self.cardConstraints.bottom?.constant = self.cardConstraints.original.bottom
        self.cardConstraints.left?.constant = self.cardConstraints.original.left
        self.cardConstraints.right?.constant = self.cardConstraints.original.right
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        self.logoView.animate(nil)
    }
    @objc func keyBoardDidHide(notification: Notification) {
        isKeyboardUp = false
        if backButtonTapped {
            self.showNextScreen()
        }
    }
    
}
