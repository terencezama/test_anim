//
//  MealsViewController.swift
//  CalorieCount
//
//  Created by Terence Zama on 27/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit
import SwipeCellKit
import RealmSwift

class MealsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
    
    var notificationToken: NotificationToken? = nil
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterButton: CircularButton!
    @IBOutlet weak var clearFilterButton: UIButton!
    var results:Results<Meal>!
    var selectedMeal:Meal?
    //MARK: - UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        MealsController.shared.viewController = self
        
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.allowsSelection = false
        tableView.tintColor = #colorLiteral(red: 0.9475007653, green: 0.2240420878, blue: 0.1897725463, alpha: 1)
        
        let realm = DBLayer.shared.realm
        let userId = AppUser.intemediate_user_id ?? AppUser.current()!.jwt.user_id
        results = realm.objects(Meal.self).sorted(byKeyPath: "date", ascending: false).filter("userId = '\(userId)'")
        observeRealmChanges()
        
    }
    deinit {
        notificationToken?.invalidate()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "updateMealSegue"{
            let vc = segue.destination as! MealsEditViewController
            vc.updateMeal = selectedMeal
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MealsRequest.shared.get(userId: AppUser.current()?.jwt.user_id) { result in
            //
        }
        tableView.reloadData()
    }
    //MARK: - UITableviewDelegate & UITableViewDatasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MealCell") as! MealCell
        cell.delegate = self
        MealCellAdapter.configure(cell: cell, for: results[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            self.selectedMeal = self.results[indexPath.row]
            MealsRequest.shared.delete(ids: [self.selectedMeal!.id], meals:[self.selectedMeal!], completion: { result in
                
            })
        }
        // customize the action appearance
        deleteAction.image = UIImage(named: "trash-circle")
        deleteAction.title = "Delete"
        deleteAction.backgroundColor = #colorLiteral(red: 0.9239231944, green: 0.9410536885, blue: 0.9452863336, alpha: 1)
        deleteAction.textColor = #colorLiteral(red: 1, green: 0.2352941176, blue: 0.1882352941, alpha: 1)
        deleteAction.font = .systemFont(ofSize: 13)
        deleteAction.transitionDelegate = ScaleTransition.default
        
        let editAction = SwipeAction(style: .destructive, title: "Edit") { action, indexPath in
            // handle action by updating model with deletion
            self.selectedMeal = self.results[indexPath.row]
            self.performSegue(withIdentifier: "updateMealSegue", sender: nil)
        }
        // customize the action appearance
        editAction.image = UIImage(named: "edit-circle")
        editAction.title = "Edit"
        editAction.backgroundColor = #colorLiteral(red: 0.9239231944, green: 0.9410536885, blue: 0.9452863336, alpha: 1)
        editAction.textColor = #colorLiteral(red: 0.2128324509, green: 0.4787533879, blue: 1, alpha: 1)
        editAction.font = .systemFont(ofSize: 13)
        editAction.transitionDelegate = ScaleTransition.default
        
        return [deleteAction,editAction]
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    //MARK: - UITableView Editing Mode
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    //MARK: - Actions
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        if results.count == 0 {
            return
        }
        self.tableView.setEditing(!self.tableView.isEditing, animated: true)
        
        if tableView.isEditing{
            sender.title            = "Deselect"
            let deleteButton        = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButtonTapped(_:)))
            deleteButton.tintColor  = Colors.red
            self.navigationItem.rightBarButtonItem = deleteButton
        }else{
            sender.title            = "Select"
            let addButton           = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped(_:)))
            addButton.tintColor     = Colors.primaryColor
            self.navigationItem.rightBarButtonItem = addButton
        }
    }
    @IBAction func addButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "addMealSegue", sender: nil)
    }
    @IBAction func deleteButtonTapped(_ sender: Any) {
        if let selectedIndexPaths = self.tableView.indexPathsForSelectedRows{
            if selectedIndexPaths.count > 0 {
                let selectedMeals = selectedIndexPaths.map { (indexPath) -> Meal in
                    return results[indexPath.row]
                }
                let ids = selectedMeals.map { (meal) -> String in
                    return meal.id
                }
                MealsRequest.shared.delete(ids: ids, meals: selectedMeals) { result in
                    
                }
            }
        }
        
        tableView.setEditing(false, animated: true)
    }
    @IBAction func filterButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "filterMealSegue", sender: nil)
    }
    @IBAction func clearFilterButtonTapped(_ sender: Any) {
        clearFilterButton.isHidden = true
        MealsController.shared.clearFilters()
    }
    
    //MARK: - Realm AutoUpdate
    func observeRealmChanges(){
        // Observe Results Notifications
        notificationToken = results.observe { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.endUpdates()
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
    }
    
    
}
