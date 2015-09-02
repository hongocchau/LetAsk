//
//  AnswerViewController.swift
//  LetAsk
//
//  Created by Ho Ngoc Chau on 1/9/15.
//  Copyright (c) 2015 Ho Ngoc Chau. All rights reserved.
//

import UIKit
import Parse

protocol AddAnswerViewControllerDelegate:class {
    
    func addAnswerViewControllerDelegateDidCancel (controller: AddAnswerViewController)
    
    func addAnswerViewControllerDelegate(controller: AddAnswerViewController)
}

class AddAnswerViewController: UIViewController {
    
    var question:PFObject!
    var sender = ""
    
    var currentUser = PFUser()

    @IBOutlet weak var senderLabel: UILabel!
    
    @IBOutlet weak var questionTextView: UITextView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var answerView: UIView!
    
    weak var delegate:AddAnswerViewControllerDelegate?
    
    @IBAction func cancel(sender: AnyObject) {
        
        delegate?.addAnswerViewControllerDelegateDidCancel(self)
        
    }
    
    @IBAction func yes(sender: AnyObject) {
        
        let yesRelation = question.relationForKey("yesRelation")
        yesRelation.addObject(currentUser)
        
        question.saveInBackgroundWithBlock { (succeeded, error) -> Void in
            
            if error != nil {
                
                let alert = UIAlertController.showErrorAlert("Error", message: error!.localizedDescription)
                self.presentViewController(alert, animated: true, completion: nil)
                
            } else {
         
                var recipientIds = self.question.objectForKey("recipientIds") as! [String]
                
                if let foundIndex = find(recipientIds, self.currentUser.objectId!) {
                    recipientIds.removeAtIndex(foundIndex)
                    self.question.setObject(recipientIds, forKey: "recipientIds")
                    self.question.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
                        if error != nil {
                            
                            let alert = UIAlertController.showErrorAlert("Error", message: error!.localizedDescription)
                            self.presentViewController(alert, animated: true, completion: nil)
                                
                        } else {
                                
                                // Do Nothing
                                self.delegate?.addAnswerViewControllerDelegate(self)
                        }

                    })
                }
                        
            }

        }
    }
    
    
    @IBAction func no(sender: AnyObject) {
        
        let noRelation = question.relationForKey("noRelation")
        noRelation.addObject(currentUser)
        
        question.saveInBackgroundWithBlock { (succeeded, error) -> Void in
            
            if error != nil {
                
                let alert = UIAlertController.showErrorAlert("Error", message: error!.localizedDescription)
                self.presentViewController(alert, animated: true, completion: nil)
                
            } else {
                
                var recipientIds = self.question.objectForKey("recipientIds") as! [String]
                
                if let foundIndex = find(recipientIds, self.currentUser.objectId!) {
                    recipientIds.removeAtIndex(foundIndex)
                    self.question.setObject(recipientIds, forKey: "recipientIds")
                    self.question.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
                        if error != nil {
                            let alert = UIAlertController.showErrorAlert("Error", message: error!.localizedDescription)
                            self.presentViewController(alert, animated: true, completion: nil)
                        } else {
                                
                            // Do Nothing
                            self.delegate?.addAnswerViewControllerDelegate(self)
                                
                        }
                            
                    })
                }

            }
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        senderLabel.text = sender + " asked:"
        senderLabel.sizeToFit()
        
        questionTextView.text = question.objectForKey("question") as! String
        questionTextView.sizeToFit()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        imageView.image = UIImage(data: question.objectForKey("image") as! NSData)
        
        currentUser = PFUser.currentUser()!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        imageView.frame = CGRect(x: imageView.frame.origin.x , y: questionTextView.frame.origin.y + questionTextView.frame.height + 15, width: imageView.frame.width, height: imageView.frame.height)
        
        answerView.frame = CGRect(x: answerView.frame.origin.x , y: imageView.frame.origin.y + imageView.frame.height + 15, width: answerView.frame.width, height: answerView.frame.height)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
