//
//  MealCell.swift
//  CalorieCount
//
//  Created by Terence Zama on 28/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit
import SwipeCellKit
class MealCell: SwipeTableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var calorieLabel: UILabel!
    @IBOutlet weak var calorieContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.backgroundColor = #colorLiteral(red: 0.9475007653, green: 0.2240420878, blue: 0.1897725463, alpha: 0.3014768836)
        self.selectedBackgroundView = view
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


    }
    

    
}
