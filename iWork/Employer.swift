//
//  Employer.swift
//  iWork
//
//  Created by Erick Sanchez on 7/5/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import Foundation
import CoreData

extension Employer {
    convenience init(name: String = "Untitled Employer", inContext context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.name = name
        
        //Adds a new Role
        let newRole = Role(inContext: context, forEmployer: self)
        self.addToRoles(newRole)
        self.selectedRole = newRole
    }
}
