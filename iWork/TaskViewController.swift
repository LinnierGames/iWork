//
//  TaskViewController.swift
//  iWork
//
//  Created by Erick Sanchez on 7/4/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import UIKit

class TaskViewController: UITableViewController, UITextFieldDelegate {
    
    private var hasInitialTitle = false
    
    private var cellTitle: CustomTableViewCells! {
        didSet {
            cellTitle.textField!.text = navController.task.title
            if navController.option == .insert {
                cellTitle.textField!.becomeFirstResponder()
                cellTitle.textField!.placeholder = "New Task Title"
            } else {
                cellTitle.textField!.placeholder = "Title"
            }
            
            NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange(_:)), name: .UITextFieldTextDidChange, object: cellTitle.textField!)
        }
    }
    
    private var navController: TaskNavigationController {
        return self.navigationController as! TaskNavigationController
    }
    
    // MARK: - RETURN VALUES
    
    // MARK: Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textField", for: indexPath) as! CustomTableViewCells
            
            cell.textField!.delegate = self
            
            cellTitle = cell; return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleSegment", for: indexPath) as! CustomTableViewCells
            
            return cell
            
        }
    }
    
    // MARK: Text Field Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder(); return true
    }
    
    // MARK: - VOID METHODS
    
    private func updateUI() {
        title = navController.task.title
        
        cellTitle.textField!.text = navController.task.title
        
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    private func dismiss() {
        if cellTitle.textField!.isFirstResponder {
            cellTitle.textField!.resignFirstResponder()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Text Field
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            if hasInitialTitle == false {
                textField.text = "Untitled Task"
            } else {
                textField.text = navController.task.title
            }
        } else {
            hasInitialTitle = true
        }
        navController.task.title = cellTitle.textField!.text
    }
    
    func textFieldDidChange(_ note: Notification) {
        _ = (note.object as! UITextField)
    }
    
    // MARK: - IBACTIONS
    
    func pressLeftNav(_ sender: Any) {
        if navController.option == .update {
            appDelegate.saveContext()
        }
        self.dismiss()
    }
    
    func pressRightNav(_ sender: Any) {
        appDelegate.saveContext()
        self.dismiss()
    }
    
    @IBAction func pressDone(_ sender: Any) {
        self.dismiss()
    }
    
    // MARK: - LIFE CYCLE

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if navController.task == nil {
            navController.option = .insert
            navController.task = Task(parent: navController.parentDirectory, context: container.viewContext, forRole: appDelegate.currentRole)
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if navController.option == .insert {
        }
    }

}
