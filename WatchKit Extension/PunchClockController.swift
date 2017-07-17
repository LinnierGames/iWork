//
//  PunchClockController.swift
//  iWork
//
//  Created by Erick Sanchez on 7/16/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import UIKit
import WatchKit

class PunchClockController: WKInterfaceController {

    @IBOutlet var tableView: WKInterfaceTable!
    
    @IBOutlet var labelTimeLeft: WKInterfaceLabel!
    @IBOutlet var labelLastPunch: WKInterfaceLabel!
    @IBOutlet var labelLastPunchTitle: WKInterfaceLabel!
    @IBOutlet var labelSum: WKInterfaceLabel!
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        tableView.setNumberOfRows(8, withRowType: "row")
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
