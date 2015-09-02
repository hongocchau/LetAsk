//
//  UIAlertViewController+ShowError.swift
//  LetAsk
//
//  Created by Ho Ngoc Chau on 31/8/15.
//  Copyright (c) 2015 Ho Ngoc Chau. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    class func showErrorAlert(title: String, message: String) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: title, style: .Default, handler: nil)
        
        alert.addAction(okAction)
        
        return alert
        
    }
   
}
