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
    
    override public var description: String {
        switch self.info! {
        case is Folder:
            return "I am a Folder"
        case is Task:
            return "I am a Task"
        default:
            return NSStringFromClass(self.info!.classForCoder)
        }
    }
    
    static func createDirectory( forDirectoryInfo info: DirectoryInfo, withParent parent: Directory?, `in` context: NSManagedObjectContext) -> Directory {
        let newHierarchy = Directory(context: context)
        newHierarchy.parent = parent
        
        newHierarchy.info = info
        
        return newHierarchy
        
    }
    
    static func fetchDirectoryWithParentDirectory(_ directory: Directory?, `in` context: NSManagedObjectContext) -> [Directory] {
        let fetch: NSFetchRequest<Directory> = Directory.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(key: "info.title", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
        
        if directory == nil {
            fetch.predicate = NSPredicate(format: "parent == nil")
        } else {
            fetch.predicate = NSPredicate(format: "parent == %@", directory!)
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
        return (self.info! is Folder)
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
