//
//  Folder.swift
//  iWork
//
//  Created by Erick Sanchez on 7/1/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import Foundation

extension Directory {
    public var folder: Folder {
        return self.info! as! Folder
    }
}

extension Folder {
    
    public var tasksDescription: String? {
        if let directories = self.directory!.children as? Set<Directory> {
            var nCompletedTasks = 0, nTasks = 0
            for directory in directories {
                if directory.info! is Task, !(directory.info! is Project) {
                    if directory.task.isCompleted {
                        nCompletedTasks += 1
                    }
                    nTasks += 1
                }
            }
            if nCompletedTasks == nTasks {
                return "Tasks are completed"
            } else {
                return "\(nTasks - nCompletedTasks) tasks remains"
                // return "\(nCompletedTasks) out of \(tasks.count) tasks completed"
            }
        } else {
            return nil
        }
    }

}
