//
//  UsersViewController.swift
//  CalorieCount
//
//  Created by Terence Zama on 27/04/2019.
//  Copyright © 2019 Terence Zama. All rights reserved.
//

import UIKit
import SwipeCellKit
import UIKit
import SwipeCellKit
import SwiftSpinner
import RealmSwift
class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate, UISearchBarDelegate {
    
    var notificationToken: NotificationToken? = nil
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var results:Results<User>!
    var selectedUser:User?
    //MARK: - UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.allowsSelection = true
        tableView.tintColor = #colorLiteral(red: 0.9475007653, green: 0.2240420878, blue: 0.1897725463, alpha: 1)
        
        let realm = DBLayer.shared.realm
        results = realm.objects(User.self).sorted(byKeyPath: "displayName", ascending: false)
        observeRealmChanges()
        
        searchBar.delegate = self
        
    }
    deinit {
        notificationToken?.invalidate()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "updateUserSegue"{
            let vc = segue.destination as! UsersEditViewController
            vc.updateUser = selectedUser
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUser.intemediate_user_id = nil
        UsersRequest.shared.get(){ result in
            //
        }
        tableView.reloadData()
        
    }
    //MARK: - UITableviewDelegate & UITableViewDatasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as! UserCell
        cell.delegate = self
        UserCellAdapter.configure(cell: cell, for: results[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            self.selectedUser = self.results[indexPath.row]
            UsersRequest.shared.delete(ids: [self.selectedUser!.uid], users:[self.selectedUser!], completion: { result in
                
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
            self.selectedUser = self.results[indexPath.row]
            self.performSegue(withIdentifier: "updateUserSegue", sender: nil)
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
        return 75
    }
    //MARK: - UITableView Editing Mode
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if AppUser.current()?.jwt.role == "admin"{
            AppUser.intemediate_user_id = results[indexPath.row].uid
            self.performSegue(withIdentifier: "showMealsSegue", sender: nil)
//            self.tabBarController?.selectedIndex = 0
        }
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
        self.performSegue(withIdentifier: "addUserSegue", sender: nil)
    }
    @IBAction func deleteButtonTapped(_ sender: Any) {
        if let selectedIndexPaths = self.tableView.indexPathsForSelectedRows{
            if selectedIndexPaths.count > 0 {
                let selectedUsers = selectedIndexPaths.map { (indexPath) -> User in
                    return results[indexPath.row]
                }
                let ids = selectedUsers.map { (user) -> String in
                    return user.uid
                }
                UsersRequest.shared.delete(ids: ids, users: selectedUsers) { result in
                    
                }
            }
        }
        
        tableView.setEditing(false, animated: true)
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
    
    //MARK: - Searching
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let realm = DBLayer.shared.realm
        if searchText.count == 0 {
            results = realm.objects(User.self).sorted(byKeyPath: "displayName", ascending: false)
            observeRealmChanges()
        }else{
            results = realm.objects(User.self).filter("displayName CONTAINS[c] '\(searchText)'").sorted(byKeyPath: "displayName", ascending: false)
            observeRealmChanges()
        }
    }
    
    
}
