//
//  InboxTableViewController.swift
//  iWork
//
//  Created by Erick Sanchez on 7/6/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import UIKit
import CoreData

class InboxTableViewController: FetchedResultsTableViewController {

    // MARK: - RETURN VALUES
    
    // MARK: Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let task = fetchedResultsController.task(at: indexPath)
        cell.textLabel!.text = task.title
        
        return cell
    }
    
    // MARK: - VOID METHODS
    
    private func updateUI() {
        let fetch: NSFetchRequest<Task> = Task.fetchRequest()
        fetch.predicate = NSPredicate(format: "directory.parent = nil AND directory.role == %@", AppDelegate.sharedInstance.currentRole)
        fetch.sortDescriptors = [CTSortDescriptor(key: "title")]
        fetchedResultsController = NSFetchedResultsController<NSManagedObject>(
            fetchRequest: fetch as! NSFetchRequest<NSManagedObject>,
            managedObjectContext: AppDelegate.viewContext,
            sectionNameKeyPath: nil, cacheName: nil
        )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "show task":
                let taskNC = segue.destination as! TaskNavigationController
                let task: Task?
                if let cell = sender as? UITableViewCell { //Detail a task
                    task = fetchedResultsController.task(at: tableView.indexPath(for: cell)!)
                } else { //sender was buttonAdd, thus create a new task
                    task = nil
                }
                taskNC.task = task
            default:
                break
            }
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        buttonAddItem.isEnabled = editing.inverse
        self.navigationItem.leftBarButtonItem!.isEnabled = editing.inverse
    }
    
    // MARK: Table View Delegate
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var buttonAddItem: UIBarButtonItem!
    @IBAction func pressAdd(_ sender: Any) {
    }
    
    @IBAction func pressDone(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        updateUI()
        
        saveHandler = AppDelegate.sharedInstance.saveContext
    }
}
