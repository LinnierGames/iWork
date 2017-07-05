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
    convenience init(parent: Directory? = nil, title: String = "", dateCreated: NSDate = NSDate(), dueDate: NSDate? = nil, context: NSManagedObjectContext, forRole role: Role) {
        self.init(context: context)
        
        _ = Directory.createDirectory(forDirectoryInfo: self, withParent: parent, in: context, forRole: role)
        
        self.title = title
        self.dateCreated = dateCreated
        self.dueDate = dueDate
    }
    
}
