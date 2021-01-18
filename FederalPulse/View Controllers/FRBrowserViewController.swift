//
//  FRBrowserViewController.swift
//  FederalPulse
//
//  Created by Nathan Reed on 1/18/21.
//

import UIKit

class FRBrowserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let counts = [999, 999, 999, 999]
    let titles = ["Notices", "Proposed Rules", "Rules", "Presidential Documents"]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Federal Register"
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "frBrowserCell") as! FRBrowserTableViewCell
        cell.categoryLabel.text = self.titles[indexPath.row]
        cell.countLabel.text = " \(self.counts[indexPath.row]) "
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var docType: FRAPIDocumentType
        switch(self.titles[indexPath.row]) {
        case "Notices":
            docType = .notice
        case "Proposed Rules":
            docType = .proposedRule
        case "Rules":
            docType = .rule
        case "Presidential Documents":
            docType = .presidentialDocument
        default:
            docType = .notice
        }
        let configuration = FRAPIDocumentListConfiguration(docType: docType, searchDate: self.datePicker.date)
        self.performSegue(withIdentifier: "browseCategory", sender: configuration)
    }
    
    
    
    @IBAction func dateChanged(_ sender: Any) {
        //TODO: make calls to API to get count of each category
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! FRBrowserCategoryTableViewController
        dest.role = .frCategory
        let config = sender as! FRAPIDocumentListConfiguration
        dest.config = config
    }
    

}
