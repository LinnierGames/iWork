//
//  PunchClockController.swift
//  iWork
//
//  Created by Erick Sanchez on 8/11/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import WatchKit
import CoreData
import UniversalKit_watchOS

class PunchClockController: WKInterfaceController {
    
    @IBOutlet var labelTimeLeft: WKInterfaceLabel!
    @IBOutlet var labelLastPunch: WKInterfaceLabel!
    @IBOutlet var labelLastPunchTitle: WKInterfaceLabel!
    @IBOutlet var labelSum: WKInterfaceLabel!
    
    @IBOutlet var labelDebug: WKInterfaceLabel!
    
    private var employer: Employer? { didSet { updateUI() } }
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    private func updateUI() {
        if let currentShift = employer?.shifts?.allObjects.first as! Shift? {
            if let lastPunch = currentShift.lastPunch {
                labelLastPunchTitle.setText(String(lastPunch.punchType))
                updateInfo()
            } else { //No punches are made
                labelTimeLeft.setText("--:--:--")
                labelLastPunchTitle.setText("Last Punch")
                labelLastPunch.setText("")
                labelSum.setText("")
            }
        } else { //No punches are made
            labelTimeLeft.setText("--:--:--")
            labelLastPunchTitle.setText("Last Punch")
            labelLastPunch.setText("")
            labelSum.setText("")
        }
    }
    
    private var timer: Timer?
    
    private func updateInfo() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (_timer) in
            if let currentShift = self?.employer!.shifts!.allObjects.first! as! Shift? {
                let sinceLastPunch = Date().timeIntervalSince(currentShift.lastPunch!.timeStamp! as Date)
                self?.labelLastPunch.setText("\(String(sinceLastPunch)) ago")
                self?.labelSum.setText(String(currentShift.continuousOnTheClockDuration!))
            }
            
            // TODO: Invalidate yourself
        })
    }
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        // TODO: fetch selected employer saved on ios
        let fetch: NSFetchRequest<Employer> = Employer.fetchRequest()
        do {
            employer = try ExtensionDelegate.instanace.persistentContainer.viewContext.fetch(fetch).first!
        } catch {
            print(error.localizedDescription)
        }
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
