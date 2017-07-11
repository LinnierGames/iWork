//
//  Task.swift
//  iWork
//
//  Created by Erick Sanchez on 7/1/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import Foundation
import CoreData

extension Directory {
    public var task: Task {
        return self.info! as! Task
    }
}

extension Task {
    convenience init(titleTask title: String, dueDate: NSDate? = nil, dateCreated: NSDate = NSDate(), parent: Directory? = nil, inContext context: NSManagedObjectContext, forRole role: Role) {
        self.init(context: context)
        
        _ = Directory(info: self, withParent: parent, inContext: context, forRole: role)
        
        self.title = title
        self.dateCreated = dateCreated
        self.dueDate = dueDate
    }
    
    override public func willSave() {
        super.willSave()
        
        if let assignedBy = self.assignedBy {
            if assignedBy == "" {
                self.assignedBy = nil
            }
        }
    }
}
