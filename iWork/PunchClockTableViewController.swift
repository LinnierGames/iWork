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
    
    private var fetchedResultsController: NSFetchedResultsController<Shift>! {
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
    
    // MARK: - RETURN VALUES
    
    // MARK: Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections?.count {
            return sections
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let shift = fetchedResultsController!.object(at: indexPath)
        cell.textLabel!.text = String(shift.date!, dateStyle: .full)
        if shift.isCompletedShift ?? false {
            cell.detailTextLabel!.text = String(shift.onTheClockDuration!)
        } else {
            if shift.punches!.count > 0 {
                cell.detailTextLabel!.textColor = UIColor.blue
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak cell, weak shift] (timer) in
                    if let lastPunch = shift?.lastPunch! {
                        if let duration = lastPunch.duration {
                            cell?.detailTextLabel!.text = "\(String(shift!.continuousOnTheClockDuration!)) - last punch: \(lastPunch.punchType) for \(String(duration))"
                        } else {
                            cell?.detailTextLabel!.text = "\(String(shift!.continuousOnTheClockDuration!)) - last punch: \(lastPunch.punchType)"
                        }
                    } else {
                        timer.invalidate()
                    }
                })
            } else {
                cell.detailTextLabel!.text = "No recorded punches"
            }
        }
        
        return cell
    }
    
    // MARK: - VOID METHODS
    
    private func updateUI() {
        let fetch: NSFetchRequest<Shift> = Shift.fetchRequest()
        fetch.predicate = NSPredicate(format: "employer == %@", appDelegate.currentEmployer)
        fetch.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchedResultsController = NSFetchedResultsController<Shift>(
            fetchRequest: fetch,
            managedObjectContext: container.viewContext,
            sectionNameKeyPath: nil, cacheName: nil
        )
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
        _ = Shift(inContext: container.viewContext, forEmployer: appDelegate.currentEmployer)
        appDelegate.saveContext()
    }
    
    // MARK: - LIFE CYCLE

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = true
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.title = appDelegate.currentEmployer.name
        updateUI()
    }
}
