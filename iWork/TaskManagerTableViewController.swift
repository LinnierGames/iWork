//
//  TaskManagerTableViewController.swift
//  iWork
//
//  Created by Erick Sanchez on 7/1/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import UIKit
import CoreData

class TaskManagerTableViewController: UITableViewController {
    
    private var fetchedResultsController: NSFetchedResultsController<Task>? {
        didSet {
            if let controller = fetchedResultsController {
                // controller.delegate = self
                do {
                    try controller.performFetch()
                } catch {
                    print(error.localizedDescription)
                }
                
                tableView.reloadData()
            }
        }
    }
    
    // MARK: - RETURN VALUES
    
    // MARK: Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchedResultsController?.sections?.count {
            return sections
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "task", for: indexPath)
        
        let row = fetchedResultsController!.object(at: indexPath)
        
        cell.textLabel!.text = row.title
        
        return cell
    }
    
    // MARK: - VOID METHODS
    
    private func updateUI() {// Get the current calendar with local time zone
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        
        // Get today's beginning & end
        let dateFrom = calendar.startOfDay(for: Date())
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute],from: dateFrom)
        components.day! += 1
        let dateTo = calendar.date(from: components)!
        
        let fetch: NSFetchRequest<Task> = Task.fetchRequest()
        fetch.predicate = NSPredicate(format: "directory.role == %@ AND isCompleted == FALSE AND (%@ <= dueDate) AND (dueDate < %@)", appDelegate.currentRole, dateFrom as NSDate, dateTo as NSDate)
        fetch.sortDescriptors = [NSSortDescriptor(key: "dueDate", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController<Task>(
            fetchRequest: fetch,
            managedObjectContext: container.viewContext,
            sectionNameKeyPath: nil, cacheName: nil
        )
        
    }
    
    private func prompt<T>(type:T.Type, withTitle promptTitle: String?, message promptMessage: String = "enter a title", willComplete: @escaping (T) -> Void = {_ in }, didComplete: @escaping (T) -> Void = {_ in }) {
        let alert = UIAlertController(title: promptTitle, message: promptMessage, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.setStyleToParagraph(withPlacehodlerText: nil, withInitalText: nil)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] (action) in
            let context = self!.container.viewContext
            let newClass: DirectoryInfo
            if type is Folder.Type {
                newClass = Folder(context: context)
            } else if type is Task.Type {
                newClass = Task(context: context)
            } else {
                newClass = DirectoryInfo(context: context)
            }
            newClass.title = alert.inputField.text
            
            willComplete(newClass as! T)
            
            _ = Directory.createDirectory(forDirectoryInfo: newClass, withParent: nil, in: context, forRole: self!.appDelegate.currentRole)
            
            self!.appDelegate.saveContext()
            
            didComplete(newClass as! T)
            
            self!.updateUI()
        }))
        
        self.present( alert, animated: true, completion: nil)
        
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "show oraganizer":
                let organizeVC = segue.destination as! OrganizeTableTableViewController
                organizeVC.currentDirectory = nil
            case "show task":
                let taskNC = segue.destination as! TaskNavigationController
                taskNC.task = sender as? Task
            default:
                break
            }
        }
    }
    
    // MARK: Table view
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "show task", sender: fetchedResultsController!.object(at: indexPath))
    }
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    // MARK: - IBACTIONS
    
    @IBAction func pressAdd(_ sender: Any) {
        performSegue(withIdentifier: "show task", sender: nil)
    }
    
    // MARK: - LIFE CYCLE

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear( animated)
        
        self.title = appDelegate.currentRole.title
        
        updateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
