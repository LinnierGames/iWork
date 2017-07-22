//
//  TaskViewController.swift
//  iWork
//
//  Created by Erick Sanchez on 7/4/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import UIKit

//checkbox/title, assigned by, due date, prioity/isStarred, notes,
private struct Table {
    static var titleSection = 0
    static var assignedBySection = 1
    static var startDateSection = 2
    static var dueDateSection = 3
    static var prioritySection = 4
    static var notesSection = 5
}

class TaskViewController: UITableViewController, UITextFieldDelegate, DatePickerDelegate, UITextViewDelegate {
    
    private var hasInitialTitle = false
    
    private var showAssigngedBy: Bool = false {
        didSet {
            if oldValue != showAssigngedBy {
                if oldValue == false {
                    tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
                } else {
                    tableView.deleteRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
                }
            }
        }
    }
    
    private var cellTitle: CustomTableViewCells! {
        didSet {
            cellTitle.textField.delegate = self
            cellTitle.textField.text = navController.task.title
            if navController.option == .insert {
                cellTitle.textField.becomeFirstResponder()
                cellTitle.textField.placeholder = "New Task Title"
            } else {
                cellTitle.textField.placeholder = "Title"
            }
        }
    }
    
    private var cellAssignedBy: CustomTableViewCells! {
        didSet {
            cellAssignedBy.textField.delegate = self
            if let assignedBy = navController.task.assignedBy {
                cellAssignedBy.textField.text = assignedBy
                //showAssigngedBy = true
            }
            cellAssignedBy.textField.placeholder = "Assigned by"
        }
    }
    
    private var cellDueDate: CustomTableViewCells! {
        didSet {
            if let dueDate = navController.task.dueDate {
                let showTime = navController.task.dueTime == true ? DateFormatter.Style.short : DateFormatter.Style.none
                cellDueDate.labelSubtitle.text = DateFormatter.localizedString(from: dueDate as Date, dateStyle: .medium, timeStyle: showTime)
            } else {
                cellDueDate.labelSubtitle.text = "Add a Due Date"
            }
        }
    }
    
    private var cellStartDate: CustomTableViewCells! {
        didSet {
            if let startDate = navController.task.startDate {
                let showTime = navController.task.startTime == true ? DateFormatter.Style.short : DateFormatter.Style.none
                cellStartDate.labelSubtitle.text = DateFormatter.localizedString(from: startDate as Date, dateStyle: .medium, timeStyle: showTime)
            } else {
                cellStartDate.labelSubtitle.text = "Add a Start Date"
            }
        }
    }
    
    private var cellPriority: CustomTableViewCells! {
        didSet {
            let priority = navController.task.priority
            if priority == .none {
                cellPriority.labelSubtitle.text = "Add a Prioity"
            } else {
                cellPriority.labelSubtitle.text = String(describing: priority)
            }
        }
    }
    
    private var cellNotes: CustomTableViewCells! {
        didSet {
            cellNotes.textView.text = navController.task.notes
            cellNotes.textView.delegate = self
        }
    }
    
    private var pickerDueDate: DatePickerViewController?
    private var pickerStartDate: DatePickerViewController?
    
    private var navController: TaskNavigationController {
        return self.navigationController as! TaskNavigationController
    }
    
    // MARK: - RETURN VALUES
    
