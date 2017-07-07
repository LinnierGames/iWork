//
//  Categories.swift
//  iWork
//
//  Created by Erick Sanchez on 7/1/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import UIKit
import CoreData

extension UIViewController {
    
    var appDelegate: AppDelegate {
        return (UIApplication.shared.delegate as! AppDelegate)
    }
    
    var container: NSPersistentContainer {
        return appDelegate.persistentContainer
    }
    
}

extension UITableViewCell {
    
    func setState(enabled: Bool) {
        if enabled {
            self.textLabel!.alpha = 1
            self.detailTextLabel!.alpha = 1
            self.isUserInteractionEnabled = true
        } else {
            self.textLabel!.alpha = 0.3
            self.detailTextLabel!.alpha = 0.3
            self.isUserInteractionEnabled = false
        }
    }
}

extension UITextField {
    open func setStyleToParagraph(withPlaceholderText placeholder: String? = "", withInitalText text: String? = "") {
        self.autocorrectionType = .default
        self.autocapitalizationType = .words
        self.text = text
        self.placeholder = placeholder
        
    }
    
}

extension UIAlertController {
    var inputField: UITextField {
        return self.textFields!.first!
    }
    
}
