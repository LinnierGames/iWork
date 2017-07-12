//
//  Punch.swift
//  iWork
//
//  Created by Erick Sanchez on 7/11/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import Foundation
import CoreData

extension TimePunch {
    public enum PunchType: Int16 {
        case StartShift = 0
        case StartBreak = 1
        case EndBreak = 2
        case StartLunch = 3
        case EndLunch = 4
        case EndShift = 5
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
}
