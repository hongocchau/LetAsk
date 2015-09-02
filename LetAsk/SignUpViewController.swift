//
//  SignUpViewController.swift
//  LetAsk
//
//  Created by Ho Ngoc Chau on 31/8/15.
//  Copyright (c) 2015 Ho Ngoc Chau. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController {
    
    // MARK: - IB properties
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBAction func signup(sender: AnyObject) {
        
        var username = (usernameField.text).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        var password = (passwordField.text).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        var email = (emailField.text).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if username.isEmpty || password.isEmpty || email.isEmpty {
            let alert = UIAlertController.showErrorAlert("Error", message: "Please enter Username, Password and Email !")
            presentViewController(alert, animated: true, completion: nil)
            
        } else {
            let newUser = PFUser()
            newUser.username = username
            newUser.password = password
            newUser.email = email
            
            newUser.signUpInBackgroundWithBlock({ (succeeded, error) -> Void in
                if error != nil {
                    let alert = UIAlertController.showErrorAlert("Error", message: error!.localizedDescription)
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                } else {
                    // Sign up ok - go to main screen
                    self.performSegueWithIdentifier("showMain", sender: self)
                }
            })
            
        }
    }
    
    // MARK: - ViewController Event

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.hidesBarsOnSwipe = true
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        usernameField.becomeFirstResponder()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        //navigationItem.hidesBackButton = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(segue:UIStoryboardSegue) {
        
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
