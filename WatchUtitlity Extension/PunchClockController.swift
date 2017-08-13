//
//  PunchClockController.swift
//  iWork
//
//  Created by Erick Sanchez on 8/11/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import WatchKit
import CoreData

class PunchClockController: WKInterfaceController {
    
    @IBOutlet var labelTimeLeft: WKInterfaceLabel!
    @IBOutlet var labelLastPunch: WKInterfaceLabel!
    @IBOutlet var labelLastPunchTitle: WKInterfaceLabel!
    @IBOutlet var labelSum: WKInterfaceLabel!
    
    @IBOutlet var labelDebug: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
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
