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
    
    private var appDelegate: AppDelegate {
        return (UIApplication.shared.delegate as! AppDelegate)
    }
    
    private var container: NSPersistentContainer {
        return appDelegate.persistentContainer
    }
    
    private var fetchedResultsController: NSFetchedResultsController<Directory>? {
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
        
        cell.textLabel!.text = row.info!.title
        cell.detailTextLabel!.text = String(describing: row)
        
        return cell
    }
    
    // MARK: - VOID METHODS
    
    private func updateUI() {
        let fetch: NSFetchRequest<Directory> = Directory.fetchRequest()
        fetch.predicate = NSPredicate(format: "parent = nil")
        fetch.sortDescriptors = [NSSortDescriptor(key: "info.title", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController<Directory>(
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
            
            _ = Directory.createDirectory(forDirectoryInfo: newClass, withParent: nil, in: context)
            
            self!.appDelegate.saveContext()
            
            didComplete(newClass as! T)
            
            self!.updateUI()
        }))
        
        self.present( alert, animated: true, completion: nil)
        
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    // MARK: Table view data source
    
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
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Folder", style: .default, handler: { [weak self] (action) in
            self!.prompt(type: Folder.self, withTitle: "New Folder")
        }))
        alert.addAction(UIAlertAction(title: "Task", style: .default, handler: { [weak self] (action) in
            self!.prompt(type: Task.self, withTitle: "New Folder", willComplete: { (task) in
                task.dateCreated = NSDate()
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - LIFE CYCLE

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
