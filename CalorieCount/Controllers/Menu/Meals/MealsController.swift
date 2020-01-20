//
//  MealsController.swift
//  CalorieCount
//
//  Created by Terence Zama on 29/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit
class MealsController{
    static let shared = MealsController()
    private init(){
        setUpFormmatters()
    }
    weak var viewController:MealsViewController!
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    var pickers:[UIDatePicker]?
    
    var filters:[Date]!
    var isFilterEnable = false
    
    func setUpFormmatters(){
        dateFormatter.dateFormat    = "dd/MMM/yyyy"
        timeFormatter.dateFormat    = "HH:mm"
    }
    func applyFilters(pickers:[UIDatePicker]){
        filters = pickers.map({ (picker) -> Date in
            return picker.date
        })
        viewController.clearFilterButton.isHidden = false
        let realm = DBLayer.shared.realm
        
        let fromDate = mergeDateAndTime(date: filters[0], time: filters[2])
        let toDate   = mergeDateAndTime(date: filters[1], time: filters[3])
        viewController.results = realm.objects(Meal.self).sorted(byKeyPath: "date", ascending: false)
            .filter("date >= %@ AND date <= %@",fromDate,toDate)
        viewController.observeRealmChanges()
        viewController.tableView.reloadData()
    }
    
    func clearFilters(){
        let realm = DBLayer.shared.realm
        viewController.results = realm.objects(Meal.self).sorted(byKeyPath: "date", ascending: false)
        viewController.observeRealmChanges()
//        viewController.tableView.reloadData()
    }
    
    func mergeDateAndTime(date:Date, time:Date)->Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MMM/yyyy HH:mm"
        let string = dateFormatter.string(from: date)+" "+timeFormatter.string(from: time)
        return formatter.date(from: string)!
    }
}
