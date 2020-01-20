//
//  Constraints.swift
//  CalorieCount
//
//  Created by Terence Zama on 22/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//
/*

 This class is to be used in ib where we make linking of constraints easier
 and it will keeps the original values of the constraints
 */
import UIKit

class Constraints:NSObject {
    
    
    @IBOutlet weak var top: NSLayoutConstraint?
    @IBOutlet weak var left: NSLayoutConstraint?
    @IBOutlet weak var right: NSLayoutConstraint?
    @IBOutlet weak var bottom: NSLayoutConstraint?
    
    struct Values {
        var top:CGFloat = 0
        var left:CGFloat = 0
        var right:CGFloat = 0
        var bottom:CGFloat = 0
    }
    
    var original = Values()
    
    override init() {
        super.init()
        addObservers()
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: "top")
    }
    
    private func addObservers(){
        addObserver(self, forKeyPath: "top", options: [.initial], context: nil)
        addObserver(self, forKeyPath: "left", options: [.initial], context: nil)
        addObserver(self, forKeyPath: "right", options: [.initial], context: nil)
        addObserver(self, forKeyPath: "bottom", options: [.initial], context: nil)
    }

    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let key = keyPath{
            let _original = object as! Constraints
            switch key {
            case "top":
                self.original.top = (_original.top?.constant) ?? 0
            case "left":
                self.original.left = (_original.left?.constant) ?? 0
            case "right":
                self.original.right = (_original.right?.constant) ?? 0
            case "bottom":
                self.original.bottom = (_original.bottom?.constant) ?? 0
            default:break
            }
        }
    }
    

    
}
