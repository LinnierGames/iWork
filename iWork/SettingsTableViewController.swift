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

fileprivate let CVNotificationViewDidAppear = "onViewDidAppear"

class SettingsTableViewController: FetchedResultsTableViewController, UITextFieldDelegate, DatePickerDelegate {

    fileprivate var hierarchy: CDSettingsHierarchy = .Root

    private var cellManager: CustomTableViewCells! {
        didSet {
            cellManager.textField.setStyleToParagraph(withPlaceholderText: "Name", withInitalText: AppDelegate.sharedInstance.currentEmployer.manager)
            cellManager.textField.returnKeyType = .done
            cellManager.textField.delegate = self
        }
    }

    private var cellSupervisor: CustomTableViewCells! {
        didSet {
            cellSupervisor.textField.setStyleToParagraph(withPlaceholderText: "Name", withInitalText: AppDelegate.sharedInstance.currentRole.supervisor)
            cellSupervisor.textField.returnKeyType = .done
            cellSupervisor.textField.delegate = self
        }
    }

    private var cellRegularRate: CustomTableViewCells! {
        didSet {
            cellRegularRate.textField.setStyleToParagraph(withPlaceholderText: "Rate", withInitalText: AppDelegate.sharedInstance.currentRole.regularRate!.currencyValue)
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
            return (fetchedResultsController.object(at: indexPath).objectID != AppDelegate.sharedInstance.currentEmployer.objectID)
        case .Roles:
            return (fetchedResultsController.object(at: indexPath).objectID != AppDelegate.sharedInstance.currentRole.objectID)
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
                cell.textLabel!.text = AppDelegate.sharedInstance.currentEmployer.name
                cell.accessoryType = .disclosureIndicator

                return cell
            case Table.Root.IndexPaths.SelectEmployer:
                let cell = tableView.returnCell(forIdentifier: "title", atIndexPath: indexPath)
                cell.textLabel!.text = "Switch Employers"
                cell.accessoryType = .disclosureIndicator

                return cell
            case Table.Root.IndexPaths.EditRole:
                let cell = tableView.returnCell(forIdentifier: "title", atIndexPath: indexPath)
                cell.textLabel!.text = AppDelegate.sharedInstance.currentRole.title
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
                cell.textLabel!.text = AppDelegate.sharedInstance.currentEmployer.name

                return cell
            case Table.Employer.IndexPaths.EmployerManagerRow:
                let cell = tableView.returnCell(forIdentifier: "titleTextField", atIndexPath: indexPath) as! CustomTableViewCells
                cell.labelTitle.text = "Manager"
                cell.textField.text = AppDelegate.sharedInstance.currentEmployer.manager

                cellManager = cell; return cell
            case Table.Employer.IndexPaths.EmployerStartDateRow:
                let cell = tableView.returnCell(forIdentifier: "subtitleRight", atIndexPath: indexPath)
                cell.textLabel!.text = "Start Date"
                cell.detailTextLabel!.text = String(AppDelegate.sharedInstance.currentEmployer.startDate!)
                cell.accessoryType = .disclosureIndicator

                return cell
            case Table.Employer.IndexPaths.EmployerEndDateRow:
                let cell = tableView.returnCell(forIdentifier: "subtitleRight", atIndexPath: indexPath)
                cell.textLabel!.text = "End Date"
                if let endDate = AppDelegate.sharedInstance.currentEmployer.endDate {
                    cell.detailTextLabel!.text = String(endDate)
                    cell.detailTextLabel!.textColor = UIColor.black
                } else {
                    cell.detailTextLabel!.text = "None"
                    cell.detailTextLabel!.textColor = UIColor.disabledState
                }
                cell.accessoryType = .disclosureIndicator

                return cell
            case Table.Employer.IndexPaths.LocationRow:
                let cell = tableView.returnCell(forIdentifier: "captionTextView", atIndexPath: indexPath) as! CustomTableViewCells
                cell.labelCaption.text = "Location"
                cell.textView.text = AppDelegate.sharedInstance.currentEmployer.location
                cell.textView.isEditable = false
                cell.accessoryType = .disclosureIndicator

                return cell
            case Table.Employer.IndexPaths.PhoneNumbersRow:
                let cell = tableView.returnCell(forIdentifier: "captionTextView", atIndexPath: indexPath) as! CustomTableViewCells
                cell.labelCaption.text = "Phone Numbers"
                cell.textView.text = AppDelegate.sharedInstance.currentEmployer.phoneNumbers ?? "None"
                cell.textView.isEditable = false
                cell.accessoryType = .disclosureIndicator

                return cell
            case Table.Employer.IndexPaths.HolidayRow:
                let cell = tableView.returnCell(forIdentifier: "subtitleRight", atIndexPath: indexPath)
                cell.textLabel!.text = "Holiday Dates"
                cell.detailTextLabel!.text = String(AppDelegate.sharedInstance.currentEmployer.holidayDates?.count ?? 0)
                cell.accessoryType = .disclosureIndicator

                return cell
            case Table.Employer.IndexPaths.NotesRow:
                let cell = tableView.returnCell(forIdentifier: "captionTextView", atIndexPath: indexPath) as! CustomTableViewCells
                cell.labelCaption.text = "Notes"
                cell.textView.text = AppDelegate.sharedInstance.currentEmployer.notes ?? "None"
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
                cell.textLabel!.text = AppDelegate.sharedInstance.currentRole.title

                return cell
            case Table.Role.IndexPaths.RoleSupervisorRow:
                let cell = tableView.returnCell(forIdentifier: "titleTextField", atIndexPath: indexPath) as! CustomTableViewCells
                cell.labelTitle.text = "Supervisor"
                cell.textField.text = AppDelegate.sharedInstance.currentRole.supervisor
                //cell.accessoryType = .none

                cellSupervisor = cell; return cell
            case Table.Role.IndexPaths.RoleStartDateRow:
                let cell = tableView.returnCell(forIdentifier: "subtitleRight", atIndexPath: indexPath)
                cell.textLabel!.text = "Start Date"
                cell.detailTextLabel!.text = String(AppDelegate.sharedInstance.currentRole.startDate!)

                return cell
            case Table.Role.IndexPaths.RoleEndDateRow:
                let cell = tableView.returnCell(forIdentifier: "subtitleRight", atIndexPath: indexPath)
                cell.textLabel!.text = "End Date"
                if let endDate = AppDelegate.sharedInstance.currentRole.endDate {
                    cell.detailTextLabel!.text = String(endDate)
                    cell.detailTextLabel!.textColor = UIColor.black
                } else {
                    cell.detailTextLabel!.text = "None"
                    cell.detailTextLabel!.textColor = UIColor.disabledState
                }

                return cell
            case Table.Role.IndexPaths.RoleRegularRateRow:
                let cell = tableView.returnCell(forIdentifier: "titleTextField", atIndexPath: indexPath) as! CustomTableViewCells
                cell.labelTitle.text = "Regular Pay Rate"
                cell.textField.text = AppDelegate.sharedInstance.currentRole.regularRate!.currencyValue

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
            if employer.objectID == AppDelegate.sharedInstance.currentEmployer.objectID {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }

            return cell
        case .Roles:
            let cell = tableView.returnCell(forIdentifier: "subtitle", atIndexPath: indexPath)
            let role = fetchedResultsController.object(at: indexPath) as! Role
            cell.textLabel!.text = role.title!
            if role.objectID == AppDelegate.sharedInstance.currentRole.objectID {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }

            return cell
        }
    }

