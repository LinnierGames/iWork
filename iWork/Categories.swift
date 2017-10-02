//
//  Categories.swift
//  iWork
//
//  Created by Erick Sanchez on 7/1/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import UIKit
import CoreData

extension UITabBarController {
    var taskManager: TaskManagerTableViewController {
        return (self.viewControllers![0] as! UINavigationController).viewControllers.first as! TaskManagerTableViewController
    }
}

extension UITableView {
    
    func returnCell(forIdentifier identifier: String = "cell", atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = self.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        cell.textLabel?.text = nil
        cell.textLabel?.textColor = UIColor.black
        cell.detailTextLabel?.text = nil
        cell.detailTextLabel?.textColor = UIColor.black
        cell.accessoryType = .none
        
        return cell
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

extension UIColor {
    
    static var defaultButtonTint: UIColor { return UIColor(red: 0, green: 122/255, blue: 1, alpha: 1) }
    
    static var disabledState: UIColor { return UIColor(white: 0.65, alpha: 1) }
    static var disabledStateOpacity: CGFloat { return 0.35 }
}

extension NSDecimalNumber {
    public var currencyValue: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        return formatter.string(from: NSNumber(value: self.doubleValue))
    }
}
