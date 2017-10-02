//
//  TaskManagerTableViewController.swift
//  iWork
//
//  Created by Erick Sanchez on 7/1/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import UIKit
import CoreData

class TaskManagerTableViewController: FetchedResultsTableViewController {
    
    // MARK: - RETURN VALUES
    
    // MARK: Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "task", for: indexPath)
        
        let row = fetchedResultsController.task(at: indexPath)
        
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
        fetch.predicate = NSPredicate(format: "directory.role == %@ AND isCompleted == FALSE AND (%@ <= dueDate) AND (dueDate < %@) OR (%@ <= startDate) AND (startDate < %@)", appDelegate.currentRole, dateFrom as NSDate, dateTo as NSDate, dateFrom as NSDate, dateTo as NSDate)
        fetch.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true), NSSortDescriptor(key: "dueDate", ascending: true), CTSortDescriptor(key: "title")]
        
        fetchedResultsController = NSFetchedResultsController<NSManagedObject>(
            fetchRequest: fetch as! NSFetchRequest<NSManagedObject>,
            managedObjectContext: container.viewContext,
            sectionNameKeyPath: nil, cacheName: nil
        )
        
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
    
    // MARK: - IBACTIONS
    
    @IBAction func pressAdd(_ sender: Any) {
        performSegue(withIdentifier: "show task", sender: nil)
    }
    
    // MARK: - LIFE CYCLE

    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveHandler = appDelegate.saveContext
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear( animated)
        
        self.navigationItem.title = appDelegate.currentRole.title
        
        updateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
