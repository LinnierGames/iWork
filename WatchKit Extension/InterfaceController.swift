//
//  InterfaceController.swift
//  WatchKit Extension
//
//  Created by Erick Sanchez on 7/16/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet var tableView: WKInterfaceTable!
    
    private struct Table {
        static var rowTask = 0
        static var rowPunchClock = 1
    }
    
    private var rowTask: WKCustomTableRow! {
        didSet {
            rowTask.textLabel.setText("Task Manager")
        }
    }
    private var rowPunchClock: WKCustomTableRow! {
        didSet {
            rowPunchClock.textLabel.setText("Punch Clock")
        }
    }
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        rowTask = tableView.rowController(at: Table.rowTask) as! WKCustomTableRow
        rowPunchClock = tableView.rowController(at: Table.rowPunchClock) as! WKCustomTableRow
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
