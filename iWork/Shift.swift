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
}
