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
    case Root
        case DetailEmployer
            case Employers
        case DetailRole
            case Roles
}

fileprivate struct Table {
    struct Root {
        static let employerSection = 0
        static let roleSection = 1
        struct IndexPaths {
            static let EditEmployer = IndexPath(row: 0, section: 0)
            static let SelectEmployer = IndexPath(row: 1, section: 0)
            static let EditRole = IndexPath(row: 0, section: 1)
            static let SelectRole = IndexPath(row: 1, section: 1)
        }
    }
    struct Employer {
        struct IndexPaths {
            static let RenameEmployerRow = IndexPath(row: 0, section: 0)
            static let EmployerManagerRow = IndexPath(row: 1, section: 0)
            static let EmployerStartDateRow = IndexPath(row: 2, section: 0)
            static let EmployerEndDateRow = IndexPath(row: 3, section: 0)
            static let LocationRow = IndexPath(row: 4, section: 0)
            static let PhoneNumbersRow = IndexPath(row: 5, section: 0)
            static let HolidayRow = IndexPath(row: 6, section: 0)
            static let NotesRow = IndexPath(row: 7, section: 0)
            static let SelectEmployerRow = IndexPath(row: 8, section: 0)
        }
    }
    struct Role {
        struct IndexPaths {
            static let RenameRoleRow = IndexPath(row: 0, section: 0)
            static let RoleSupervisorRow = IndexPath(row: 1, section: 0)
            static let RoleStartDateRow = IndexPath(row: 2, section: 0)
            static let RoleEndDateRow = IndexPath(row: 3, section: 0)
            static let RoleRegularRateRow = IndexPath(row: 4, section: 0)
            static let RoleTimeAndHalfRow = IndexPath(row: 5, section: 0)
            static let RoleOvertimeRow = IndexPath(row: 6, section: 0)
            static let SelectRoleRow = IndexPath(row: 7, section: 0)
        }
    }
}

class SettingsTableViewController: FetchedResultsTableViewController, UITextFieldDelegate {
    
    fileprivate var hierarchy: CDSettingsHierarchy = .Root
    
    private var cellManager: CustomTableViewCells! {
        didSet {
            cellManager.textField.setStyleToParagraph(withPlaceholderText: "Name", withInitalText: appDelegate.currentEmployer.manager)
            cellManager.textField.returnKeyType = .done
            cellManager.textField.delegate = self
        }
    }
    
    private var cellSupervisor: CustomTableViewCells! {
        didSet {
            cellSupervisor.textField.setStyleToParagraph(withPlaceholderText: "Name", withInitalText: appDelegate.currentRole.supervisor)
            cellSupervisor.textField.returnKeyType = .done
            cellSupervisor.textField.delegate = self
        }
    }
    
    private var cellRegularRate: CustomTableViewCells! {
        didSet {
            cellRegularRate.textField.setStyleToParagraph(withPlaceholderText: "Rate", withInitalText: appDelegate.currentRole.regularRate!.currencyValue)
            cellRegularRate.textField.returnKeyType = .done
            cellRegularRate.textField.delegate = self
        }
    }
    
    var array: [Any]!
    
    // MARK: - RETURN VALUES
    
