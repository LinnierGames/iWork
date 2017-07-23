//
//  ShiftTableViewController.swift
//  iWork
//
//  Created by Erick Sanchez on 7/11/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import UIKit
import CoreData

class ShiftViewController: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, DatePickerDelegate {

    
    var shift: Shift!
    
    var lastPunch: TimePunch? {
        return fetchedResultsController.fetchedObjects?.first
    }
    
    var fetchedResultsController: NSFetchedResultsController<TimePunch>! {
        didSet {
            if let controller = fetchedResultsController {
                do {
                    try controller.performFetch()
                    controller.delegate = self
                    tableView.reloadData()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var labelFifthHour: UILabel!
    @IBOutlet weak var labelLastPunch: UILabel!
    @IBOutlet weak var labelCaption: UILabel!
    @IBOutlet weak var labelSum: UILabel!
    @IBOutlet weak var textViewNotes: UITextView! {
        didSet {
            textViewNotes.text = shift.notes
            if shift.notes == "" || shift.notes == nil {
                labelNotes.isHidden = false
            } else {
                labelNotes.isHidden = true
            }
        }
    }
    @IBOutlet weak var labelNotes: UILabel!
    @IBAction func didTapToDimissKeyboard(_ sender: Any) {
        if textViewNotes.isFirstResponder {
            textViewNotes.resignFirstResponder()
        }
    }
    
    private var timer: Timer!
    
    // MARK: - RETURN VALUES
    
    // MARK: Table view data source
    
    // MARK: Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections?.count {
            return sections
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Punches"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var actions = [UITableViewRowAction(style: .normal, title: "Refresh", handler: { [weak self] (action, indexPath) in
            self!.fetchedResultsController.object(at: indexPath).timeStamp = NSDate()
            self!.appDelegate.saveContext()
        })]
        if fetchedResultsController.object(at: indexPath).punchType != .StartShift || fetchedResultsController.fetchedObjects!.count == 1 {
            actions.insert(UITableViewRowAction(style: .destructive, title: "Remove", handler: { [weak self] (action, indexPath) in
                let punch = self!.fetchedResultsController.object(at: indexPath)
                self!.container.viewContext.delete(punch)
                self!.updateNotifications(forDeletedPunch: punch)
                self!.appDelegate.saveContext()
                self!.updateInfo()
            }), at: 0)
        }
        
        return actions
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let punch = fetchedResultsController.object(at: indexPath)
        cell.textLabel!.text = String(describing: punch.punchType)
        let time = String(punch.timeStamp!, dateStyle: .none, timeStyle: .medium)
        if let duration = punch.duration {
            let stringTimeVariance = String(duration)
            let cellDetailText = NSMutableAttributedString(string: "\(time) was \(stringTimeVariance)")
            if duration >= TimeInterval(CTDateComponentHour*4+CTDateComponentMinute*30) { //4hours and 30minutes
                cellDetailText.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: NSRange(location: time.characters.count+5, length: stringTimeVariance.characters.count))
            }
            cell.detailTextLabel!.attributedText = cellDetailText
        } else {
            cell.detailTextLabel!.text = "\(time)"
        }
        
