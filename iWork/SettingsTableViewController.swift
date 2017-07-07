//
//  SettingsTableViewController.swift
//  iWork
//
//  Created by Erick Sanchez on 7/4/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import UIKit
import CoreData

fileprivate enum CDSettingsHierarchy {
    case root
    case employers
}

class SettingsTableViewController: FetchedResultsTableViewController {
    
    fileprivate var hierarchy: CDSettingsHierarchy = .root
    
    var array: [Any]!
    
    // MARK: - RETURN VALUES
    
    // MARK: Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        switch hierarchy {
        case .root, .employers:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch hierarchy {
        case .root:
            return "Select an Employer"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch hierarchy {
        case .root:
            return 1
        case .employers:
            return fetchedResultsController.sections![section].numberOfObjects
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch hierarchy {
        case .employers:
            return (fetchedResultsController.object(at: indexPath).objectID != appDelegate.currentEmployer.objectID)
        default:
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        func returnCell(forIdentifier identifier: String = "title") -> UITableViewCell {
            return tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        }
        switch hierarchy {
        case .root:
            let cell = returnCell()
            cell.textLabel!.text = appDelegate.currentEmployer.name
            cell.accessoryType = .disclosureIndicator
            
            return cell
        case .employers:
            let cell = returnCell(forIdentifier: "subtitle")
            let employer = fetchedResultsController.object(at: indexPath) as! Employer
            cell.textLabel!.text = String("\(employer.name!) - \(employer.selectedRole!.title!)")
            cell.detailTextLabel!.text = String("Number of Roles: \(employer.roles?.count ?? 0)")
            if employer.objectID == appDelegate.currentEmployer.objectID {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            return cell
        }
    }
    
    // MARK: - VOID METHODS
    
    private var reloadIndexesOnViewDidAppear: [IndexPath]?
    
    private var fetchedResultsController: NSFetchedResultsController<NSManagedObject>! {
        didSet {
            if fetchedResultsController != nil {
                do {
                    try fetchedResultsController.performFetch()
                    fetchedResultsController.delegate = self
                    tableView.reloadData()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func updateTable() {
        switch hierarchy {
        case .root:
            break
        case .employers:
            let fetch: NSFetchRequest<Employer> = Employer.fetchRequest()
            fetch.sortDescriptors = CTSortDescriptor(key: "name")
            fetchedResultsController = NSFetchedResultsController<NSManagedObject>(fetchRequest: fetch as! NSFetchRequest<NSManagedObject>, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        }
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch hierarchy {
        case .root:
            let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "settingsVC") as! SettingsTableViewController
            vc.hierarchy = .employers
            self.navigationController?.pushViewController(vc, animated: true)
            
            reloadIndexesOnViewDidAppear = [indexPath]
        case .employers:
            let row = fetchedResultsController.object(at: indexPath) as! Employer
            appDelegate.currentEmployer = row
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let row = fetchedResultsController.object(at: indexPath)
            container.viewContext.delete(row)
            appDelegate.saveContext()
        default:
            break
        }
    }
    
    // MARK: - IBACTIONS
    
    internal func pressRightNav(_ sender: Any) {
        let alert = UIAlertController(title: "New Employer", message: "enter a title", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.setStyleToParagraph()
        }
        alert.addAction(UIAlertAction(title: "Discard", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] (action) in
            _ = Employer(name: alert.inputField.text!, inContext: self!.container.viewContext)
            self!.appDelegate.saveContext()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - LIFE CYCLE

    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch hierarchy {
        case .root:
            break
        case .employers:
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(pressRightNav(_:)))
        }
        
        updateTable()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let indexesToReload = reloadIndexesOnViewDidAppear {
            tableView.reloadRows(at: indexesToReload, with: .fade)
            reloadIndexesOnViewDidAppear = nil
        }
    }
}
