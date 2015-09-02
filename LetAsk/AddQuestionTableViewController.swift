//
//  AddQuestionTableViewController.swift
//  LetAsk
//
//  Created by Ho Ngoc Chau on 31/8/15.
//  Copyright (c) 2015 Ho Ngoc Chau. All rights reserved.
//

import UIKit
import MobileCoreServices

protocol AddQuestionTableViewControllerDelegate: class {
    
    func addQuestionTableViewControllerDidCancel(controller:AddQuestionTableViewController)
    func addQuestionTableViewController(controller:AddQuestionTableViewController, question: Question)
    
}


class AddQuestionTableViewController: UITableViewController, UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    
    @IBOutlet weak var questionTextView: UITextView!
    var imagePicker:UIImagePickerController!
    
    var image:UIImage?
    @IBOutlet weak var imageView: UIImageView!
    
    weak var delegate:AddQuestionTableViewControllerDelegate?
    
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    var question:Question!
    
    
    @IBAction func done(sender: AnyObject) {
        
        if !questionTextView.text.isEmpty
        {
            question = Question(content: questionTextView.text, image: image)
            delegate?.addQuestionTableViewController(self, question: question)
        }
    }
    
    
    @IBAction func cancel(sender: AnyObject) {
        delegate?.addQuestionTableViewControllerDidCancel(self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if image == nil {
            questionTextView.becomeFirstResponder()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 88
        } else if indexPath.section == 1 && indexPath.row == 1 {
            return 176
        }
        return 44
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 1 && indexPath.row == 0 {
            
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            
            if UIImagePickerController.isSourceTypeAvailable(.Camera) {
                imagePicker.sourceType = .Camera
            } else {
                imagePicker.sourceType = .PhotoLibrary
            }
            
            imagePicker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(imagePicker.sourceType)!
            
            presentViewController(imagePicker, animated: false, completion: nil)
            
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 0 && indexPath.row == 0 {
            return nil
        }
        return indexPath
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        var  mediaType = info[UIImagePickerControllerMediaType] as? String
        
        
        if mediaType! == kUTTypeImage as String {
            
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
            
            if imagePicker.sourceType == .Camera {
                // save the image captured by camera
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
            
        }
        
        imageView.image = image
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        dismissViewControllerAnimated(false, completion: nil)
    }
}

extension AddQuestionTableViewController:UITextViewDelegate {
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        let oldText:NSString = questionTextView.text
        let newText:NSString = oldText.stringByReplacingCharactersInRange(range, withString: text)
        
        if newText.length > 0 {
            doneBarButton.enabled = true
        } else {
            doneBarButton.enabled = false
        }
        return true
    }
    
}