        return cell
    }
    
    // MARK: - VOID METHODS
    
    private func updateUI() {
        let fetch: NSFetchRequest<TimePunch> = TimePunch.fetchRequest()
        fetch.predicate = NSPredicate(format: "shift == %@", shift)
        fetch.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: false)]
        fetchedResultsController = NSFetchedResultsController<TimePunch>(
            fetchRequest: fetch,
            managedObjectContext: container.viewContext,
            sectionNameKeyPath: nil, cacheName: nil
        )
        buttonDate.setTitle(String(shift.date!, dateStyle: .full), for: .normal)
        updateInfo()
    }
    
    private func setSuggestedPunch() -> TimePunch.PunchType? {
        if let punches = shift.punches?.array as! [TimePunch]? {
            let hasFirstBreak = punches.contains(where: { $0.punchType == .StartBreak }),
            hasLunch = punches.contains(where: { $0.punchType == .StartLunch }),
            hasSecondBreak = punches.reduce(0) { $1.punchType == .StartBreak ? $0+1 : $0 } > 1,
            hasEndShift = punches.contains(where: { $0.punchType == .EndShift })
            
            if shift.lastPunch!.punchType == .StartBreak {
                return .EndBreak
            } else if shift.lastPunch!.punchType == .StartLunch {
                return .EndLunch
            } else if shift.lastPunch!.punchType == .EndShift {
                return nil
            } else {
                if hasFirstBreak {
                    if hasLunch {
                        if hasSecondBreak {
                            if hasEndShift {
                                return nil
                            } else {
                                return .EndShift
                            }
                        } else {
                            return .StartBreak
                        }
                    } else {
                        return .StartLunch
                    }
                } else {
                    return .StartBreak
                }
            }
        } else {
            return .StartShift
        }
    }
    
    private func updateInfo() {
        if let punch = lastPunch {
            if punch.punchType != .EndShift {
                let sum = Date().timeIntervalSince(punch.timeStamp! as Date)
                labelLastPunch.text = "Last Punch: \(String(describing: punch.punchType)), \(String(sum)) ago"
            } else {
                labelLastPunch.text = "Last Punch: End Shift"
            }
            if punch.punchType != .StartLunch, punch.punchType != .EndShift {
                let intervalTillFithHour = shift.fithHour!.timeIntervalSinceNow
                if intervalTillFithHour > 0 {
                    if intervalTillFithHour < CTDateComponentMinute*30 { //30minutes
                        labelFifthHour.textColor = UIColor.red
                    } else {
                        labelFifthHour.textColor = UIColor.black
                    }
                    labelFifthHour.text = "\(String(intervalTillFithHour)) left"
                    labelCaption.text = "until you hit a 5th hour at \(String(shift.fithHour!, dateStyle: .none, timeStyle: .long))"
                } else {
                    labelFifthHour.text = "You've worked over 5 hours"
                    labelCaption.text = nil
                }
            } else { //Starting a lunch or ended a shift
                labelFifthHour.text = "Currently off the Clock"
                labelCaption.text = nil
            }
            labelSum.text = "Sum: \(String(shift.continuousOnTheClockDuration!))"
            
            suggestedPunch = setSuggestedPunch()
        } else {
            labelFifthHour.text = "Add a Punch"
            labelCaption.text = nil
            labelLastPunch.text = "Last Punch:"
            labelSum.text = "Sum:"
            
            suggestedPunch = .StartShift
        }
    }
    
    ///nofications for the fifth hour
    private func updateNotifications(forAddedPunch insertPunch: TimePunch? = nil, forDeletedPunch deletePunch: TimePunch? = nil) {
        if let punch = insertPunch {
            if punch.punchType == .StartShift || punch.punchType == .EndLunch {
                AppDelegate.userNotificationCenter.getNotificationSettings { (setting) in
                    if setting.alertSetting == .enabled {
                        AppDelegate.userNotificationCenter.addLocalNotification(forPunch: punch)
                    }
                }
            } else if punch.punchType == .StartLunch || punch.punchType == .EndShift {
                AppDelegate.userNotificationCenter.removePendingFifthHourNotificationRequests()
            }
        } else if let punch = deletePunch {
            if punch.punchType == .StartLunch || punch.punchType == .EndShift {
                AppDelegate.userNotificationCenter.getNotificationSettings { [weak shift] (setting) in
                    if setting.alertSetting == .enabled {
                        AppDelegate.userNotificationCenter.addLocalNotification(forPunch: shift!.onTheClockPunch!)
                    }
                }
            } else if punch.punchType == .StartShift || punch.punchType == .EndLunch {
                AppDelegate.userNotificationCenter.removePendingFifthHourNotificationRequests()
            }
        } else {
            preconditionFailure("cannont have both punches set to nil to update the notification center")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "show date":
                let dateVC = (segue.destination as! UINavigationController).visibleViewController! as! DatePickerViewController
                let indexPath = tableView.indexPath(for: sender as! UITableViewCell)!
                dateVC.date = fetchedResultsController.object(at: indexPath).timeStamp! as Date
                dateVC.isTimeSet = true
                dateVC.delegate = self
            default:
                break
            }
        }
    }
    
    // MARK: Text View Delegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        labelNotes.isHidden = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        shift.notes = textView.text
        appDelegate.saveContext()
        
        if textView.text == "" {
            labelNotes.isHidden = false
        } else {
            labelNotes.isHidden = true
        }
    }
    
    // MARK: Date Picker Delegate
    
    func datePicker(_ picker: DatePickerViewController, didFinishWithDate date: Date?, withTimeInterval interval: TimeInterval?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let punch = fetchedResultsController.object(at: indexPath)
            punch.timeStamp = date! as NSDate
            appDelegate.saveContext()
        }
    }
        
    // MARK: - IBACTIONS
    
    private func insert(punch: TimePunch.PunchType) {
        let newPunch = TimePunch(punch: punch, inContext: container.viewContext, forShift: shift)
        shift.addToPunches(newPunch)
        appDelegate.saveContext()
        updateNotifications(forAddedPunch: newPunch)
        updateInfo()
    }
    
    @IBAction func pressAdd(_ sender: Any) {
        let alert = UIAlertController(title: "Adding a Punch", message: "select a punch type", preferredStyle: .actionSheet)
        if let punch = lastPunch {
            switch punch.punchType {
            case .StartShift, .EndBreak, .EndLunch:
                alert.addAction(UIAlertAction(title: "Start Break", style: .default, handler: { [weak self] (action) in
                    self!.insert(punch: .StartBreak)
                }))
                alert.addAction(UIAlertAction(title: "Start Lunch", style: .default, handler: { [weak self] (action) in
                    self!.insert(punch: .StartLunch)
                }))
                alert.addAction(UIAlertAction(title: "End Shift", style: .default, handler: { [weak self] (action) in
                    self!.insert(punch: .EndShift)
                }))
            case .StartBreak:
                alert.addAction(UIAlertAction(title: "End Break", style: .default, handler: { [weak self] (action) in
                    self!.insert(punch: .EndBreak)
                }))
            case .StartLunch:
                alert.addAction(UIAlertAction(title: "End Lunch", style: .default, handler: { [weak self] (action) in
                    self!.insert(punch: .EndLunch)
                }))
            case .EndShift:
                break
            }
        } else {
            alert.addAction(UIAlertAction(title: "Start Shift", style: .default, handler: { [weak self] (action) in
                self!.insert(punch: .StartShift)
            }))
        }
        alert.addAction(UIAlertAction(title: "Override", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBOutlet weak var buttonDate: UIButton!
    @IBAction func pressDate(_ sender: Any) {
        
    }
    
    @IBOutlet weak var buttonPunch: UIBarButtonItem!
    private var suggestedPunch: TimePunch.PunchType? = .StartShift {
        didSet {
            if let punch = suggestedPunch {
                buttonPunch.title = String(punch)
            } else {
                buttonPunch.title = nil
            }
        }
    }
    @IBAction func pressPunch(_ sender: Any) {
        if let punch = suggestedPunch {
            insert(punch: punch)
        }
    }
    
    // MARK: - LIFE CYCLE

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.setEditing(true, animated: false)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (timer) in
            self!.updateInfo()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        AppDelegate.userNotificationCenter.getPendingNotificationRequests(completionHandler: { (notes) in
            for note in notes {
                print(note)
            }
        })
    }
}

extension ShiftViewController {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert: tableView.insertSections([sectionIndex], with: .fade)
        case .delete: tableView.deleteSections([sectionIndex], with: .fade)
        default: break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
