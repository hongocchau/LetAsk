//
//  InboxTableViewController.swift
//  LetAsk
//
//  Created by Ho Ngoc Chau on 1/9/15.
//  Copyright (c) 2015 Ho Ngoc Chau. All rights reserved.
//

import UIKit
import Parse

class InboxTableViewController: UITableViewController {

    var currentUser = PFUser()
    var questions = [PFObject]()
    var senderNames = [String]()
    
    var senderWithQuestions = [(String,[PFObject])]()
    var ownQuestions = [PFObject]()
    
    @IBAction func logOut(sender: AnyObject) {
        PFUser.logOutInBackgroundWithBlock { (error) -> Void in
            if error != nil {
                
                let alert = UIAlertController.showErrorAlert("Error", message: error!.localizedDescription)
                self.presentViewController(alert, animated: true, completion: nil)
                
            } else {
                // Do Nothing !
                self.performSegueWithIdentifier("backLaunch", sender: self)
            }
        }
        
    }
    
    @IBAction func close(segue:UIStoryboardSegue) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        currentUser = PFUser.currentUser()!
        
        self.tableView.tableFooterView = UIView(frame:CGRectZero)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var query = PFQuery(className: "Question")
        query.whereKey("recipientIds", equalTo: currentUser.objectId!)
        query.orderByAscending("createdAt")
        query.findObjectsInBackgroundWithBlock { (questions, error) -> Void in
            if error != nil {
                
                let alert = UIAlertController.showErrorAlert("Error", message: error!.localizedDescription)
                self.presentViewController(alert, animated: true, completion: nil)
                
            } else {
                
                self.questions = questions as! [PFObject]
                self.senderNames = self.questions.map({ (question) -> String in
                    return question.objectForKey("senderName") as! String
                })
                
                //println("\(senderNames)")
                self.senderNames = self.distinct(self.senderNames)
                
                self.senderWithQuestions = self.senderNames.map({ (senderName) -> (String,[PFObject]) in
                    return (senderName,self.questions.filter({ (question) -> Bool in
                        return senderName == question.objectForKey("senderName") as! String
                    }))
                })
                
                //println("\(self.senderWithQuestions.count)")
                //self.tableView.reloadData()
                
                var query = PFQuery(className: "Question")
                query.whereKey("senderId", equalTo: self.currentUser.objectId!)
                query.orderByAscending("createdAt")
                query.findObjectsInBackgroundWithBlock({ (questions, error) -> Void in
                    
                    if error != nil {
                        
                        let alert = UIAlertController.showErrorAlert("Error", message: error!.localizedDescription)
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        self.ownQuestions = questions as! [PFObject]
                        self.tableView.reloadData()
                    }

                    
                })
                
            }
        }

    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        //println("\(ownQuestions.count)")
        return senderWithQuestions.count + (ownQuestions.count == 0 ? 0 : 1)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section < senderWithQuestions.count {
            let (senderName, questions) = senderWithQuestions[section]
            return senderName
        } else {
            return "Your Questions"
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let labelRect = CGRect(x: 15, y: tableView.sectionHeaderHeight - 16, width: 300, height: 14)
        let label = UILabel(frame: labelRect)
        label.font = UIFont.boldSystemFontOfSize(14)
        
        label.text = tableView.dataSource!.tableView!(tableView, titleForHeaderInSection: section)
        
        let separatorRect = CGRect(x: 15, y: tableView.sectionHeaderHeight - 0.5, width: tableView.bounds.size.width - 15, height: 0.5)
        let separator = UIView(frame: separatorRect)
        separator.backgroundColor = tableView.separatorColor
        
        let viewRect = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.sectionHeaderHeight)
        let view = UIView(frame: viewRect)
        view.addSubview(label)
        view.addSubview(separator)
        
        return view
        
        
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if section < senderWithQuestions.count {
            let (senderName, questions) = senderWithQuestions[section]
            return questions.count
        } else {
            return ownQuestions.count
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cellIdentifer = "InboxCell"
    
    let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifer, forIndexPath: indexPath) as! UITableViewCell
    
    // Configure the cell...
        
    if indexPath.section < senderWithQuestions.count {
        
        let (senderName, questions) = senderWithQuestions[indexPath.section]

        let questionForCell = questions[indexPath.row]
        
        cell.textLabel!.text = questionForCell.objectForKey("question") as? String
        
    } else {
        
        let questionForCell = ownQuestions[indexPath.row]
        
        cell.textLabel!.text = questionForCell.objectForKey("question") as? String

        }
    
    
    return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section < senderWithQuestions.count {
            performSegueWithIdentifier("addAnswer", sender: indexPath)
        } else {
            performSegueWithIdentifier("viewAnswer", sender: indexPath)
        }
        
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
        
            if indexPath.section == senderWithQuestions.count {
            
                let question = ownQuestions[indexPath.row]
                
                ownQuestions.removeAtIndex(indexPath.row)
                
                question.deleteInBackgroundWithBlock({ (succeeded, error) -> Void in
                    if error != nil {
                        let alert = UIAlertController.showErrorAlert("Error", message: error!.localizedDescription)
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        
                        self.tableView.reloadData()
                    }
                })
                
            } else {
                
            }
            
        }
        
    
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "addAnswer" {
            
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! AddAnswerViewController
            
            let (senderName, questions) = senderWithQuestions[(sender as! NSIndexPath).section]
            controller.question = questions[(sender as! NSIndexPath).row]
            controller.sender = senderName
            
            controller.delegate = self
            
        } else if segue.identifier == "viewAnswer" {
            
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! ViewAnswersViewController
            
            controller.question = ownQuestions[(sender as! NSIndexPath).row]
            
        }
    }
    
    //MARK: - Helper Methods
    func distinct<T: Equatable>(source: [T]) -> [T] {
        var unique = [T]()
        for item in source {
            if !contains(unique, item) {
                unique.append(item)
            }
        }
        return unique
    }

}

extension InboxTableViewController:AddAnswerViewControllerDelegate {
    
    func addAnswerViewControllerDelegateDidCancel(controller: AddAnswerViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addAnswerViewControllerDelegate(controller: AddAnswerViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
