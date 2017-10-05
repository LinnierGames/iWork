//
//  PunchClockTableViewController.swift
//  iWork
//
//  Created by Erick Sanchez on 7/11/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import UIKit
import CoreData

class PunchClockTableViewController: FetchedResultsTableViewController {
    
    // MARK: - RETURN VALUES
    
    // MARK: Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let shift = fetchedResultsController.shift(at: IndexPath(row: 0, section: section))
        var weekSum: TimeInterval = 0
        if let shifts = fetchedResultsController.sections?[section].objects as! [Shift]? {
            for shift in shifts {
                if let duration = shift.onTheClockDuration {
                    weekSum += duration
                } else {
                    weekSum += 0
                }
            }
        } else {
            weekSum = 0
        }
        
        return "Week \(shift.week): \(String(weekSum))"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.returnCell(atIndexPath: indexPath)
        
        let shift = fetchedResultsController.shift(at: indexPath)
        cell.textLabel!.text = String(shift.date!, dateStyle: .full)
        cell.accessoryType = .detailDisclosureButton
        if shift.isCompletedShift ?? false {
            cell.detailTextLabel!.text = "Sum: \(String(shift.onTheClockDuration!))"
        } else {
            if shift.punches!.count > 0 {
                cell.detailTextLabel!.text = "Loading"
                cell.detailTextLabel!.textColor = UIColor.blue
                let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak cell, weak shift] (timer) in
                    if let lastPunch = shift?.lastPunch {
                        if shift!.isCompletedShift! {
                            timer.invalidate()
                        } else {
                            cell?.detailTextLabel!.text = "Sum: \(String(shift!.continuousOnTheClockDuration!)) last punch: \(lastPunch.punchType)"
                        }
                    } else {
                        timer.invalidate()
                    }
                })
                timer.fire()
            } else {
                cell.detailTextLabel!.text = "No recorded punches"
            }
        }
        
        return cell
    }
    
    // MARK: - VOID METHODS
    
    private func updateUI() {
        let fetch: NSFetchRequest<Shift> = Shift.fetchRequest()
        fetch.predicate = NSPredicate(format: "employer == %@", AppDelegate.sharedInstance.currentEmployer)
        fetch.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchedResultsController = NSFetchedResultsController<NSManagedObject>(
            fetchRequest: fetch as! NSFetchRequest<NSManagedObject>,
            managedObjectContext: AppDelegate.viewContext,
            sectionNameKeyPath: "week", cacheName: nil
        )
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        buttonAdd.isEnabled = editing.inverse
        self.navigationItem.setHidesBackButton(editing, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "show shift":
                let shiftVC = segue.destination as! ShiftViewController
                shiftVC.shift = sender as! Shift
            default:
                break
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "show shift", sender: fetchedResultsController.object(at: indexPath))
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var buttonAdd: UIBarButtonItem!
    @IBAction func pressAdd(_ sender: Any) {
        _ = Shift(inContext: AppDelegate.viewContext, forEmployer: AppDelegate.sharedInstance.currentEmployer)
        AppDelegate.sharedInstance.saveContext()
    }
    
    // MARK: - LIFE CYCLE

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = true
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.title = AppDelegate.sharedInstance.currentEmployer.name
        updateUI()
        
        saveHandler = AppDelegate.sharedInstance.saveContext
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AppDelegate.userNotificationCenter.requestAuthorization(options: [.alert, .sound], completionHandler: { _ in })
    }
}
