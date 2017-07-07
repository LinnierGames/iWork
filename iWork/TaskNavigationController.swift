//
//  TaskNavigationController.swift
//  iWork
//
//  Created by Erick Sanchez on 7/4/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import UIKit

public enum CDEditingStyle {
    case none
    case insert
    case update
    case delete
}

class TaskNavigationController: UINavigationController {
    
    var task: Task!
    
    var parentDirectory: Directory?
    
    var option: CDEditingStyle!

}
