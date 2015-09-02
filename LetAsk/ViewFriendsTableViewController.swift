//
//  FriendsTableViewController.swift
//  LetAsk
//
//  Created by Ho Ngoc Chau on 31/8/15.
//  Copyright (c) 2015 Ho Ngoc Chau. All rights reserved.
//

import UIKit
import Parse

class ViewFriendsTableViewController: UITableViewController {
    
    var friendsRelation = PFRelation()
    var friendList = FriendList()
    var currentUser = PFUser()


    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        currentUser = PFUser.currentUser()!
        friendsRelation = currentUser.objectForKey("friendsRelation") as! PFRelation
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let query = friendsRelation.query()
        query?.orderByAscending("username")
        query?.findObjectsInBackgroundWithBlock({ (friends, error) -> Void in
            
            if error != nil {
                
                let alert = UIAlertController.showErrorAlert("Error", message: error!.localizedDescription)
                self.presentViewController(alert, animated: true, completion: nil)
                
            } else {
                
                self.friendList.friends = friends as! [PFUser]
                self.tableView.reloadData()
                
            }
            
        })
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
        return friendList.friends.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "ViewFriendsCell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        
        let friend = friendList.friends[indexPath.row]
        
        cell.textLabel!.text = friend.username
        
        return cell
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showEditFriends" {
            
            let navigationController = segue.destinationViewController as! UINavigationController
            
            let controller = navigationController.topViewController as! EditFriendsTableViewController
            
            controller.friendList = friendList
            controller.delegate = self
            
        }
    }

}

extension ViewFriendsTableViewController:EditFriendsTableViewControllerDelegate {
    
    func editFriendsTableViewControllerDidDone(controller: EditFriendsTableViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func editFriendsTableViewControllerDidCancel(controller: EditFriendsTableViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
