//
//  Role.swift
//  iWork
//
//  Created by Erick Sanchez on 7/2/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import Foundation
import CoreData

extension Role {
    convenience init(title: String = "Untitled Role", startDate: NSDate = NSDate(), inContext context: NSManagedObjectContext, forEmployer employer: Employer) {
        self.init(context: context)
        
        self.title = title
        self.employer = employer
        self.startDate = startDate
    }
}
