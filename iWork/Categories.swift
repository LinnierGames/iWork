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

extension UITableViewController {
    
    func returnCell(forIdentifier identifier: String = "title", atIndexPath indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
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

extension Bool {
    public mutating func invert() {
        if self == true {
            self = false
        } else {
            self = true
        }
    }
}

extension String {
    init?(date: NSDate) {
        self.init("date")
    }
    
    init?(date: Date) {
        self.init("date")
    }
}

let CTDateComponentMinute: TimeInterval = 60
let CTDateComponentHour: TimeInterval = CTDateComponentMinute*60
let CTDateComponentDay: TimeInterval = CTDateComponentHour*24

extension DateComponents {
    init(date: Date, forComponents components: Set<Calendar.Component>)  {
        self = Calendar.current.dateComponents(components, from: date)
    }
    var timeInterval: TimeInterval {
        get {
            var interval: TimeInterval = 0
            if let _second = second {
                interval += TimeInterval(_second)
            }
            if let _minute = minute {
                interval += TimeInterval(_minute)*CTDateComponentMinute
            }
            if let _hour = hour {
                interval += TimeInterval(_hour)*CTDateComponentHour
            }
            
            return interval
        }
    }
    var weekdayTitle: String? {
        if let day = weekday {
            switch day {
            case 1:
                return "Sunday"
            case 2:
                return "Monday"
            case 3:
                return "Tuesday"
            case 4:
                return "Wednesday"
            case 5:
                return "Thursday"
            case 6:
                return "Friday"
            case 7:
                return "Saturday"
            default:
                return nil
            }
        } else {
            return nil
        }
    }
}

extension UIColor {
    
    static var defaultButtonTint: UIColor { return UIColor(red: 0, green: 122/255, blue: 1, alpha: 1) }
    
    static var disabledState: UIColor { return UIColor(white: 0.65, alpha: 1) }
    static var disabledStateOpacity: CGFloat { return 0.35 }
}