    // MARK: Text Field Delegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == cellManager?.textField || textField == cellSupervisor?.textField {
            textField.resignFirstResponder()
        }

        return false
    }

    // MARK: - VOID METHODS

    private var reloadIndexesOnViewDidAppear: [IndexPath]?

    private func updateTable() {
        switch hierarchy {
        case .Employers:
            let fetch: NSFetchRequest<Employer> = Employer.fetchRequest()
            fetch.sortDescriptors = [CTSortDescriptor(key: "name")]
            fetchedResultsController = NSFetchedResultsController<NSManagedObject>(fetchRequest: fetch as! NSFetchRequest<NSManagedObject>, managedObjectContext: AppDelegate.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        case .Roles:
            let fetch: NSFetchRequest<Role> = Role.fetchRequest()
            fetch.predicate = NSPredicate(format: "employer == %@", AppDelegate.sharedInstance.currentEmployer)
            fetch.sortDescriptors = [CTSortDescriptor(key: "title")]
            fetchedResultsController = NSFetchedResultsController<NSManagedObject>(fetchRequest: fetch as! NSFetchRequest<NSManagedObject>, managedObjectContext: AppDelegate.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        default:
            break
        }

        tableView.reloadData()
    }

    private typealias PrepareSegueSender = (hierarchy: CDSettingsHierarchy, options: [String:Any]?)

    //Use this method to fire segues into a deeper hierarchy
    private func performSegue(withHierarchy hierarchy: CDSettingsHierarchy, object: [String:Any]? = nil) {
        self.performSegue(withIdentifier: "show setting", sender: (hierarchy, object)) //fire a genuine segue
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let object = sender as? PrepareSegueSender { //internal segue (moving deeper into the settings heirarchy)
            self.prepare(for: segue, object: object)
        } else { //external segues (e.g. date pickers)
            if let identifier = segue.identifier {
                switch identifier {
                case "show date":
                    let dateVC = (segue.destination as! UINavigationController).viewControllers.first! as! DatePickerViewController
                    switch sender as! String {
                    case "employer start":
                        dateVC.date = AppDelegate.sharedInstance.currentEmployer.startDate! as Date
                        dateVC.isTimeSet = true
                        var options = DatePickerOptions()
                        options.tag = 1
                        options.timeRequired = false
                        dateVC.options = options
                        dateVC.delegate = self
                        reloadIndexesOnViewDidAppear = [Table.Employer.IndexPaths.EmployerStartDateRow]
                    case "employer end":
                        dateVC.date = AppDelegate.sharedInstance.currentEmployer.endDate as Date?
                        var options = DatePickerOptions()
                        options.tag = 2
                        options.dateRanges = Range<Date>(uncheckedBounds: (lower: AppDelegate.sharedInstance.currentEmployer.startDate! as Date, upper: Date()))
                        options.timeRanges = true
                        options.dateRequired = false
                        options.timeRequired = false
                        dateVC.options = options
                        dateVC.isTimeSet = true
                        dateVC.delegate = self
                        reloadIndexesOnViewDidAppear = [Table.Employer.IndexPaths.EmployerEndDateRow]
                    case "role start":
                        dateVC.date = AppDelegate.sharedInstance.currentRole.startDate! as Date
                        dateVC.isTimeSet = true
                        var options = DatePickerOptions()
                        options.tag = 1
                        options.timeRequired = false
                        dateVC.options = options
                        dateVC.delegate = self
                        reloadIndexesOnViewDidAppear = [Table.Role.IndexPaths.RoleStartDateRow]
                    case "role end":
                        dateVC.date = AppDelegate.sharedInstance.currentRole.endDate as Date?
                        var options = DatePickerOptions()
                        options.tag = 2
                        options.dateRanges = Range<Date>(uncheckedBounds: (lower: AppDelegate.sharedInstance.currentRole.startDate! as Date, upper: Date()))
                        options.timeRanges = true
                        options.dateRequired = false
                        options.timeRequired = false
                        dateVC.options = options
                        dateVC.isTimeSet = true
                        dateVC.delegate = self
                        reloadIndexesOnViewDidAppear = [Table.Role.IndexPaths.RoleEndDateRow]
                    default: break
                    }
                default: break
                }
            }
        }
    }

    private func prepare(for segue: UIStoryboardSegue, object: PrepareSegueSender) {
        switch segue.identifier! {
        case "show setting":
            let settingVC = segue.destination as! SettingsTableViewController
            settingVC.hierarchy = object.hierarchy

            if object.options != nil {
                if let reloadingIndexPaths = object.options![CVNotificationViewDidAppear] as! [IndexPath]? {
                    reloadIndexesOnViewDidAppear = (reloadingIndexPaths)
                }
            }
        default:
            break
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
                self.performSegue(withHierarchy: .DetailEmployer, object: [CVNotificationViewDidAppear: [Table.Root.IndexPaths.EditEmployer]])
            case Table.Root.IndexPaths.SelectEmployer:
                self.performSegue(withHierarchy: .Employers, object: [CVNotificationViewDidAppear: [Table.Root.IndexPaths.EditEmployer, Table.Root.IndexPaths.EditRole]])
            case Table.Root.IndexPaths.EditRole:
                self.performSegue(withHierarchy: .DetailRole, object: [CVNotificationViewDidAppear: [Table.Root.IndexPaths.EditRole]])
            case Table.Root.IndexPaths.SelectRole:
                self.performSegue(withHierarchy: .Roles, object: [CVNotificationViewDidAppear: [Table.Root.IndexPaths.EditRole]])
            default:
                break
            }
        case .DetailEmployer:
            switch indexPath {
            case Table.Employer.IndexPaths.RenameEmployerRow:
                let alert = UIAlertController(title: "Rename Employer", message: "enter a name", preferredStyle: .alert)
                alert.addTextField(configurationHandler: { (textField) in
                    textField.setStyleToParagraph(withPlaceholderText: "name", withInitalText: AppDelegate.sharedInstance.currentEmployer.name)
                })
                alert.addActions(actions:
                    UIAlertActionInfo(title: "Rename", handler: { [weak self] (action) in
                        AppDelegate.sharedInstance.currentEmployer.name = alert.inputField.text
                        AppDelegate.sharedInstance.saveContext()
                        self!.tableView.reloadRows(at: [Table.Employer.IndexPaths.RenameEmployerRow], with: .fade)
                    })
                )

                self.present(alert, animated: true, completion: { [weak self] in
                    self!.tableView.deselectRow(at: Table.Employer.IndexPaths.RenameEmployerRow, animated: true)
                })
            case Table.Employer.IndexPaths.EmployerStartDateRow:
                self.performSegue(withIdentifier: "show date", sender: "employer start")
            case Table.Employer.IndexPaths.EmployerEndDateRow:
                self.performSegue(withIdentifier: "show date", sender: "employer end")
            default:
                break
            }
        case .Employers, .Roles:
            let row = fetchedResultsController.object(at: indexPath)
            if hierarchy == .Employers {
                AppDelegate.sharedInstance.currentEmployer = row as! Employer
                AppDelegate.userNotificationCenter.removePendingFifthHourNotificationRequests()
                //TODO most recent shit using sort descriptor, find active shifts vs using the first
                if let recentShift = AppDelegate.sharedInstance.currentEmployer.shifts?.array.last as! Shift? {
                    recentShift.setNotificationsForFifthHour()
                }
            } else {
                AppDelegate.sharedInstance.currentRole = row as! Role
            }
            self.navigationController?.popViewController(animated: true)
        case .DetailRole:
            switch indexPath {
            case Table.Role.IndexPaths.RenameRoleRow:
                let alert = UIAlertController(title: "Rename Role", message: "enter a title", preferredStyle: .alert)
                alert.addTextField(configurationHandler: { (textField) in
                    textField.setStyleToParagraph(withPlaceholderText: "title", withInitalText: AppDelegate.sharedInstance.currentRole.title)
                })
                alert.addActions(actions:
                    UIAlertActionInfo(title: "Rename", handler: { (action) in
                        AppDelegate.sharedInstance.currentRole.title = alert.inputField.text
                        AppDelegate.sharedInstance.saveContext()
                        tableView.reloadRows(at: [Table.Role.IndexPaths.RenameRoleRow], with: .fade)
                    })
                )

                self.present(alert, animated: true, completion: { [weak self] in
                    self!.tableView.deselectRow(at: Table.Role.IndexPaths.RenameRoleRow, animated: true)
                })
            case Table.Employer.IndexPaths.EmployerStartDateRow:
                self.performSegue(withIdentifier: "show date", sender: "role start")
            case Table.Employer.IndexPaths.EmployerEndDateRow:
                self.performSegue(withIdentifier: "show date", sender: "role end")
            default:
                break
            }
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let row = fetchedResultsController.object(at: indexPath)
            AppDelegate.viewContext.delete(row)
            AppDelegate.sharedInstance.saveContext()
        default:
            break
        }
    }

    // MARK: Text Field Delegate

    func textFieldDidEndEditing(_ textField: UITextField) {
        switch hierarchy {
        case .DetailEmployer:
            if textField == cellManager.textField {
                AppDelegate.sharedInstance.currentEmployer.manager = textField.text
                AppDelegate.sharedInstance.saveContext()
            }
        case .DetailRole:
            if textField == cellSupervisor.textField {
                AppDelegate.sharedInstance.currentRole.supervisor = textField.text
                AppDelegate.sharedInstance.saveContext()
            }
        default:
            break
        }
    }

    // MARK: Date Picker Delegate

    func datePicker(_ picker: DatePickerViewController, didFinishWithDate date: Date?, withTimeInterval interval: TimeInterval?) {
        switch hierarchy {
        case .DetailEmployer:
            if picker.options.tag! == 1 { //Start Date
                AppDelegate.sharedInstance.currentEmployer.startDate = date as NSDate?
            } else if picker.options.tag! == 2 { //End Date
                AppDelegate.sharedInstance.currentEmployer.endDate = date as NSDate?
            }
            AppDelegate.sharedInstance.saveContext()
        case .DetailRole:
            if picker.options.tag! == 1 { //Start Date
                AppDelegate.sharedInstance.currentRole.startDate = date as NSDate?
            } else if picker.options.tag! == 2 { //End Date
                AppDelegate.sharedInstance.currentRole.endDate = date as NSDate?
            }
            AppDelegate.sharedInstance.saveContext()
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
                UIAlertActionInfo(title: "Save", handler: { (action) in
                    _ = Employer(name: alert.inputField.text!, inContext: AppDelegate.viewContext)
                    AppDelegate.sharedInstance.saveContext()
                })
            )
            self.present(alert, animated: true, completion: nil)
        case .Roles:
            let alert = UIAlertController(title: "New Role", message: "enter a title", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.setStyleToParagraph()
            }
            alert.addActions(actions:
                UIAlertActionInfo(title: "Save", handler: { (action) in
                    _ = Role(title: alert.inputField.text!, inContext: AppDelegate.viewContext, forEmployer: AppDelegate.sharedInstance.currentEmployer)
                    AppDelegate.sharedInstance.saveContext()
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

        DispatchQueue.once(token: DispatchQueue.SettingViewDidAppear) {
            if hierarchy == .Root {
                let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
                let build = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
                let labelVersion = UITextView(frame: CGRect(x: 0, y: 0, width: 0, height: 64))
                labelVersion.translatesAutoresizingMaskIntoConstraints = false

                labelVersion.text = "iWork (Linnier__Games)\nv\(version) (\(build))\ndev branch"
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