    // MARK: Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        switch hierarchy {
        case .Root:
            return 2
        case .Employers:
            return 1
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch hierarchy {
        case .Root:
            switch section {
            case Table.Root.employerSection:
                return "Current Employer and Role"
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch hierarchy {
        case .Root:
            switch section {
            case Table.Root.employerSection, Table.Root.roleSection:
                return 2
            default:
                return 0
            }
        case .DetailEmployer:
            return 8
        case .Employers, .Roles:
            return fetchedResultsController.sections![section].numberOfObjects
        case .DetailRole:
            return 7
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch hierarchy {
        case .Employers:
            return (fetchedResultsController.object(at: indexPath).objectID != appDelegate.currentEmployer.objectID)
        case .Roles:
            return (fetchedResultsController.object(at: indexPath).objectID != appDelegate.currentRole.objectID)
        default:
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch hierarchy {
        case .Root:
            return 44
        case .DetailEmployer:
            switch indexPath {
            case Table.Employer.IndexPaths.LocationRow, Table.Employer.IndexPaths.PhoneNumbersRow, Table.Employer.IndexPaths.NotesRow:
                return 96
            default:
                return 44
            }
        default:
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch hierarchy {
        case .Root:
            switch indexPath {
            case Table.Root.IndexPaths.EditEmployer:
                let cell = tableView.returnCell(forIdentifier: "title", atIndexPath: indexPath)
                cell.textLabel!.text = appDelegate.currentEmployer.name
                cell.accessoryType = .disclosureIndicator
                
                return cell
            case Table.Root.IndexPaths.SelectEmployer:
                let cell = tableView.returnCell(forIdentifier: "title", atIndexPath: indexPath)
                cell.textLabel!.text = "Switch Employers"
                cell.accessoryType = .disclosureIndicator
                
                return cell
            case Table.Root.IndexPaths.EditRole:
                let cell = tableView.returnCell(forIdentifier: "title", atIndexPath: indexPath)
                cell.textLabel!.text = appDelegate.currentRole.title
                cell.accessoryType = .disclosureIndicator
                
                return cell
            case Table.Root.IndexPaths.SelectRole:
                let cell = tableView.returnCell(forIdentifier: "title", atIndexPath: indexPath)
                cell.textLabel!.text = "Switch Roles"
                cell.accessoryType = .disclosureIndicator
                
                return cell
            default:
                return UITableViewCell() //None
            }
        case .DetailEmployer:
            switch indexPath {
            case Table.Employer.IndexPaths.RenameEmployerRow:
                let cell = tableView.returnCell(forIdentifier: "title", atIndexPath: indexPath)
                cell.textLabel!.text = appDelegate.currentEmployer.name
                
                return cell
            case Table.Employer.IndexPaths.EmployerManagerRow:
                let cell = tableView.returnCell(forIdentifier: "titleTextField", atIndexPath: indexPath) as! CustomTableViewCells
                cell.labelTitle.text = "Manager"
                cell.textField.text = appDelegate.currentEmployer.manager
                
                cellManager = cell; return cell
            case Table.Employer.IndexPaths.EmployerStartDateRow:
                let cell = tableView.returnCell(forIdentifier: "subtitleRight", atIndexPath: indexPath)
                cell.textLabel!.text = "Start Date"
                cell.detailTextLabel!.text = String(appDelegate.currentEmployer.startDate!)
                
                return cell
            case Table.Employer.IndexPaths.EmployerEndDateRow:
                let cell = tableView.returnCell(forIdentifier: "subtitleRight", atIndexPath: indexPath)
                cell.textLabel!.text = "End Date"
                if let endDate = appDelegate.currentEmployer.endDate {
                    cell.detailTextLabel!.text = String(endDate)
                } else {
                    cell.detailTextLabel!.text = ""
                }
                
                return cell
            case Table.Employer.IndexPaths.LocationRow:
                let cell = tableView.returnCell(forIdentifier: "captionTextView", atIndexPath: indexPath) as! CustomTableViewCells
                cell.labelCaption.text = "Location"
                cell.textView.text = appDelegate.currentEmployer.location
                cell.textView.isEditable = false
                cell.accessoryType = .disclosureIndicator
                
                return cell
            case Table.Employer.IndexPaths.PhoneNumbersRow:
                let cell = tableView.returnCell(forIdentifier: "captionTextView", atIndexPath: indexPath) as! CustomTableViewCells
                cell.labelCaption.text = "Phone Numbers"
                cell.textView.text = appDelegate.currentEmployer.phoneNumbers ?? "None"
                cell.textView.isEditable = false
                cell.accessoryType = .disclosureIndicator
                
                return cell
            case Table.Employer.IndexPaths.HolidayRow:
                let cell = tableView.returnCell(forIdentifier: "title", atIndexPath: indexPath)
                cell.textLabel!.text = "Holiday Dates"
                
                return cell
            case Table.Employer.IndexPaths.NotesRow:
                let cell = tableView.returnCell(forIdentifier: "captionTextView", atIndexPath: indexPath) as! CustomTableViewCells
                cell.labelCaption.text = "Notes"
                cell.textView.text = appDelegate.currentEmployer.notes
                cell.textView.text = appDelegate.currentEmployer.notes ?? "None"
                cell.textView.isEditable = false
                cell.accessoryType = .disclosureIndicator
                
                return cell
            default:
                return UITableViewCell() //None
            }
        case .DetailRole:
            switch indexPath {
            case Table.Role.IndexPaths.RenameRoleRow:
                let cell = tableView.returnCell(forIdentifier: "title", atIndexPath: indexPath)
                cell.textLabel!.text = appDelegate.currentRole.title
                
                return cell
            case Table.Role.IndexPaths.RoleSupervisorRow:
                let cell = tableView.returnCell(forIdentifier: "titleTextField", atIndexPath: indexPath) as! CustomTableViewCells
                cell.labelTitle.text = "Supervisor"
                cell.textField.text = appDelegate.currentRole.supervisor
                //cell.accessoryType = .none
                
                cellSupervisor = cell; return cell
            case Table.Role.IndexPaths.RoleStartDateRow:
                let cell = tableView.returnCell(forIdentifier: "subtitleRight", atIndexPath: indexPath)
                cell.textLabel!.text = "Start Date"
                cell.detailTextLabel!.text = String(appDelegate.currentRole.startDate!)
                
                return cell
            case Table.Role.IndexPaths.RoleEndDateRow:
                let cell = tableView.returnCell(forIdentifier: "subtitleRight", atIndexPath: indexPath)
                cell.textLabel!.text = "End Date"
                if let endDate = appDelegate.currentRole.endDate {
                    cell.detailTextLabel!.text = String(endDate)
                } else {
                    cell.detailTextLabel!.text = ""
                }
                
                return cell
            case Table.Role.IndexPaths.RoleRegularRateRow:
                let cell = tableView.returnCell(forIdentifier: "titleTextField", atIndexPath: indexPath) as! CustomTableViewCells
                cell.labelTitle.text = "Regular Pay Rate"
                cell.textField.text = appDelegate.currentRole.regularRate!.currencyValue
                
                cellRegularRate = cell; return cell
            case Table.Role.IndexPaths.RoleTimeAndHalfRow:
                let cell = tableView.returnCell(forIdentifier: "subtitleRight", atIndexPath: indexPath)
                cell.textLabel!.text = "Time and a Half"
                
                return cell
            case Table.Role.IndexPaths.RoleOvertimeRow:
                let cell = tableView.returnCell(forIdentifier: "subtitleRight", atIndexPath: indexPath)
                cell.textLabel!.text = "Overtime"
                
                return cell
            default:
                return UITableViewCell()
            }
        case .Employers:
            let cell = tableView.returnCell(forIdentifier: "subtitle", atIndexPath: indexPath)
            let employer = fetchedResultsController.object(at: indexPath) as! Employer
            cell.textLabel!.text = String("\(employer.name!) - \(employer.selectedRole!.title!)")
            cell.detailTextLabel!.text = String("Number of Roles: \(employer.roles?.count ?? 0)")
            if employer.objectID == appDelegate.currentEmployer.objectID {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            return cell
        case .Roles:
            let cell = tableView.returnCell(forIdentifier: "subtitle", atIndexPath: indexPath)
            let role = fetchedResultsController.object(at: indexPath) as! Role
            cell.textLabel!.text = role.title!
            if role.objectID == appDelegate.currentRole.objectID {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            return cell
        }
    }
    
    // MARK: Text Field Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == cellManager.textField || textField == cellSupervisor.textField {
            textField.resignFirstResponder()
        }
        
        return false
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
        case .Employers:
            let fetch: NSFetchRequest<Employer> = Employer.fetchRequest()
            fetch.sortDescriptors = [CTSortDescriptor(key: "name")]
            fetchedResultsController = NSFetchedResultsController<NSManagedObject>(fetchRequest: fetch as! NSFetchRequest<NSManagedObject>, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        case .Roles:
            let fetch: NSFetchRequest<Role> = Role.fetchRequest()
            fetch.predicate = NSPredicate(format: "employer == %@", appDelegate.currentEmployer)
            fetch.sortDescriptors = [CTSortDescriptor(key: "title")]
            fetchedResultsController = NSFetchedResultsController<NSManagedObject>(fetchRequest: fetch as! NSFetchRequest<NSManagedObject>, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        default:
            break
        }
    
        tableView.reloadData()
    }
    
    private typealias prepareSegueSender = (hierarchy: CDSettingsHierarchy, options: [String:Any]?)
    
    private func performSegue(withHierarchy hierarchy: CDSettingsHierarchy, object: [String:Any]? = nil) {
        self.performSegue(withIdentifier: "show setting", sender: (hierarchy, object))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.prepare(for: segue, object: sender! as! prepareSegueSender)
    }
    
    private func prepare(for segue: UIStoryboardSegue, object: prepareSegueSender) {
        if let identifier = segue.identifier {
            switch identifier {
            case "show setting":
                let settingVC = segue.destination as! SettingsTableViewController
                settingVC.hierarchy = object.hierarchy
                
                if object.options != nil {
                    if let reloadingIndexPaths = object.options!["reloadOnViewDidAppear"] {
                        reloadIndexesOnViewDidAppear = (reloadingIndexPaths as! [IndexPath])
                    }
                }
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
        switch hierarchy {
        case .Root:
            switch indexPath {
            case Table.Root.IndexPaths.EditEmployer:
                self.performSegue(withHierarchy: .DetailEmployer, object: ["reloadOnViewDidAppear": [Table.Root.IndexPaths.EditEmployer]])
            case Table.Root.IndexPaths.SelectEmployer:
                self.performSegue(withHierarchy: .Employers, object: ["reloadOnViewDidAppear": [Table.Root.IndexPaths.EditEmployer, Table.Root.IndexPaths.EditRole]])
            case Table.Root.IndexPaths.EditRole:
                self.performSegue(withHierarchy: .DetailRole, object: ["reloadOnViewDidAppear": [Table.Root.IndexPaths.EditRole]])
            case Table.Root.IndexPaths.SelectRole:
                self.performSegue(withHierarchy: .Roles, object: ["reloadOnViewDidAppear": [Table.Root.IndexPaths.EditRole]])
            default:
                break
            }
        case .DetailEmployer:
            if indexPath == Table.Employer.IndexPaths.RenameEmployerRow {
                let alert = UIAlertController(title: "Rename Employer", message: "enter a name", preferredStyle: .alert)
                alert.addTextField(configurationHandler: { [weak self] (textField) in
                    textField.setStyleToParagraph(withPlaceholderText: "name", withInitalText: self!.appDelegate.currentEmployer.name)
                })
                alert.addActions(actions:
                    UIAlertActionInfo(title: "Rename", handler: { [weak self] (action) in
                        self!.appDelegate.currentEmployer.name = alert.inputField.text
                        self!.appDelegate.saveContext()
                        self!.tableView.reloadRows(at: [Table.Employer.IndexPaths.RenameEmployerRow], with: .fade)
                    })
                )
                
                self.present(alert, animated: true, completion: { [weak self] in
                    self!.tableView.deselectRow(at: Table.Employer.IndexPaths.RenameEmployerRow, animated: true)
                })
                
            }
        case .Employers, .Roles:
            let row = fetchedResultsController.object(at: indexPath)
            if hierarchy == .Employers {
                appDelegate.currentEmployer = row as! Employer
            } else {
                appDelegate.currentRole = row as! Role
            }
            self.navigationController?.popViewController(animated: true)
        case .DetailRole:
            if indexPath == Table.Role.IndexPaths.RenameRoleRow {
                let alert = UIAlertController(title: "Rename Role", message: "enter a title", preferredStyle: .alert)
                alert.addTextField(configurationHandler: { [weak self] (textField) in
                    textField.setStyleToParagraph(withPlaceholderText: "title", withInitalText: self!.appDelegate.currentRole.title)
                })
                alert.addActions(actions:
                    UIAlertActionInfo(title: "Rename", handler: { [weak self] (action) in
                        self!.appDelegate.currentRole.title = alert.inputField.text
                        self!.appDelegate.saveContext()
                        self!.tableView.reloadRows(at: [Table.Role.IndexPaths.RenameRoleRow], with: .fade)
                    })
                )
                
                self.present(alert, animated: true, completion: { [weak self] in
                    self!.tableView.deselectRow(at: Table.Role.IndexPaths.RenameRoleRow, animated: true)
                })
            }
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
    
    // MARK: Text Field Delegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch hierarchy {
        case .DetailEmployer:
            if textField == cellManager.textField {
                appDelegate.currentEmployer.manager = textField.text
                appDelegate.saveContext()
            }
        case .DetailRole:
            if textField == cellSupervisor.textField {
                appDelegate.currentRole.supervisor = textField.text
                appDelegate.saveContext()
            }
        default:
            break
        }
    }
    
    // MARK: - IBACTIONS
    
    internal func pressRightNav(_ sender: Any) {
        switch hierarchy {
        case .Employers:
            let alert = UIAlertController(title: "New Employer", message: "enter a name", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.setStyleToParagraph()
            }
            alert.addActions(actions:
                UIAlertActionInfo(title: "Save", handler: { [weak self] (action) in
                    _ = Employer(name: alert.inputField.text!, inContext: self!.container.viewContext)
                    self!.appDelegate.saveContext()
                })
            )
            self.present(alert, animated: true, completion: nil)
        case .Roles:
            let alert = UIAlertController(title: "New Role", message: "enter a title", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.setStyleToParagraph()
            }
            alert.addActions(actions:
                UIAlertActionInfo(title: "Save", handler: { [weak self] (action) in
                    _ = Role(title: alert.inputField.text!, inContext: self!.container.viewContext, forEmployer: self!.appDelegate.currentEmployer)
                    self!.appDelegate.saveContext()
                })
            )
            self.present(alert, animated: true, completion: nil)
        default:
            break
        }
    }
    
    // MARK: - LIFE CYCLE

    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch hierarchy {
        case .Employers, .Roles:
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(pressRightNav(_:)))
        default:
            break
        }
        
        updateTable()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch hierarchy {
        case .DetailEmployer:
            title = "Employer Details"
        case .Employers:
            title = "Select an Employer"
        case .DetailRole:
            title = "Role Details"
        case .Roles:
            title = "Select a Role"
        default:
            break
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let indexesToReload = reloadIndexesOnViewDidAppear {
            tableView.reloadRows(at: indexesToReload, with: .fade)
            reloadIndexesOnViewDidAppear = nil
        }
        
        DispatchQueue.once(token: "settings.viewWillAppear") {
            if hierarchy == .Root {
                let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
                let build = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
                let labelVersion = UITextView(frame: CGRect(x: 0, y: 0, width: 0, height: 64))
                labelVersion.translatesAutoresizingMaskIntoConstraints = false
                
                labelVersion.text = "iWork (Linnier__Games)\nv\(version) (\(build))"
                labelVersion.textAlignment = .center
                labelVersion.textColor = UIColor.lightGray
                labelVersion.isEditable = false
                labelVersion.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
                tableView.addSubview(labelVersion)
                
                let margins = labelVersion.superview!.readableContentGuide
                
                labelVersion.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
                labelVersion.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
                labelVersion.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: 0).isActive = true
                labelVersion.heightAnchor.constraint(equalToConstant: 64).isActive = true
            }
        }
    }
}
