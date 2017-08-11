//
//  PunchClockController.swift
//  iWork
//
//  Created by Erick Sanchez on 7/16/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import UIKit
import WatchKit
import WatchConnectivity

class PunchClockController: WKInterfaceController, WCSessionDelegate {
    
    private var delegate: WCSession!

    @IBOutlet var tableView: WKInterfaceTable?
    
    @IBOutlet var labelTimeLeft: WKInterfaceLabel!
    @IBOutlet var labelLastPunch: WKInterfaceLabel!
    @IBOutlet var labelLastPunchTitle: WKInterfaceLabel!
    @IBOutlet var labelSum: WKInterfaceLabel!
    
    @IBOutlet var labelDebug: WKInterfaceLabel?
    
    var shift: Shift? {
        didSet {
            if shift != nil {
                updateUI()
            }
        }
    }
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    private func updateUI() {
        if let currentShift = shift {
            if let lastPunch = currentShift.lastPunch {
                switch lastPunch.punchType {
                case .StartShift, .EndBreak, .EndLunch:
                    self.addMenuItem(with: .add, title: "SB", action: #selector(punchSB))
                default:
                    break
                }
            } else {
                labelDebug?.setText("No punches found")
            }
        } else {
            labelDebug?.setText("No shift was found")
        }
    }
    
    private func updateTimers() {
        if let currentShift = shift {
            
        }
    }
    
    @objc private func punchSB() {
        labelDebug?.setText("Start Break")
    }
    
    // MARK: WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        switch activationState {
        case .activated:
            labelDebug?.setText("activated")
        case .notActivated:
            labelDebug?.setText("notActivated")
        case .inactive:
            labelDebug?.setText("inactive")
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        labelDebug?.setText("sessionReachabilityDidChange")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let object1 = message["object1"] {
            labelDebug!.setText(object1 as? String)
        } else {
            labelDebug!.setText("m:nothing to parse")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        labelDebug!.setText("s:messageData:")
        if let payload = NSKeyedUnarchiver.unarchiveObject(with: messageData) {
            labelDebug!.setText("unarchiveObject")
            if let payloadShift = payload as? Shift {
                labelDebug!.setText("payloadShift")
                shift = payloadShift
                updateUI()
            } else {
                labelDebug!.setText("payloadShift failed")
            }
        } else {
            labelDebug!.setText("payload failed")
        }
    }
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        delegate = WCSession.default()
        delegate.delegate = self
        delegate.activate()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        updateUI()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}
