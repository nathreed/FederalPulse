//
//  BacklogTableViewController.swift
//  FederalPulse
//
//  Created by Nathan Reed on 1/18/21.
//

import UIKit

class BacklogTableViewController: DocumentListTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.title = "Backlog"
        self.role = .backlog
        let model = Backlog()
        model.registerLoadingDoneCallback {
            print("Backlog load done!")
            print(model.documents)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        self.documentModel = model
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }

    override func viewWillAppear(_ animated: Bool) {
        self.documentModel?.refresh()
    }

}
