//
//  MealCellAdapter.swift
//  CalorieCount
//
//  Created by Terence Zama on 28/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import Foundation
class MealCellAdapter{
    static let dateFormatter = DateFormatter()
    class func configure(cell:MealCell,for meal:Meal){
        dateFormatter.dateFormat    = "dd MMM yyyy"
        cell.titleLabel.text        = meal.text
        cell.calorieLabel.text      = "\(meal.calories)"
        cell.timeLabel.text         = meal.time
        cell.dateLabel.text         = dateFormatter.string(from: meal.date)
        
        if meal.calories > AppSettings.Current.caloriesPerDay{
            cell.calorieLabel.textColor = #colorLiteral(red: 0.9475007653, green: 0.2240420878, blue: 0.1897725463, alpha: 1)
        }else{
            cell.calorieLabel.textColor = #colorLiteral(red: 0.3019607843, green: 0.8509803922, blue: 0.3921568627, alpha: 1)
        }
    }
}
