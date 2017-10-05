//
//  OrganizeTableTableViewController.swift
//  Assigned - iOS
//
//  Created by Erick Sanchez on 6/23/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import UIKit
import CoreData

class OrganizeTableTableViewController: FetchedResultsTableViewController, MoveTableViewControllerDelegate {
    
    private var selectedRowItems: [NSManagedObject] = [NSManagedObject]() {
        didSet {
            if selectedRowItems.count > 0 {
                navigationItem.rightBarButtonItem!.title = "Next"
            } else {
                navigationItem.rightBarButtonItem!.title = "Done"
            }
        }
    }
    
    open var currentDirectory: Directory? { didSet { updateUI() } }
    
    // MARK: - RETURN VALUES
    
    // MARK: Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return currentDirectory?.info!.title ?? "Top"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if currentDirectory == nil {
            let folder = fetchedResultsController.object(at: indexPath) as! Folder
            cell.textLabel!.text = folder.title
            cell.accessoryType = .detailDisclosureButton
        } else {
            let directory = fetchedResultsController.object(at: indexPath) as! Directory
            cell.textLabel!.text = directory.info!.title
            
            if directory.isDirectory {
                cell.accessoryType = .detailDisclosureButton
            } else {
                cell.accessoryType = .detailButton
            }
        }
        
        return cell
    }
    
    // MARK: - VOID METHODS
    
    private func updateUI() {
        let request: NSFetchRequest<NSFetchRequestResult>
        let currentRole = AppDelegate.sharedInstance.currentRole
        if currentDirectory == nil {
            request = Folder.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "directory.info.title", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
            request.predicate = NSPredicate(format: "directory.role == %@ AND directory.parent = nil", currentRole)
        } else {
            request = Directory.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "info.title", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
            if let hierarchy = currentDirectory {
                request.predicate = NSPredicate(format: "role == %@ AND parent == %@", currentRole, hierarchy)
            } else {
                request.predicate = NSPredicate(format: "role == %@ AND parent = nil", currentRole)
            }
        }
        fetchedResultsController = NSFetchedResultsController<NSManagedObject>(
            fetchRequest: request as! NSFetchRequest<NSManagedObject>,
            managedObjectContext: AppDelegate.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
    
    private func prompt<T>(type:T.Type, withTitle promptTitle: String?, message promptMessage: String = "enter a title", willComplete: @escaping (T) -> Void = {_ in }, didComplete: @escaping (T) -> Void = {_ in }) {
        let alert = UIAlertController(title: promptTitle, message: promptMessage, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.setStyleToParagraph()
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] (action) in
            let newClass: DirectoryInfo
            let context = AppDelegate.viewContext
            let text = alert.inputField.text!
            let parent = self!.currentDirectory
            let role = AppDelegate.sharedInstance.currentRole
            
            if type is Folder.Type {
                newClass = Folder(title: text, parent: parent, inContext: context, forRole: role)
            } else if type is Project.Type {
                newClass = Project(titleProject: text, parent: parent, inContext: context, forRole: role)
            } else {
                newClass = DirectoryInfo(context: context)
            }
            newClass.title = alert.inputField.text
            
            willComplete(newClass as! T)
            
            AppDelegate.sharedInstance.saveContext()
            
            didComplete(newClass as! T)
        }))
        
        self.present( alert, animated: true, completion: nil)
        
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
            case "show task":
                let taskNC = segue.destination as! TaskNavigationController
                taskNC.task = sender as? Task
                taskNC.parentDirectory = currentDirectory
            case "show move":
                let moveNC = segue.destination as! MoveNavigationController
                if currentDirectory == nil {
                    moveNC.itemsToBeMoved = selectedRowItems.map { ($0 as! Folder).directory! }
                } else {
                    moveNC.itemsToBeMoved = (selectedRowItems as! [Directory])
                }
                moveNC.parentDelegate = self
            default:
                break
            }
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        if (navigationItem.rightBarButtonItem!.title == "Next") {
            self.performSegue(withIdentifier: "show move", sender: nil)
        } else {
            super.setEditing(editing, animated: animated)
            
            buttonAddItem.isEnabled = editing.inverse
            self.navigationItem.leftBarButtonItem?.isEnabled = editing.inverse
            self.navigationItem.setHidesBackButton(editing, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Table view
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            selectedRowItems.append(fetchedResultsController.object(at: indexPath))
        } else {
            if currentDirectory == nil {
                let folder = fetchedResultsController.object(at: indexPath) as! Folder
                let vc = UIStoryboard(name: "TaskManager", bundle: Bundle.main).instantiateViewController(withIdentifier: "organize table") as! OrganizeTableTableViewController
                vc.currentDirectory = folder.directory!
                self.navigationController?.pushViewController( vc, animated: true)
            } else {
                let row = fetchedResultsController.object(at: indexPath) as! Directory
                if row.isDirectory {
                    let vc = UIStoryboard(name: "TaskManager", bundle: Bundle.main).instantiateViewController(withIdentifier: "organize table") as! OrganizeTableTableViewController
                    vc.currentDirectory = row
                    
                    self.navigationController?.pushViewController( vc, animated: true)
                } else if row.info! is Task {
                    self.performSegue(withIdentifier: "show task", sender: row.info!)
                    
                } else {
                    assertionFailure("tableView:didSelectRowAt: -- failed to cast the selected object from row")
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let row = fetchedResultsController.object(at: indexPath)
        if tableView.isEditing {
            if let index = selectedRowItems.index(of: row) {
                selectedRowItems.remove(at: index)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        // TODO: CRUD Folders and Projects
    }
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    // MARK: Move Table View Delegate
    
    func controller(moveTableView: MoveTableViewController, didCompleteWithParentDestination: Directory?) {
        selectedRowItems.removeAll()
        setEditing(false, animated: true)
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var buttonAddItem: UIBarButtonItem!
    @IBAction func pressAddItem(_ sender: Any) {
        
        // Only tasks can be inside a project
        if currentDirectory?.info! is Project {
            self.performSegue(withIdentifier: "show task", sender: nil)
            
        } else { //Top or not inside another project
            let actionType = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            // A folder can be in root or inside another project
            actionType.addAction( UIAlertAction(title: "Folder", style: .default, handler: { [weak self] (action) in
                self!.prompt(type: Folder.self, withTitle: "New Folder")
            }))
            
            // A task/project can be inside anywhere but not in root
            let addingProjectTitle = currentDirectory == nil ? "Inbox Project" : "Project"
            actionType.addAction( UIAlertAction(title: addingProjectTitle, style: .default, handler: { [weak self] (action) in
                self!.prompt(type: Project.self, withTitle: "New Project")
            }))
            
            let addingTaskTitle = currentDirectory == nil ? "Inbox Task" : "Task"
            actionType.addAction( UIAlertAction(title: addingTaskTitle, style: .default, handler: { [weak self] (action) in
                self!.performSegue(withIdentifier: "show task", sender: nil)
            }))
            
            actionType.addAction( UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(actionType, animated: true, completion: nil)

            
        }
    }
    
    @IBAction func pressClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - LIFE CYCLE

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: currentDirectory?.info!.title ?? "Top", style: .plain, target: self, action: #selector(dismiss(animated:completion:)))
        if currentDirectory != nil {
            self.navigationItem.leftBarButtonItem = nil
            self.title = nil
        }
        self.navigationItem.rightBarButtonItem = self.editButtonItem

        saveHandler = AppDelegate.sharedInstance.saveContext
        // self.clearsSelectionOnViewWillAppear = true
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
}
