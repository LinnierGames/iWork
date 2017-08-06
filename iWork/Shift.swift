//
//  Shift.swift
//  iWork
//
//  Created by Erick Sanchez on 7/11/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import Foundation
import CoreData

extension Shift {
    convenience init(date: Date = Date(), inContext context: NSManagedObjectContext, forEmployer employer: Employer) {
        self.init(context: context)
        
        self.date = date as NSDate
        self.employer = employer
    }
    
    public var lastPunch: TimePunch? {
        return self.punches?.array.last as! TimePunch?
    }
    
    /// This includes the duration of the last punch, excluding start lunch, till the current time
    public var onTheClockDuration: TimeInterval? {
        if let punches = self.punches?.array as? [TimePunch] {
            var duration: TimeInterval = 0
            var perviousPunch: TimePunch? = nil
            for punch in punches {
                if let lastPunch = perviousPunch, perviousPunch!.punchType != .StartLunch {
                    duration += punch.timeStamp!.timeIntervalSince(lastPunch.timeStamp! as Date)
                }
                perviousPunch = punch
            }
            
            return duration
        } else {
            return nil
        }
    }
    
    public var continuousOnTheClockDuration: TimeInterval? {
        if let onTheClockDuration = self.onTheClockDuration {
            let lastPunch = self.lastPunch!
            if lastPunch.punchType != .StartLunch, lastPunch.punchType != .EndShift {
                return onTheClockDuration + Date().timeIntervalSince(lastPunch.timeStamp! as Date)
            } else {
                return onTheClockDuration
            }
        } else {
            return nil
        }
    }
    
    public var onTheClockPunch: TimePunch? {
        if let punches = self.punches?.array as? [TimePunch] {
            for punch in punches.reversed() {
                if punch.punchType == .StartShift || punch.punchType == .EndLunch {
                    return punch
                }
            }
            
            return nil
        } else {
            return nil
        }
    }
    
    public var fithHour: Date? {
        return (self.onTheClockPunch?.timeStamp as Date?)!.addingTimeInterval( 5*CTDateComponentHour)
    }
    
    public var isCompletedShift: Bool? {
        if let punch = self.lastPunch {
            return punch.punchType == .EndShift ? true : false
        } else {
            return nil
        }
    }
}
