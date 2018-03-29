//
//  Punch.swift
//  iWork
//
//  Created by Erick Sanchez on 7/11/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import Foundation
import CoreData

extension String {
    init(_ punch: TimePunch.PunchType) {
        self = punch.debugDescription
    }
}

extension TimePunch {
    public enum PunchType: Int16, CustomDebugStringConvertible {
        case StartShift = 0
        case StartBreak = 1
        case EndBreak = 2
        case StartLunch = 3
        case EndLunch = 4
        case EndShift = 5

        public var debugDescription: String {
            switch self {
            case .StartShift:
                return "Start Shift"
            case .StartBreak:
                return "Start Break"
            case .EndBreak:
                return "End Break"
            case .StartLunch:
                return "Start Lunch"
            case .EndLunch:
                return "End Lunch"
            case .EndShift:
                return "End Shift"
            }
        }
    }

    convenience init(punch: PunchType, timeStamp stamp: Date = Date(), inContext context: NSManagedObjectContext, forShift shift: Shift) {
        self.init(context: context)

        self.punchValue = punch.rawValue
        self.timeStamp = stamp as NSDate
        self.shift = shift
    }

    public var punchType: PunchType {
        set {
            self.punchValue = newValue.rawValue
        }
        get {
            return PunchType(rawValue: self.punchValue)!
        }
    }

    public var duration: TimeInterval? {
        let punches = self.shift!.punches!.reversed
        let selfIndex = punches.index(of: self)
        if self != punches.lastObject! as! TimePunch {
            let previousPunch = punches[selfIndex+1] as! TimePunch

            return self.timeStamp?.timeIntervalSince(previousPunch.timeStamp! as Date)
        } else {
            return nil
        }
    }
}

import UserNotifications

private typealias UserNotifications = UNUserNotificationCenter
extension UserNotifications {

    /// used to mark the fifth hour fire date in user notifications
    func addLocalNotification(forPunch punch: TimePunch, forShift shift: Shift) {
        //TODO: only add if each notification is still current, not in the past
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "punch_fifth_hour_title", arguments: nil)
        content.subtitle = AppDelegate.sharedInstance.currentEmployer.name!
        content.categoryIdentifier = "UTILS_PUNCH_CLOCK"
        content.sound = UNNotificationSound.default()
        content.userInfo = ["shift": shift.objectID.uriRepresentation().absoluteString]

        let fifthHour = String(date: punch.timeStamp!.addingTimeInterval(CTDateComponentHour*5), dateStyle: .none, timeStyle: .long)

        let dateInfo60 = DateComponents(date: (punch.timeStamp! as Date).addingTimeInterval(CTDateComponentHour*4), forComponents: [.day, .month, .year, .hour, .minute, .second])
        content.body = NSString.localizedUserNotificationString(forKey: "punch_fifth_hour", arguments: ["1h", fifthHour])
        var trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo60, repeats: false)

        // Create the request object.
        self.add(UNNotificationRequest(identifier: "note_fifth_hour-60", content: content, trigger: trigger)) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            }
        }

        let dateInfo30 = DateComponents(date: (punch.timeStamp! as Date).addingTimeInterval(CTDateComponentHour*5-CTDateComponentMinute*30), forComponents: [.day, .month, .year, .hour, .minute, .second])
        content.body = NSString.localizedUserNotificationString(forKey: "punch_fifth_hour", arguments: ["30m", fifthHour])
        trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo30, repeats: false)

        // Create the request object.
        self.add(UNNotificationRequest(identifier: "note_fifth_hour-30", content: content, trigger: trigger)) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            }
        }

        let dateInfo15 = DateComponents(date: (punch.timeStamp! as Date).addingTimeInterval(CTDateComponentHour*5-CTDateComponentMinute*15), forComponents: [.day, .month, .year, .hour, .minute, .second])
        content.body = NSString.localizedUserNotificationString(forKey: "punch_fifth_hour", arguments: ["15m", fifthHour])
        trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo15, repeats: false)

        // Create the request object.
        self.add(UNNotificationRequest(identifier: "note_fifth_hour-15", content: content, trigger: trigger)) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            }
        }

        let dateInfo10 = DateComponents(date: (punch.timeStamp! as Date).addingTimeInterval(CTDateComponentHour*5-CTDateComponentMinute*10), forComponents: [.day, .month, .year, .hour, .minute, .second])
        content.body = NSString.localizedUserNotificationString(forKey: "punch_fifth_hour", arguments: ["10m", fifthHour])
        trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo10, repeats: false)

        // Create the request object.
        self.add(UNNotificationRequest(identifier: "note_fifth_hour-10", content: content, trigger: trigger)) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            }
        }

        let dateInfo5 = DateComponents(date: (punch.timeStamp! as Date).addingTimeInterval(CTDateComponentHour*5-CTDateComponentMinute*5),  forComponents: [.day, .month, .year, .hour, .minute, .second])
        content.body = NSString.localizedUserNotificationString(forKey: "punch_fifth_hour", arguments: ["5m", fifthHour])
        trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo5, repeats: false)

        // Create the request object.
        self.add(UNNotificationRequest(identifier: "note_fifth_hour-5", content: content, trigger: trigger)) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            }
        }

        let dateInfo = DateComponents(date: (punch.timeStamp! as Date).addingTimeInterval(CTDateComponentHour*5-CTDateComponentMinute),  forComponents: [.day, .month, .year, .hour, .minute, .second])
        content.body = NSString.localizedUserNotificationString(forKey: "punch_fifth_hour", arguments: ["1m", fifthHour])
        trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)

        // Create the request object.
        self.add(UNNotificationRequest(identifier: "note_fifth_hour-1", content: content, trigger: trigger)) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }

    /// Clears all consecutive notifcations, if any
    func removePendingFifthHourNotificationRequests() {
        let identifiers = ["note_fifth_hour-60","note_fifth_hour-30","note_fifth_hour-15","note_fifth_hour-10","note_fifth_hour-5","note_fifth_hour-1"]
        self.removePendingNotificationRequests(withIdentifiers: identifiers)
        self.removeDeliveredNotifications(withIdentifiers: identifiers)
    }
}
