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
        let cell = tableView.returnCell(atIndexPath: indexPath)
        
        let shift = fetchedResultsController!.object(at: indexPath)
        cell.textLabel!.text = String(shift.date!, dateStyle: .full)
        cell.accessoryType = .detailDisclosureButton
        if shift.isCompletedShift ?? false {
            cell.detailTextLabel!.text = "Sum: \(String(shift.onTheClockDuration!))"
        } else {
            if shift.punches!.count > 0 {
                cell.detailTextLabel!.text = "Loading"
                cell.detailTextLabel!.textColor = UIColor.blue
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak cell, weak shift] (timer) in
                    if let lastPunch = shift?.lastPunch {
                        if shift!.isCompletedShift! {
                            timer.invalidate()
                        } else {
                            if let duration = lastPunch.duration {
                                cell?.detailTextLabel!.text = "Sum: \(String(shift!.continuousOnTheClockDuration!)) last punch: \(lastPunch.punchType) for \(String(duration))"
                            } else {
                                cell?.detailTextLabel!.text = "Sum: \(String(shift!.continuousOnTheClockDuration!)) last punch: \(lastPunch.punchType)"
                            }
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
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func exportDatabase() {
        let exportString = createExportString()
        saveAndExport(exportString: exportString)
    }
    
    func saveAndExport(exportString: String) {
        let exportFilePath = NSTemporaryDirectory() + "itemlist.csv"
        let exportFileURL = NSURL(fileURLWithPath: exportFilePath)
        FileManager.default.createFile(atPath: exportFilePath, contents: NSData() as Data, attributes: nil)
        var fileHandle: FileHandle? = nil
        do {
            fileHandle = try FileHandle(forWritingTo: exportFileURL as URL)
        } catch {
            print("Error with fileHandle")
        }
        
        if fileHandle != nil {
            fileHandle!.seekToEndOfFile()
            let csvData = exportString.data(using: String.Encoding.utf8, allowLossyConversion: false)
            fileHandle!.write(csvData!)
            
            fileHandle!.closeFile()
            
            let firstActivityItem = NSURL(fileURLWithPath: exportFilePath)
            let activityViewController : UIActivityViewController = UIActivityViewController(
                activityItems: [firstActivityItem], applicationActivities: nil)
            
            activityViewController.excludedActivityTypes = [
                UIActivityType.assignToContact,
                UIActivityType.saveToCameraRoll,
                UIActivityType.postToFlickr,
                UIActivityType.postToVimeo,
                UIActivityType.postToTencentWeibo
            ]
            
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func createExportString() -> String {
        var export: String = ""
        for shift in appDelegate.currentEmployer.shifts?.allObjects as! [Shift] {
            let stringDate = String(shift.date!).replacingOccurrences(of: ",", with: "")
            let stringNotes = shift.notes?.replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: ",", with: ";") ?? "No Notes"
            export += "\(stringDate),\(stringNotes) \n"
            for punch in shift.punches?.array as! [TimePunch] {
                let stringPunchType = String(punch.punchType)
                let stringPunchTime = String(punch.timeStamp!, dateStyle: .none, timeStyle: .long)
                export += ", \(stringPunchType),\(stringPunchTime) \n"
            }
        }
        print("This is what the app will export: \(export)")
        return export
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        exportDatabase()
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AppDelegate.userNotificationCenter.requestAuthorization(options: [.alert, .sound], completionHandler: { _ in })
    }
}
