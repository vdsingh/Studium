//
//  SettingsViewController.swift
//  Studium
//
//  Created by Vikram Singh on 7/21/20.
//  Copyright © 2020 Vikram Singh. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit
import Firebase

class SettingsViewController: UITableViewController{
    let realm = try! Realm() //Link to the realm where we are storing information

    
    let cellData: [[String]] = [["Theme", "Reset Wake Up Times"], ["Delete All Assignments","Delete Completed Assignments",  "Delete All Other Events", "Delete All Completed Other Events"], ["Sign Out"]]
    let cellLinks: [[String]] = [["toThemePage", "toWakeUpTimes", ""], ["", "", "", ""], ["toLoginScreen"]]
    
    let alertData: [[String]] = [
        ["Delete All Assignments", "Are you sure you want to delete all assignments? You can't undo this action."],
        ["Delete Completed Assignments", "Are you sure you want to delete all completed assignments? You can't undo this action."],
        ["Delete All Other Events", "Are you sure you want to delete all other events? You can't undo this action."],
        ["Delete All Completed Other Events", "Are you sure you want to delete all completed other events? You can't undo this action."]]
    
    override func viewDidLoad() {
        tableView.tableFooterView = UIView()

    }
    override func viewWillAppear(_ animated: Bool){
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.text = cellData[indexPath.section][indexPath.row]
        return cell!
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return cellData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellData[section].count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if cellLinks[indexPath.section][indexPath.row] != ""{
            performSegue(withIdentifier: cellLinks[indexPath.section][indexPath.row], sender: self)
        }
        
        if cellData[indexPath.section][indexPath.row] == "Clear Notifs"{
            let center = UNUserNotificationCenter.current()
            center.removeAllDeliveredNotifications()    // to remove all delivered notifications
            center.removeAllPendingNotificationRequests()   // to remove all pending notifications
            UIApplication.shared.applicationIconBadgeNumber = 0 // to clear the icon notification badge
//            print("cleared all notifications")
//            print(UIApplication.shared.scheduledLocalNotifications)
        }else if cellData[indexPath.section][indexPath.row] == "Delete All Assignments"{
            createAlertForAssignments(title: alertData[0][0], message: alertData[0][1], isCompleted: false)
        }else if cellData[indexPath.section][indexPath.row] == "Delete Completed Assignments"{
            createAlertForAssignments(title: alertData[1][0], message: alertData[1][1], isCompleted: true)
        }else if cellData[indexPath.section][indexPath.row] == "Delete All Other Events"{
            createAlertForOtherEvents(title: alertData[2][0], message: alertData[2][1], isCompleted: false)
        }else if cellData[indexPath.section][indexPath.row] == "Delete All Completed Other Events"{
            createAlertForOtherEvents(title: alertData[3][0], message: alertData[3][1], isCompleted: true)
        }else if cellData[indexPath.section][indexPath.row] == "Sign Out"{
            do {
                try Auth.auth().signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.secondarySystemBackground
    }
    
    //edit the background color of section headers
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))
        headerView.backgroundColor = UIColor.black
        return headerView
    }
    
    //
    func deleteAllAssignments(isCompleted:Bool){
        let assignments: Results<Assignment>? = realm.objects(Assignment.self)
        
        for assignment in assignments!{
            do{
                if((isCompleted && assignment.complete) || (!isCompleted)){
                    try realm.write{
                        realm.delete(assignment)
                    }
                }
            }catch{
                print(error)
            }
        }
    }
    
    func deleteAllOtherEvents(isCompleted:Bool){
        let otherEvents: Results<OtherEvent>? = realm.objects(OtherEvent.self)
        
        for event in otherEvents!{
            do{
                if((isCompleted && event.complete) || (!isCompleted)){
                    try realm.write{
                        realm.delete(event)
                    }
                }
            }catch{
                print(error)
            }
        }
    }
    
    func createAlertForAssignments(title: String, message: String, isCompleted: Bool){
        let refreshAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.deleteAllAssignments(isCompleted: isCompleted)
          }))

        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
          }))

        present(refreshAlert, animated: true, completion: nil)
    }
    
    func createAlertForOtherEvents(title: String, message: String, isCompleted: Bool){
        let refreshAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.deleteAllOtherEvents(isCompleted: isCompleted)
          }))

        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
          }))

        present(refreshAlert, animated: true, completion: nil)
    }
}
