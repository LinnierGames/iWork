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
    
    private var selectedRowItems: [Directory] = [Directory]() {
        didSet {
            if selectedRowItems.count > 0 {
                navigationItem.rightBarButtonItem!.title = "Next"
            } else {
                navigationItem.rightBarButtonItem!.title = "Done"
            }
        }
    }
    
    fileprivate var fetchedResultsController: NSFetchedResultsController<Directory>? {
        didSet {
            if let controller = fetchedResultsController {
                do {
                    controller.delegate = self
                    try controller.performFetch()
                    
                } catch let error {
                    print("ERROR: \(error.localizedDescription)")
                }
                
                tableView.reloadData()
                
            }
            
        }
        
    }
    
    open var currentDirectory: Directory? { didSet { updateUI() } }
    
    // MARK: - RETURN VALUES
    
    // MARK: Table view data source
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return currentDirectory?.info!.title ?? "root"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // Configure the cell...
        let row = fetchedResultsController!.object(at: indexPath)
        
        cell.textLabel!.text = row.info!.title
        
        if row.isDirectory {
            cell.accessoryType = .detailDisclosureButton
        } else {
            cell.accessoryType = .detailButton
        }
        
        switch row.info! {
        case is Folder:
            cell.detailTextLabel!.text = row.folder.tasksDescription
        case is Project:
            cell.detailTextLabel!.text = row.project.tasksDescription
        case is Task:
            if row.task.isCompleted {
                cell.textLabel!.attributedText = CTAttributedStringStrikeOut(string: row.task.title!)
                cell.setState(enabled: false)
            } else {
                cell.textLabel!.attributedText = NSAttributedString(string: row.task.title!)
                cell.setState(enabled: true)
            }
            cell.isUserInteractionEnabled = true
        default:
            cell.detailTextLabel!.text = String(describing: row)
        }
        cell.detailTextLabel!.text = String(describing: row)
        
        return cell
    }
    
    // MARK: - VOID METHODS
    
    private func updateUI() {
        let request: NSFetchRequest<Directory> = Directory.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "info.title", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
        if let hierarchy = currentDirectory {
            request.predicate = NSPredicate(format: "role == %@ AND parent == %@", appDelegate.currentRole, hierarchy)
        } else {
            request.predicate = NSPredicate(format: "role == %@ AND parent = nil", appDelegate.currentRole)
        }
        fetchedResultsController = NSFetchedResultsController<Directory>(
            fetchRequest: request,
            managedObjectContext: container.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
    
    private func prompt<T>(type:T.Type, withTitle promptTitle: String?, message promptMessage: String = "enter a title", willComplete: @escaping (T) -> Void = {_ in }, didComplete: @escaping (T) -> Void = {_ in }) {
        let alert = UIAlertController(title: promptTitle, message: promptMessage, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.setStyleToParagraph(withPlacehodlerText: nil, withInitalText: nil)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] (action) in
            let newClass: DirectoryInfo, context = self!.container.viewContext
            if type is Folder.Type {
                newClass = Folder(context: context)
            } else if type is Project.Type {
                newClass = Project(context: context)
            } else if type is Task.Type {
                newClass = Task(context: context)
            } else {
                newClass = DirectoryInfo(context: context)
            }
            newClass.title = alert.inputField.text
            
            willComplete(newClass as! T)
            
            _ = Directory.createDirectory(forDirectoryInfo: newClass, withParent: self!.currentDirectory, in: context, forRole: self!.appDelegate.currentRole)
            
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
        if let identifier = segue.identifier {
            switch identifier {
            case "show task":
                let taskNC = segue.destination as! TaskNavigationController
                let task = (sender as! Directory).info! as! Task
                taskNC.task = task
            case "show move":
                let moveNC = segue.destination as! MoveNavigationController
                moveNC.itemsToBeMoved = selectedRowItems
                moveNC.parentDelegate = self
            default:
                break
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Table view
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        if (navigationItem.rightBarButtonItem!.title == "Next") {
            self.performSegue(withIdentifier: "show move", sender: nil)
        } else {
            super.setEditing(editing, animated: animated)
            
            let editingInvert = editing ? false : true
            buttonAddItem.isEnabled = editingInvert
            self.navigationItem.setHidesBackButton(editing, animated: true)
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = fetchedResultsController!.object(at: indexPath)
        if tableView.isEditing {
            // navController.selectedItems.append(row)
            selectedRowItems.append(row)
            
        } else {
            if row.isDirectory {
                let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "organize table") as! OrganizeTableTableViewController
                vc.currentDirectory = row
                
                self.navigationController?.pushViewController( vc, animated: true)
                
            }
            else if row.info! is Task {
                self.performSegue(withIdentifier: "show task", sender: row)
                
            }
            else {
                assertionFailure("tableView:didSelectRowAt: -- failed to cast the selected object from row")
            }
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let row = fetchedResultsController!.object(at: indexPath)
        if tableView.isEditing {
            if let index = selectedRowItems.index(of: row) {
                selectedRowItems.remove(at: index)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let rowItem = fetchedResultsController!.object(at: indexPath)
        let alert = UIAlertController(title: "Update Title", message: "enter a new title", preferredStyle: .alert
        )
        alert.addTextField { (textField) in
            textField.setStyleToParagraph(withPlacehodlerText: nil, withInitalText: rowItem.info!.title)
        }
        alert.addAction( UIAlertAction(title: "Discard", style: .default, handler: nil))
        alert.addAction( UIAlertAction(title: "Save", style: .default, handler: { [weak self] (action) in
            rowItem.info!.title = alert.textFields!.first!.text
            
            self!.appDelegate.saveContext()
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let row = fetchedResultsController!.object(at: indexPath)
            
            container.viewContext.delete(row)
            
            appDelegate.saveContext()
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
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
            prompt(type: Task.self, withTitle: "New Task", willComplete: { (obj) in
                obj.dateCreated = NSDate()
            })
            
        } else {
            let actionType = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            // A folder can be in root or inside another project
            actionType.addAction( UIAlertAction(title: "Folder", style: .default, handler: { [weak self] (action) in
                self!.prompt(type: Folder.self, withTitle: "New Folder")
            }))
            
            // A project can be inside anything but inside another project
            actionType.addAction( UIAlertAction(title: "Project", style: .default, handler: { [weak self] (action) in
                self!.prompt(type: Project.self, withTitle: "New Project", willComplete: { (obj) -> Void in
                    obj.dateCreated = NSDate()
                })
            }))
            
            // A task can be inside anywhere but not in root
            if currentDirectory != nil {
                actionType.addAction( UIAlertAction(title: "Task", style: .default, handler: { [weak self] (action) in
                    self!.prompt(type: Task.self, withTitle: "New Task", willComplete: { (obj) -> Void in
                        obj.dateCreated = NSDate()
                    })
                }))
            }
            
            actionType.addAction( UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(actionType, animated: true, completion: nil)

            
        }
    }
    
    @IBAction func pressClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: currentDirectory?.info!.title ?? "root", style: .plain, target: self, action: #selector(dismiss(animated:completion:)))
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem

        self.clearsSelectionOnViewWillAppear = true
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

}

extension OrganizeTableTableViewController
{
    
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
    
    //    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    //    {   if let sections = fetchedResultsController?.sections, sections.count > 0 {
    //        return sections[section].name
    //    } else {
    //        return nil
    //        }
    //    }
    //
    //    override func sectionIndexTitles(for tableView: UITableView) -> [String]?
    //    {
    //        return fetchedResultsController?.sectionIndexTitles
    //    }
    //
    //    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int
    //    {
    //        return fetchedResultsController?.section(forSectionIndexTitle: title, at: index) ?? 0
    //    }
    
}
