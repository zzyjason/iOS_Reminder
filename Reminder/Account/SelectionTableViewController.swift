//
//  SelectionTableViewController.swift
//  Reminder
//
//  Created by Jason on 2017/12/2.
//  Copyright © 2017年 Yijia Huang. All rights reserved.
//

import UIKit
import Firebase
class SelectionTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    var users = [FbUser]()
    func fetchUsers(){
        DatabaseService.shared.userRef.observe(.value,  with: { (snapshot) in
            if snapshot.exists() {
                guard let usersSnapshot = UsersSnapshot(with: snapshot) else { return }
                self.users = usersSnapshot.users
                self.users.sort(by: { $0.created?.compare($1.created!) == .orderedDescending })
                DatabaseService.shared.userRef.child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {}
                    else {

                    }
                }, withCancel: nil)

            }
            
        }, withCancel: nil)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    
    // MARK: - Table view data source

    
    
    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return users.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberSelection", for: indexPath) as! GroupMemberTableViewCell
        
        // Configure the cell...
        let User=users[indexPath.row]
        cell.Name.text=User.name ?? ""
        
        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
