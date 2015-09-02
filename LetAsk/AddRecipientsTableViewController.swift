//
//  AddRecipientsTableViewController.swift
//  LetAsk
//
//  Created by Ho Ngoc Chau on 31/8/15.
//  Copyright (c) 2015 Ho Ngoc Chau. All rights reserved.
//

import UIKit
import Parse

class AddRecipientsTableViewController: UITableViewController, AddQuestionTableViewControllerDelegate {

    
    @IBOutlet weak var sendBarButton: UIBarButtonItem!
    
    var friendList = FriendList()
    var friendsRelation = PFRelation()
    var currentUser = PFUser()
    
    var recipients = [String]()
    
    var question:Question!
    
    
    @IBAction func sendQuestion(sender: AnyObject) {
        
        uploadQuestion()
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        currentUser = PFUser.currentUser()!
        
        friendsRelation = currentUser.objectForKey("friendsRelation") as! PFRelation
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let query = friendsRelation.query()
        query?.orderByAscending("username")
        query?.findObjectsInBackgroundWithBlock({ (users, error) -> Void in
            
            if error != nil {
                println("Error: \(error?.localizedDescription)")
            } else {
                
                self.friendList.friends = users as! [PFUser]
                self.tableView.reloadData()
            }
        })
        
        if question != nil {
            sendBarButton.enabled = true
        } else {
            sendBarButton.enabled = false
        }
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
        
        let cellIdentifier = "AddRecipientsCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UITableViewCell

        let friendForCell = friendList.friends[indexPath.row]
        
        cell.textLabel!.text = friendForCell.username
        
        if contains(recipients, friendForCell.objectId!) {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }


        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let friend = friendList.friends[indexPath.row]
        
        if let selectedCell = tableView.cellForRowAtIndexPath(indexPath) {
            
            if selectedCell.accessoryType == .None {
                selectedCell.accessoryType = .Checkmark
                recipients.append(friend.objectId!)
            } else {
                selectedCell.accessoryType = .None
            }
            
        }

        
    }

    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "addQuestion" {
            let navigationController = segue.destinationViewController as! UINavigationController
            
            let controller = navigationController.topViewController as! AddQuestionTableViewController
            
            controller.delegate = self
        }
    }
    
    func addQuestionTableViewControllerDidCancel(controller: AddQuestionTableViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addQuestionTableViewController(controller: AddQuestionTableViewController, question: Question) {
        
        self.question = question
        
        dismissViewControllerAnimated(true, completion: nil)
        
        //println("\(self.question.content)")
    }
    
    func resize(originalImage: UIImage, toWidth width:CGFloat, toHeight height:CGFloat) -> UIImage {
        
        let newSize = CGSize(width: width, height: height)
        let newRectangle = CGRect(x: 0, y: 0, width: width, height: height)
        
        UIGraphicsBeginImageContext(newSize)
        originalImage.drawInRect(newRectangle)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
        
    }
    
    func uploadQuestion() {
        
        var imageData = NSData()
        var imageName = ""
        
        if let image = question.image {
            
            let newImage = resize(image, toWidth: 150.0, toHeight: 150.0)
            
            imageData = UIImagePNGRepresentation(newImage)
            imageName = "image.png"
        }
        
        var uploadQuestion = PFObject(className: "Question")
        uploadQuestion.setObject(self.currentUser.objectId!, forKey: "senderId")
        uploadQuestion.setObject(self.currentUser.username!, forKey: "senderName")
        uploadQuestion.setObject(self.recipients, forKey: "recipientIds")
        uploadQuestion.setObject(self.question.content, forKey: "question")
        uploadQuestion.setObject(imageData, forKey: "image")
                    
        uploadQuestion.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
        if error != nil {
            let alert = UIAlertController.showErrorAlert("Error", message: error!.localizedDescription)
            self.presentViewController(alert, animated: true, completion: nil)
            } else {
                // Do Nothing !
                self.tabBarController?.selectedIndex = 0
            }

        })
    }
        
}

