//
//  TimeInterval+Class.swift
//  UniversalKit
//
//  Created by Erick Sanchez on 8/12/17.
//
//

import Foundation

public let CTDateComponentMinute: TimeInterval = 60
public let CTDateComponentHour: TimeInterval = CTDateComponentMinute*60
public let CTDateComponentDay: TimeInterval = CTDateComponentHour*24

extension String {
    
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
