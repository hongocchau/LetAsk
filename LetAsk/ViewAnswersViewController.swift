//
//  ViewAnswersViewController.swift
//  LetAsk
//
//  Created by Ho Ngoc Chau on 1/9/15.
//  Copyright (c) 2015 Ho Ngoc Chau. All rights reserved.
//

import UIKit
import Parse

class ViewAnswersViewController: UIViewController {
    
    var question:PFObject!
    
    var currentUser = PFUser()
    
    var yesRelation:PFRelation?
    
    var noRelation:PFRelation?
    
    var friendsSayYes = [PFUser]()
    var friendsSayNo = [PFUser]()
    
    @IBOutlet weak var yesButton: UIButton!
    
    @IBOutlet weak var noButton: UIButton!
    
    @IBOutlet weak var questionTextView: UITextView!
    
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var answerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        questionTextView.text = question.objectForKey("question") as! String
        questionTextView.sizeToFit()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        imageView.image = UIImage(data: question.objectForKey("image") as! NSData)
        
        currentUser = PFUser.currentUser()!
        
        yesRelation = question.objectForKey("yesRelation") as? PFRelation
        noRelation = question.objectForKey("noRelation") as? PFRelation
        
        
        yesButton.layer.cornerRadius = yesButton.frame.size.width / 2
        yesButton.clipsToBounds = true
        
        noButton.layer.cornerRadius = yesButton.frame.size.width / 2
        noButton.clipsToBounds = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        yesButton.enabled = false
        noButton.enabled = false
        
        imageView.frame = CGRect(x: imageView.frame.origin.x , y: questionTextView.frame.origin.y + questionTextView.frame.height + 15, width: imageView.frame.width, height: imageView.frame.height)
        
        answerView.frame = CGRect(x: answerView.frame.origin.x , y: imageView.frame.origin.y + imageView.frame.height + 15, width: answerView.frame.width, height: answerView.frame.height)
        
        if let yesRelation = self.yesRelation {
            let query = yesRelation.query()
            query?.orderByAscending("username")
            query?.findObjectsInBackgroundWithBlock({ (friends, error) -> Void in
            
            if error != nil {
                
                let alert = UIAlertController.showErrorAlert("Error", message: error!.localizedDescription)
                self.presentViewController(alert, animated: true, completion: nil)
                
            } else {
                if friends!.count != 0 {
                    self.friendsSayYes = friends as! [PFUser]
                    self.yesButton.enabled = true
                    let buttonTitle = String(format: "%d", friends!.count) + " Yes"
                    self.yesButton.setTitle(buttonTitle, forState: .Normal)
                }
                
            }
            
        })
        }
        
        if let noRelation = self.noRelation {
            let query = noRelation.query()
            query?.orderByAscending("username")
            query?.findObjectsInBackgroundWithBlock({ (friends, error) -> Void in
                
                if error != nil {
                    
                    let alert = UIAlertController.showErrorAlert("Error", message: error!.localizedDescription)
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                } else {
                    if friends!.count != 0 {
                        self.friendsSayNo = friends as! [PFUser]
                        self.noButton.enabled = true
                        let buttonTitle = String(format: "%d", friends!.count) + " No"
                        self.noButton.setTitle(buttonTitle, forState: .Normal)
                    }
                }
                
            })
        }


    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "showYes" {
            
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! YesTableViewController
            
            controller.friendsSayYes = friendsSayYes
            
        } else if segue.identifier == "showNo" {
            
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! NoTableViewController
            
            controller.friendsSayNo = friendsSayNo
        }
        
    }
    
    
    @IBAction func close(segue:UIStoryboardSegue) {
        
    }

}
