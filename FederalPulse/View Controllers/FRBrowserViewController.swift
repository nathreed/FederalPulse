//
//  FRBrowserViewController.swift
//  FederalPulse
//
//  Created by Nathan Reed on 1/18/21.
//

import UIKit

class FRBrowserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var counts = [0, 0, 0, 0]
    let titles = ["Notices", "Proposed Rules", "Rules", "Presidential Documents"]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Federal Register"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.loadCategoryCounts()
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
        self.loadCategoryCounts()
    }
    
    //This function starts API calls to the endpoints to update the counts for each category, which are then filled in by the callback.
    //Struct is used for receiving the results
    struct CountAPIDetails: Decodable {
        var count: Int
        var name: String
    }
    
    func loadCategoryCounts() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: self.datePicker.date)
        
        let baseAPIUrl = "https://www.federalregister.gov/api/v1/documents/facets/daily?conditions%5Bpublication_date%5D%5Bis%5D=\(dateString)&conditions%5Btype%5D%5B%5D="
        
        let constants = ["NOTICE", "PRORULE", "RULE", "PRESDOCU"]
        for i in 0...3 {
            let taskAPIUrl = baseAPIUrl + constants[i]
            if let url = URL(string: taskAPIUrl) {
                let task = URLSession(configuration: .default).dataTask(with: url) { (data, resp, err) in
                    guard let respData = data else {
                        print("count errror")
                        return
                    }
                    let decoder = JSONDecoder()
                    
                    do {
                        let results = try decoder.decode([String: CountAPIDetails].self, from: respData)
                        if let actualCount = results[dateString] {
                            self.counts[i] = actualCount.count
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                        
                    } catch {
                        print("decode error \(error)")
                    }
                    
                }
                task.resume()
            }
            
        }
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
