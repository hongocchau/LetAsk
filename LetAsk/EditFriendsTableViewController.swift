//
//  EditFriendTableViewController.swift
//  LetAsk
//
//  Created by Ho Ngoc Chau on 31/8/15.
//  Copyright (c) 2015 Ho Ngoc Chau. All rights reserved.
//

import UIKit
import Parse

protocol EditFriendsTableViewControllerDelegate: class {
    
    func editFriendsTableViewControllerDidCancel(controller:EditFriendsTableViewController)
    func editFriendsTableViewControllerDidDone(controller:EditFriendsTableViewController)
    
}

class EditFriendsTableViewController: UITableViewController {

    var friendList = FriendList()
    var users = [PFUser]()
    var currentUser = PFUser()
    
    weak var delegate:EditFriendsTableViewControllerDelegate?
    
    @IBAction func done(sender: AnyObject) {
        
        delegate?.editFriendsTableViewControllerDidDone(self)
    }
    
    
    @IBAction func Cancel(sender: AnyObject) {
        delegate?.editFriendsTableViewControllerDidCancel(self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let query = PFUser.query()
        query?.orderByAscending("username")
        
        query?.findObjectsInBackgroundWithBlock({ (users, error) -> Void in
            
            if error != nil {
                
                let alert = UIAlertController.showErrorAlert("Error", message: error!.localizedDescription)
                self.presentViewController(alert, animated: true, completion: nil)
                
            } else {
                
                if let users = users {
                    
                    self.users = users as! [PFUser]
                    
                    
                    self.users = self.users.filter({ (user) -> Bool in
                        //println("\((user as PFUser).objectId != self.currentUser.objectId)")
                        return (user as PFUser).objectId != self.currentUser.objectId
                    })
                    
                    //println("\(self.users)")
                    
                }
                
                self.tableView.reloadData()
                
            }
            
        })
        
        currentUser = PFUser.currentUser()!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return users.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "EditFriendCell"
        
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        
        let userForCell = users[indexPath.row]

        cell.textLabel!.text = users[indexPath.row].username
        
        if isFriend(userForCell) {
            
            cell.accessoryType = .Checkmark
            
        } else {
            
            cell.accessoryType = .None
            
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //println("\(friendList.friends)")
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let selectedCell = tableView.cellForRowAtIndexPath(indexPath) {
            
            let selectedUser = users[indexPath.row]
            
            // Create Friend Relation
            let friendsRelation = currentUser.relationForKey("friendsRelation")
            
            if isFriend(selectedUser) {
                
                selectedCell.accessoryType = .None
                friendList.friends.removeAtIndex(indexPath.row)
                
                friendsRelation.removeObject(selectedUser)
                
            } else {
                
                selectedCell.accessoryType = .Checkmark
                
                friendsRelation.addObject(selectedUser)
                
            }
            
            currentUser.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
                
                if error != nil {
                    
                    let alert = UIAlertController.showErrorAlert("Error", message: error!.localizedDescription)
                    self.presentViewController(alert, animated: true, completion: nil)
                
                } else {
                    
                    // Do nothing !
                }
                
            })
            
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - Helper Methods
    
    func isFriend(user:PFUser) -> Bool {
        
        for friend:PFUser in friendList.friends {
            
            if user.objectId == friend.objectId {
                return true
            }
        }
        
        return false
    }


}
