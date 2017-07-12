//
//  ShiftTableViewController.swift
//  iWork
//
//  Created by Erick Sanchez on 7/11/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import UIKit
import CoreData

class ShiftViewController: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
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
            if shift.notes == "" {
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
                self!.container.viewContext.delete(self!.fetchedResultsController.object(at: indexPath))
                self!.appDelegate.saveContext()
            }), at: 0)
        }
        
        return actions
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let punch = fetchedResultsController.object(at: indexPath)
        cell.textLabel!.text = String(describing: punch.punchType)
        let time = String(punch.timeStamp!, dateStyle: .none, timeStyle: .medium)
        let nPunches = fetchedResultsController.fetchedObjects!.count
        if  nPunches > 1, indexPath.row != nPunches-1 {
            let perviousIndexPath = IndexPath(row: indexPath.row+1, section: indexPath.section)
            let perviousPunch = fetchedResultsController.object(at: perviousIndexPath)
            let intervalTimeVariance = punch.timeStamp!.timeIntervalSince(perviousPunch.timeStamp! as Date)
            let stringTimeVariance = String(intervalTimeVariance)
            let cellDetailText = NSMutableAttributedString(string: "\(time) was \(stringTimeVariance) long")
            if intervalTimeVariance >= CTDateComponentHour*4+CTDateComponentMinute*30 { //4hours and 30minutes
                cellDetailText.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: NSRange(location: time.characters.count+5, length: stringTimeVariance.characters.count+5))
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
    
    private func updateInfo() {
        if let punch = lastPunch {
            if punch.punchType != .EndShift {
                let sum = Date().timeIntervalSince(punch.timeStamp! as Date)
                labelLastPunch.text = "Last Punch: \(String(describing: punch.punchType)) was \(String(sum)) ago"
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
                    labelCaption.text = "until you hit a 5th hour"
                } else {
                    labelFifthHour.text = "You've worked over 5 hours"
                    labelCaption.text = nil
                }
            } else {
                labelFifthHour.text = "Currently off the Clock"
                labelCaption.text = nil
            }
            labelSum.text = "Sum: \(String(shift.continuousOnTheClockDuration!))"
            
//            if punch.punchType == .EndShift {
//                timer.invalidate()
//            }
        } else {
            labelFifthHour.text = "Add a Punch"
            labelCaption.text = nil
            labelLastPunch.text = "Last Punch:"
            labelSum.text = "Sum:"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    // MARK: Table View Delegate
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            container.viewContext.delete(fetchedResultsController.object(at: indexPath))
            appDelegate.saveContext()
        default:
            break
        }
    }
    
    // MARK: - IBACTIONS
    @IBAction func pressAdd(_ sender: Any) {
        let alert = UIAlertController(title: "Adding a Punch", message: "select a punch type", preferredStyle: .actionSheet)
        
        func insert(punch: TimePunch.PunchType) {
            let newPunch = TimePunch(punch: punch, inContext: container.viewContext, forShift: shift)
            shift.addToPunches(newPunch)
            appDelegate.saveContext()
        }
        if let punch = lastPunch {
            switch punch.punchType {
            case .StartShift, .EndBreak, .EndLunch:
                alert.addAction(UIAlertAction(title: "Start Break", style: .default, handler: { (action) in
                    insert(punch: .StartBreak)
                }))
                alert.addAction(UIAlertAction(title: "Start Lunch", style: .default, handler: { (action) in
                    insert(punch: .StartLunch)
                }))
                alert.addAction(UIAlertAction(title: "End Shift", style: .default, handler: { (action) in
                    insert(punch: .EndShift)
                }))
            case .StartBreak:
                alert.addAction(UIAlertAction(title: "End Break", style: .default, handler: { (action) in
                    insert(punch: .EndBreak)
                }))
            case .StartLunch:
                alert.addAction(UIAlertAction(title: "End Lunch", style: .default, handler: { (action) in
                    insert(punch: .EndLunch)
                }))
            case .EndShift:
                break
            }
        } else {
            alert.addAction(UIAlertAction(title: "Start Shift", style: .default, handler: { (action) in
                insert(punch: .StartShift)
            }))
        }
        alert.addAction(UIAlertAction(title: "Override", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBOutlet weak var buttonDate: UIButton!
    @IBAction func pressDate(_ sender: Any) {
        
    }
    
    // MARK: - LIFE CYCLE

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.setEditing(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (timer) in
            self!.updateInfo()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
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
