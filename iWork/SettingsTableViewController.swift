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

fileprivate struct Table {
    static let employerSection = 0
    static let roleSection = 1
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
        static let RenameRoleRow = IndexPath(row: 0, section: 1)
        static let RoleSupervisorRow = IndexPath(row: 1, section: 1)
        static let RoleStartDateRow = IndexPath(row: 2, section: 1)
        static let RoleEndDateRow = IndexPath(row: 3, section: 1)
        static let RoleRegularRateRow = IndexPath(row: 4, section: 1)
        static let RoleTimeAndHalfRow = IndexPath(row: 5, section: 1)
        static let RoleOvertimeRow = IndexPath(row: 6, section: 1)
        static let SelectRoleRow = IndexPath(row: 7, section: 1)
    }
}

class SettingsTableViewController: FetchedResultsTableViewController, UITextFieldDelegate {
    
    fileprivate var hierarchy: CDSettingsHierarchy = .root
    
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
        case .root:
            return 2
        case .employers:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch hierarchy {
        case .root:
            if section == Table.employerSection {
                return "Current Employer"
            } else {
                return "Current Role"
            }
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch hierarchy {
        case .root:
            if section == Table.employerSection {
                return 9
            } else {
                return 8
            }
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch hierarchy {
        case .root:
            switch indexPath {
            case Table.IndexPaths.LocationRow, Table.IndexPaths.PhoneNumbersRow, Table.IndexPaths.NotesRow:
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
        case .root:
            switch indexPath {
            case Table.IndexPaths.RenameEmployerRow:
                let cell = tableView.returnCell(forIdentifier: "title", atIndexPath: indexPath)
                cell.textLabel!.text = appDelegate.currentEmployer.name
                
                return cell
            case Table.IndexPaths.EmployerManagerRow:
                let cell = tableView.returnCell(forIdentifier: "titleTextField", atIndexPath: indexPath) as! CustomTableViewCells
                cell.labelTitle.text = "Manager"
                cell.textField.text = appDelegate.currentEmployer.manager
                
                cellManager = cell; return cell
            case Table.IndexPaths.EmployerStartDateRow:
                let cell = tableView.returnCell(forIdentifier: "subtitleRight", atIndexPath: indexPath)
                cell.textLabel!.text = "Start Date"
                cell.detailTextLabel!.text = String(appDelegate.currentEmployer.startDate!)
                
                return cell
            case Table.IndexPaths.EmployerEndDateRow:
                let cell = tableView.returnCell(forIdentifier: "subtitleRight", atIndexPath: indexPath)
                cell.textLabel!.text = "End Date"
                if let endDate = appDelegate.currentEmployer.endDate {
                    cell.detailTextLabel!.text = String(endDate)
                } else {
                    cell.detailTextLabel!.text = ""
                }
                
                return cell
            case Table.IndexPaths.LocationRow:
                let cell = tableView.returnCell(forIdentifier: "captionTextView", atIndexPath: indexPath) as! CustomTableViewCells
                cell.labelCaption.text = "Location"
                cell.textView.text = appDelegate.currentEmployer.location
                cell.textView.isEditable = false
                cell.accessoryType = .disclosureIndicator
                
                return cell
            case Table.IndexPaths.PhoneNumbersRow:
                let cell = tableView.returnCell(forIdentifier: "captionTextView", atIndexPath: indexPath) as! CustomTableViewCells
                cell.labelCaption.text = "Phone Numbers"
                cell.textView.text = appDelegate.currentEmployer.phoneNumbers ?? "None"
                cell.textView.isEditable = false
                cell.accessoryType = .disclosureIndicator
                
                return cell
            case Table.IndexPaths.NotesRow:
                let cell = tableView.returnCell(forIdentifier: "captionTextView", atIndexPath: indexPath) as! CustomTableViewCells
                cell.labelCaption.text = "Notes"
                cell.textView.text = appDelegate.currentEmployer.notes
                cell.textView.text = appDelegate.currentEmployer.notes ?? "None"
                cell.textView.isEditable = false
                cell.accessoryType = .disclosureIndicator
                
                return cell
            case Table.IndexPaths.SelectEmployerRow:
                let cell = tableView.returnCell(forIdentifier: "title", atIndexPath: indexPath)
                cell.textLabel!.text = "Select Employer"
                cell.accessoryType = .disclosureIndicator
                
                return cell
            case Table.IndexPaths.RenameRoleRow:
                let cell = tableView.returnCell(forIdentifier: "title", atIndexPath: indexPath)
                cell.textLabel!.text = appDelegate.currentRole.title
                
                return cell
            case Table.IndexPaths.RoleSupervisorRow:
                let cell = tableView.returnCell(forIdentifier: "titleTextField", atIndexPath: indexPath) as! CustomTableViewCells
                cell.labelTitle.text = "Supervisor"
                cell.textField.text = appDelegate.currentRole.supervisor
                //cell.accessoryType = .none
                
                cellSupervisor = cell; return cell
            case Table.IndexPaths.RoleStartDateRow:
                let cell = tableView.returnCell(forIdentifier: "subtitleRight", atIndexPath: indexPath)
                cell.textLabel!.text = "Start Date"
                cell.detailTextLabel!.text = String(appDelegate.currentRole.startDate!)
                
                return cell
            case Table.IndexPaths.RoleEndDateRow:
                let cell = tableView.returnCell(forIdentifier: "subtitleRight", atIndexPath: indexPath)
                cell.textLabel!.text = "End Date"
                if let endDate = appDelegate.currentRole.endDate {
                    cell.detailTextLabel!.text = String(endDate)
                } else {
                    cell.detailTextLabel!.text = ""
                }
                
                return cell
            case Table.IndexPaths.HolidayRow:
                let cell = tableView.returnCell(forIdentifier: "title", atIndexPath: indexPath)
                cell.textLabel!.text = "Holiday Dates"
                
                return cell
            case Table.IndexPaths.RoleRegularRateRow:
                let cell = tableView.returnCell(forIdentifier: "titleTextField", atIndexPath: indexPath) as! CustomTableViewCells
                cell.labelTitle.text = "Regular Pay Rate"
                cell.textField.text = appDelegate.currentRole.regularRate!.currencyValue
                
                cellRegularRate = cell; return cell
            case Table.IndexPaths.RoleTimeAndHalfRow:
                let cell = tableView.returnCell(forIdentifier: "subtitleRight", atIndexPath: indexPath)
                cell.textLabel!.text = "Time and a Half"
                
                return cell
            case Table.IndexPaths.RoleOvertimeRow:
                let cell = tableView.returnCell(forIdentifier: "subtitleRight", atIndexPath: indexPath)
                cell.textLabel!.text = "Overtime"
                
                return cell
            case Table.IndexPaths.SelectRoleRow:
                let cell = tableView.returnCell(forIdentifier: "title", atIndexPath: indexPath)
                cell.textLabel!.text = "Select Role"
                cell.accessoryType = .disclosureIndicator
                
                return cell
            default:
                return UITableViewCell() //None
            }
        case .employers:
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
        case .root:
            break
        case .employers:
            let fetch: NSFetchRequest<Employer> = Employer.fetchRequest()
            fetch.sortDescriptors = [CTSortDescriptor(key: "name")]
            fetchedResultsController = NSFetchedResultsController<NSManagedObject>(fetchRequest: fetch as! NSFetchRequest<NSManagedObject>, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        }
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
            case "show setting":
                let settingVC = segue.destination as! SettingsTableViewController
                settingVC.hierarchy = .employers
                
                reloadIndexesOnViewDidAppear = [sender as! IndexPath]
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
        case .root:
            if indexPath == Table.IndexPaths.RenameEmployerRow {
                let alert = UIAlertController(title: "Rename Employer", message: "enter a name", preferredStyle: .alert)
                alert.addTextField(configurationHandler: { [weak self] (textField) in
                    textField.setStyleToParagraph(withPlaceholderText: "name", withInitalText: self!.appDelegate.currentEmployer.name)
                })
                alert.addActions(actions:
                    UIAlertActionInfo(title: "Rename", handler: { [weak self] (action) in
                        self!.appDelegate.currentEmployer.name = alert.inputField.text
                        self!.appDelegate.saveContext()
                        self!.tableView.reloadRows(at: [Table.IndexPaths.RenameEmployerRow], with: .fade)
                    })
                )
                
                self.present(alert, animated: true, completion: { [weak self] in
                    self!.tableView.deselectRow(at: Table.IndexPaths.RenameEmployerRow, animated: true)
                })
                
            } else if indexPath == Table.IndexPaths.SelectEmployerRow {
                performSegue(withIdentifier: "show setting", sender: Table.IndexPaths.RenameEmployerRow)
            }
        case .employers:
            let employer = fetchedResultsController.object(at: indexPath) as! Employer
            appDelegate.currentEmployer = employer
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
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
        if textField == cellManager.textField {
            appDelegate.currentEmployer.manager = textField.text
            appDelegate.saveContext()
        }
    }
    
    // MARK: - IBACTIONS
    
    internal func pressRightNav(_ sender: Any) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let indexesToReload = reloadIndexesOnViewDidAppear {
            tableView.reloadRows(at: indexesToReload, with: .fade)
            reloadIndexesOnViewDidAppear = nil
        }
        
        DispatchQueue.once(token: "settings.viewWillAppear") {
            if hierarchy == .root {
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
