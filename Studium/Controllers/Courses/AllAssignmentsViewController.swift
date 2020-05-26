//
//  AllAssignmentsViewController.swift
//  Studium
//
//  Created by Vikram Singh on 5/24/20.
//  Copyright © 2020 Vikram Singh. All rights reserved.
//

import Foundation
import RealmSwift
import ChameleonFramework

class AllAssignmentsViewController: SwipeTableViewController, AssignmentRefreshProtocol{
    
    let realm = try! Realm() //Link to the realm where we are storing information
    var assignments: Results<Assignment>? //Auto updating array linked to the realm
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAssignments()
    }
    
    func loadAssignments(){
        assignments = realm.objects(Assignment.self) //fetching all objects of type Course and updating array with it.
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let assignment = assignments?[indexPath.row]{
            cell.textLabel?.text = assignment.title
            let parentColor = assignment.parentCourse[0].color
            cell.backgroundColor = UIColor(hexString: parentColor)
            cell.textLabel?.textColor = ContrastColorOf(UIColor(hexString: parentColor)!, returnFlat: true)
            cell.accessoryType = assignment.complete ? .checkmark : .none
        }else{
            cell.textLabel?.text = ""
            print("error in AllAssignmentsViewController in cellForRowAt in the assignment if let.")
        }
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assignments!.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let assignment = assignments?[indexPath.row]{
            do{
                try realm.write{
                    assignment.complete = !assignment.complete
                }
            }catch{
                print(error)
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}