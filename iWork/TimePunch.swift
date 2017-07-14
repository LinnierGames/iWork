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
