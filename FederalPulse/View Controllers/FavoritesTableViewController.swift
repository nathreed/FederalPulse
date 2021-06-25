//
//  FavoritesTableViewController.swift
//  FederalPulse
//
//  Created by Nathan Reed on 1/18/21.
//

import UIKit

class FavoritesTableViewController: DocumentListTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Favorites"
        self.role = .favorites
        let model = Favorites()
        model.registerLoadingDoneCallback {
            print("favorites done loading!")
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
