//
//  DocumentListTableViewController.swift
//  FederalPulse
//
//  Created by Nathan Reed on 1/18/21.
//

import UIKit

enum DocumentListRole {
    case frCategory
    case backlog
    case favorites
}

class DocumentListTableViewController: UITableViewController {
    
    var documentModel: DocumentList?
    var role: DocumentListRole?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let nib = UINib(nibName: "DocumentTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "docCell")
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.documentModel?.documents.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "docCell", for: indexPath) as! DocumentTableViewCell

        cell.titleLabel.text = self.documentModel!.documents[indexPath.row].title
        cell.agenciesLabel.text = self.documentModel!.documents[indexPath.row].agencies
        
        let isBacklog = self.documentModel!.documents[indexPath.row].backlog
        let isFavorite = self.documentModel!.documents[indexPath.row].favorite
        
        //Set up the button based on what role we are in
        switch(role) {
        case .none:
            fatalError()
        case .backlog:
            //remove from backlog and favorite/unfavorite buttons to set up
            //We KNOW it's in the backlog
            cell.backlogOnlyButton.setImage(UIImage(systemName: "minus.square.fill"), for: .normal)
            cell.backlogOnlyButton.addTarget(self, action: #selector(backlogTapped), for: .touchUpInside)
            if(isFavorite) {
                cell.multiUseButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            } else {
                cell.multiUseButton.setImage(UIImage(systemName: "star"), for: .normal)
            }
            cell.multiUseButton.addTarget(self, action: #selector(favoritesTapped), for: .touchUpInside)
        case .favorites:
            //just a favorite/unfavorite
            //star/star.fill
            cell.backlogOnlyButton.isHidden = true
            //Since we are in favorites and we are doing cellForRow, we KNOW it must be a favorite
            cell.multiUseButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            cell.multiUseButton.addTarget(self, action: #selector(favoritesTapped), for: .touchUpInside)
        case .frCategory:
            //just an add/remove to/from backlog
            //plus.square.fill/minus.square.fill
            cell.backlogOnlyButton.isHidden = true
            if(isBacklog) {
                cell.multiUseButton.setImage(UIImage(systemName: "minus.square.fill"), for: .normal)
            } else {
                cell.multiUseButton.setImage(UIImage(systemName: "plus.square.fill"), for: .normal)
            }
            cell.multiUseButton.addTarget(self, action: #selector(backlogTapped), for: .touchUpInside)
        
        }

        return cell
    }
    
    @objc func favoritesTapped() {
        print("favorites!")
    }
    
    @objc func backlogTapped() {
        print("backlog!")
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
