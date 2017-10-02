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
    
    public enum Priority: Int16 {
        case High = 3
        case Medium = 2
        case Low = 1
        case None = 0
        case Unimportant = -1
    }
    
    public var priority: Priority {
        set {
            self.priorityValue = newValue.rawValue
        }
        get {
            return Priority(rawValue: self.priorityValue)!
        }
    }
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

extension NSFetchedResultsController {
    func task(at indexPath: IndexPath) -> Task {
        return object(at: indexPath) as! Task
    }
}