    // MARK: Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            if showAssigngedBy {
                return 1
            } else {
                return 0
            }
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == Table.titleSection {
            let cell = returnCell(forIdentifier: "textField", atIndexPath: indexPath) as! CustomTableViewCells
            
            cellTitle = cell; return cell
            
        } else if indexPath.section == Table.assignedBySection {
            let cell = returnCell(forIdentifier: "titleTextField", atIndexPath: indexPath) as! CustomTableViewCells
            cell.labelTitle!.text = "Assigned By"
            
            cellAssignedBy = cell; return cell
            
        } else if indexPath.section == Table.startDateSection {
            let cell = returnCell(forIdentifier: "captionSubtitle", atIndexPath: indexPath) as! CustomTableViewCells
            cell.labelCaption.text = "Start Date"
            
            cellStartDate = cell; return cell
            
        } else if indexPath.section == Table.dueDateSection {
            let cell = returnCell(forIdentifier: "captionSubtitle", atIndexPath: indexPath) as! CustomTableViewCells
            cell.labelCaption.text = "Due Date"
            
            cellDueDate = cell; return cell
            
        } else if indexPath.section == Table.prioritySection {
            let cell = returnCell(forIdentifier: "captionSubtitle", atIndexPath: indexPath) as! CustomTableViewCells
            cell.labelCaption.text = "Priority"
            
            cellPriority = cell; return cell
            
        } else {
            let cell = returnCell(forIdentifier: "captionTextView", atIndexPath: indexPath) as! CustomTableViewCells
            cell.labelCaption.text = "Notes"
            
            cellNotes = cell; return cell
        }
    }
    
    // MARK: Text Field Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder(); return true
    }
    
    // MARK: - VOID METHODS
    
    private func updateUI() {
        title = navController.task.title
        
        cellTitle.textField.text = navController.task.title
        
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "show date":
                let info = sender as! (date: Date?, time: Bool, picker: String)
                let dateVC = (segue.destination as! UINavigationController).topViewController as! DatePickerViewController
                dateVC.date = info.date
                dateVC.isTimeSet = info.time
                dateVC.delegate = self
                if info.picker == "due date" {
                    pickerDueDate = dateVC
                } else if info.picker == "start date" {
                    pickerStartDate = dateVC
                }
            default:
                break
            }
        }
    }
    
    private func dismiss() {
        if cellTitle.textField.isFirstResponder {
            cellTitle.textField.resignFirstResponder()
        }
        if cellNotes.textView.isFirstResponder {
            cellNotes.textView.resignFirstResponder()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == Table.dueDateSection {
            self.performSegue(withIdentifier: "show date", sender: (date: navController.task.dueDate, time: navController.task.dueTime, picker: "due date"))
        } else if indexPath.section == Table.startDateSection {
            self.performSegue(withIdentifier: "show date", sender: (date: navController.task.startDate, time: navController.task.startTime, picker: "start date"))
        } else if indexPath.section == Table.prioritySection {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let stringStarred = navController.task.isStarred ? "Unstar" : "Star"
            alert.addAction(UIAlertAction(title: stringStarred, style: .default, handler: { [weak self] (action) in
                self!.navController.task.isStarred.invert()
                self!.tableView.reloadSections([Table.prioritySection], with: .fade)
            }))
            alert.addAction(UIAlertAction(title: "High", style: .default, handler: { [weak self] (action) in
                self!.navController.task.priority = .High
                self!.tableView.reloadSections([Table.prioritySection], with: .fade)
            }))
            alert.addAction(UIAlertAction(title: "Medium", style: .default, handler: { [weak self] (action) in
                self!.navController.task.priority = .Medium
                self!.tableView.reloadSections([Table.prioritySection], with: .fade)
            }))
            alert.addAction(UIAlertAction(title: "Low", style: .default, handler: { [weak self] (action) in
                self!.navController.task.priority = .Low
                self!.tableView.reloadSections([Table.prioritySection], with: .fade)
            }))
            alert.addAction(UIAlertAction(title: "Unimportant", style: .default, handler: { [weak self] (action) in
                self!.navController.task.priority = .Unimportant
                self!.tableView.reloadSections([Table.prioritySection], with: .fade)
            }))
            alert.addAction(UIAlertAction(title: "None", style: .cancel, handler: { [weak self] (action) in
                self!.navController.task.priority = .None
                self!.tableView.reloadSections([Table.prioritySection], with: .fade)
            }))
            
            self.present(alert, animated: true, completion: nil)
        } else if indexPath.section == Table.notesSection {
            
        }
    }
    
    // MARK: Text Field
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == cellTitle.textField {
            if textField.text == "" {
                if hasInitialTitle == false {
                    textField.text = "Untitled Task"
                } else {
                    textField.text = navController.task.title
                }
            } else {
                hasInitialTitle = true
            }
            navController.task.title = cellTitle.textField.text
        } else if textField == cellAssignedBy.textField {
            navController.task.assignedBy = textField.text
        }
    }
    
    // MARK: Text View Delegate
    
    func textViewDidEndEditing(_ textView: UITextView) {
        navController.task.notes = textView.text
    }
    
    // MARK: Date Picker Delegate
    
    func datePicker(_ picker: DatePickerViewController, didFinishWithDate date: Date?, withTimeInterval interval: TimeInterval?) {
        if picker == pickerDueDate {
            navController.task.dueDate = date as NSDate?
            navController.task.dueTime = interval == nil ? false : true
            tableView.reloadSections([Table.dueDateSection], with: .fade)
        } else if picker == pickerStartDate {
            navController.task.startDate = date as NSDate?
            navController.task.startTime = interval == nil ? false : true
            tableView.reloadSections([Table.startDateSection], with: .fade)
        }
    }
    
    // MARK: - IBACTIONS
    
    func pressLeftNav(_ sender: Any) {
        self.dismiss()
        if navController.option == .update {
            appDelegate.saveContext()
        }
    }
    
    func pressRightNav(_ sender: Any) {
        self.dismiss()
        appDelegate.saveContext()
    }
    
    @IBAction func pressAssignedBy(_ sender: Any) {
        showAssigngedBy = true
        cellAssignedBy.textField.becomeFirstResponder()
    }
    
    @IBAction func pressDone(_ sender: Any) {
        self.dismiss()
    }
    
    // MARK: - LIFE CYCLE

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        if navController.task == nil {
            navController.option = .insert
            navController.task = Task(titleTask: "", parent: navController.parentDirectory, inContext: container.viewContext, forRole: appDelegate.currentRole)
        } else {
            navController.option = .update
            hasInitialTitle = true
        }
        
        if navController.option == .insert {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(pressLeftNav(_:)))
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(pressRightNav(_:)))
        } else if navController.option == .update {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(pressLeftNav(_:)))
        }
        if navController.task.assignedBy != nil {
            showAssigngedBy = true
        }
    }

}
