//
//  UtilitiesTableViewController.swift
//  iWork
//
//  Created by Erick Sanchez on 7/11/17.
//  Copyright © 2017 Erick Sanchez. All rights reserved.
//

import UIKit

class UtilitiesTableViewController: UITableViewController {
    
    private struct Feature {
        var title: String
        var subtitle: String?
        var footer: String?
        var header: String?
    }
    
    private let features = [
        Feature(title: "Punch Clock", subtitle: "Keep track of all of your punches", footer: "Each shift is saved under its employer and sorted by date of the shift", header: nil),
        Feature(title: "Timers", subtitle: nil, footer: nil, header: nil),
        Feature(title: "Alarms", subtitle: "Save reusable alarms", footer: "Create collections of alarms and enable them on any given day", header: nil)
    ]
    
    // MARK: - RETURN VALUES
    
    // MARK: Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return features.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return features[section].header
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return features[section].footer
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let feature = features[indexPath.section]
        cell.textLabel!.text = feature.title
        cell.detailTextLabel!.text = feature.subtitle
        
        return cell
    }
    
    // MARK: - VOID METHODS
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
}
