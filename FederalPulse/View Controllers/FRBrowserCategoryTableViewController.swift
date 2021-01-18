//
//  FRBrowserCategoryTableViewController.swift
//  FederalPulse
//
//  Created by Nathan Reed on 1/18/21.
//

import UIKit

class FRBrowserCategoryTableViewController: DocumentListTableViewController {
    
    var config: FRAPIDocumentListConfiguration?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch(self.config?.docType) {
        case .none:
            self.title = "Error"
        case .notice:
            self.title = "Notices"
        case .proposedRule:
            self.title = "Proposed Rules"
        case .rule:
            self.title = "Rules"
        case .presidentialDocument:
            self.title = "Presidential Documents"
        }
        
        //Create the model and get it going
        let model = FRAPIDocumentList()
        model.setConfiguration(config: self.config!)
        model.registerLoadingDoneCallback {
            print("model done loading!")
            print(model.documents)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        model.refresh()
        self.documentModel = model
        
    }


}
