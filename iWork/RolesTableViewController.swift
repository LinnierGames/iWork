//
//  RolesTableViewController.swift
//  iWork
//
//  Created by Erick Sanchez on 7/2/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import UIKit
import CoreData

class RolesTableViewController: FetchedResultsTableViewController {
    
    private var fetchedResultsController: NSFetchedResultsController<Role>? {
        didSet {
            if let controller = fetchedResultsController {
                controller.delegate = self
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
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return (appDelegate.currentRole != fetchedResultsController!.object(at: indexPath))
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let role = fetchedResultsController!.object(at: indexPath)
        
        cell.textLabel!.text = role.title
        
        if appDelegate.currentRole == role {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    // MARK: - VOID METHODS
    
    private func updateUI() {
        let fetch: NSFetchRequest<Role> = Role.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController<Role>(
            fetchRequest: fetch,
            managedObjectContext: container.viewContext,
            sectionNameKeyPath: nil, cacheName: nil
        )
        
    }
    
    private func rename(role: Role) {
        let alert = UIAlertController(title: "Edit Role", message: "enter a title", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.setStyleToParagraph(withPlacehodlerText: nil, withInitalText: role.title)
        }
        alert.addAction(UIAlertAction(title: "Discard", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] (action) in
            role.title = alert.inputField.text
            self!.appDelegate.saveContext()
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing( editing, animated: animated)
        if editing {
            self.navigationItem.prompt = "switch roles to delete the selected role"
        } else {
            self.navigationItem.prompt = nil
        }
    }
    
    // MARK: Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        appDelegate.currentRole = fetchedResultsController!.object(at: indexPath)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        rename(role: fetchedResultsController!.object(at: indexPath))
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            container.viewContext.delete(fetchedResultsController!.object(at: indexPath))
            appDelegate.saveContext()
        default:
            break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBACTIONS
    @IBAction func pressAdd(_ sender: Any) {
        let alert = UIAlertController(title: "New Role", message: "enter a title", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.setStyleToParagraph(withPlacehodlerText: nil, withInitalText: nil)
        }
        alert.addAction(UIAlertAction(title: "Discard", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] (action) in
            let newRole = Role(context: self!.container.viewContext)
            newRole.title = alert.inputField.text
            
            self!.appDelegate.saveContext()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func pressRename(_ sender: Any) {
        rename(role: appDelegate.currentRole)
    }
    
    @IBAction func pressCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - LIFE CYCLE

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        updateUI()
    }
}
