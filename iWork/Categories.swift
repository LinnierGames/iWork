//
//  Categories.swift
//  iWork
//
//  Created by Erick Sanchez on 7/1/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import UIKit
import CoreData
import UniversalKit_iOS

extension UITabBarController {
    var taskManager: TaskManagerTableViewController {
        return (self.viewControllers![0] as! UINavigationController).viewControllers.first as! TaskManagerTableViewController
    }
}

extension UIViewController {
    
    var appDelegate: AppDelegate {
        return (UIApplication.shared.delegate as! AppDelegate)
    }
    
    var container: NSPersistentContainer {
        return AppDelegate.persistentContainer
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

public struct UIAlertActionInfo {
    var title: String?
    var style: UIAlertActionStyle
    var handler: ((UIAlertAction) -> Swift.Void)?
    
    init(title: String?, style: UIAlertActionStyle = .default, handler: ((UIAlertAction) -> Swift.Void)?) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}

extension UIAlertController {
    open func addActions(cancelButton cancel: String? = "Cancel", alertStyle: UIAlertControllerStyle = .alert, actions: UIAlertActionInfo...) {
        for action in actions {
            self.addAction(UIAlertAction(title: action.title, style: action.style, handler: action.handler))
        }
        if cancel != nil {
            self.addAction(UIAlertAction(title: cancel, style: .cancel, handler: nil))
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
    init(_ date: NSDate, dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .none) {
        self.init(DateFormatter.localizedString(from: date as Date, dateStyle: dateStyle, timeStyle: timeStyle))!
    }
    
    init(_ date: Date, dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .none) {
        self = String(date as NSDate, dateStyle: dateStyle, timeStyle: timeStyle)
    }
    
    init(_ timeInterval: TimeInterval) {
        var temp = abs(Int(timeInterval))
        let hours = temp/Int(CTDateComponentHour)
        temp -= hours*Int(CTDateComponentHour)
        
        let minutes = temp/Int(CTDateComponentMinute)
        temp -= minutes*Int(CTDateComponentMinute)
        
        let seconds = temp
        var string = ""
        if hours > 0 {
            string.append("\(hours)h ")
        }
        if minutes > 0 {
            string.append("\(minutes)m ")
        }
        string.append("\(seconds)s")
        
        self = string
    }
}

extension DateComponents {
    init(date: Date, forComponents components: Set<Calendar.Component>)  {
        self = Calendar.current.dateComponents(components, from: date)
    }
    
    /// returns the length in time, seconds+mintues+hours only
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

public extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    public class func once(token: String, block: (Void)->Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) {
            return
        }
        
        _onceTracker.append(token)
        block()
    }
}
