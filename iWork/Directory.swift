//
//  Directory.swift
//  iWork
//
//  Created by Erick Sanchez on 7/1/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import Foundation
import CoreData

extension Directory {
    
    convenience init(info: DirectoryInfo, withParent parent: Directory?, inContext context: NSManagedObjectContext, forRole role: Role) {
        self.init(context: context)
        
        self.info = info
        self.parent = parent
        self.role = role
    }
    
    override public var description: String {
        switch self.info! {
        case is Folder:
            return "I am a Folder"
        case is Project:
            return "I am a Project"
        case is Task:
            return "I am a Task"
        default:
            return NSStringFromClass(self.info!.classForCoder)
        }
    }
    
    static func fetchDirectoryWithParentDirectory(_ directory: Directory?, `in` context: NSManagedObjectContext, forRole role: Role) -> [Directory] {
        let fetch: NSFetchRequest<Directory> = Directory.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(key: "info.title", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
        
        if directory == nil {
            fetch.predicate = NSPredicate(format: "role == %@ AND parent == nil", role)
        } else {
            fetch.predicate = NSPredicate(format: "role == %@ AND parent == %@", role, directory!)
        }
        
        var result = [Directory]()
        
        if let newResult = try? context.fetch(fetch) {
            for hierarchy in newResult {
                result.append( hierarchy)
                
            }
            
        }
        
        return result
        
    }
    
    var isDirectory: Bool {
        return (self.info! is Folder || self.info! is Project)
    }
    
    /**
     Counts the number of repeating classes in the children set
     - Returns: dictionary with the count of each class title
     */
    var childrenInfo : [String:Int] {
        var dic = [String:Int]()
        
        for child in (children?.allObjects)! as! [Directory] {
            if let key = String(NSStringFromClass(child.info!.classForCoder)) {
                var count: Int = dic[key] ?? 0
                count += 1
                dic[key] = count
                
            }
            
        }
        
        return dic
        
    }
    
}
