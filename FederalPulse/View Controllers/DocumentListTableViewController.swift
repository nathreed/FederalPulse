//
//  DocumentListTableViewController.swift
//  FederalPulse
//
//  Created by Nathan Reed on 1/18/21.
//

import UIKit
import SafariServices

enum DocumentListRole {
    case frCategory
    case backlog
    case favorites
}

class DocumentListTableViewController: UITableViewController {
    
    var documentModel: DocumentList?
    var role: DocumentListRole?
    
    let feedbackGenerator = UISelectionFeedbackGenerator()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let nib = UINib(nibName: "DocumentTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "docCell")
        
        feedbackGenerator.prepare()
        
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
            cell.backlogOnlyButton.setImage(UIImage(systemName: "minus.square.fill")!.applyingSymbolConfiguration(.init(pointSize: 25)), for: .normal)
            cell.backlogOnlyButton.addTarget(self, action: #selector(backlogTapped), for: .touchUpInside)
            if(isFavorite) {
                cell.multiUseButton.setImage(UIImage(systemName: "star.fill")!.applyingSymbolConfiguration(.init(pointSize: 25)), for: .normal)
            } else {
                cell.multiUseButton.setImage(UIImage(systemName: "star")!.applyingSymbolConfiguration(.init(pointSize: 25)), for: .normal)
            }
            cell.multiUseButton.addTarget(self, action: #selector(favoritesTapped), for: .touchUpInside)
        case .favorites:
            //just a favorite/unfavorite
            //star/star.fill
            cell.backlogOnlyButton.isHidden = true
            //Since we are in favorites and we are doing cellForRow, we KNOW it must be a favorite
            cell.multiUseButton.setImage(UIImage(systemName: "star.fill")!.applyingSymbolConfiguration(.init(pointSize: 25)), for: .normal)
            cell.multiUseButton.addTarget(self, action: #selector(favoritesTapped), for: .touchUpInside)
        case .frCategory:
            //just an add/remove to/from backlog
            //plus.square.fill/minus.square.fill
            cell.backlogOnlyButton.isHidden = true
            if(isBacklog) {
                cell.multiUseButton.setImage(UIImage(systemName: "minus.square.fill")!.applyingSymbolConfiguration(.init(pointSize: 25)), for: .normal)
            } else {
                cell.multiUseButton.setImage(UIImage(systemName: "plus.square.fill")!.applyingSymbolConfiguration(.init(pointSize: 25)), for: .normal)
            }
            cell.multiUseButton.addTarget(self, action: #selector(backlogTapped), for: .touchUpInside)
        
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //self.performSegue(withIdentifier: "readDocumentFromCategory", sender: self.documentModel!.documents[indexPath.row])
        
        //Configure and present an SFSafariViewController
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        if let url = self.documentModel!.documents[indexPath.row].textURL {
            let controller = SFSafariViewController(url: url, configuration: config)
            self.present(controller, animated: true, completion: nil)
        }
        
    }
    
    @objc func favoritesTapped(sender: UIButton) {
        print("favorites!")
        self.feedbackGenerator.selectionChanged()
        let touchPoint = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: touchPoint)!
        if(self.documentModel!.documents[indexPath.row].favorite) {
            //Already is a favorite, we should de-favorite it
            sender.setImage(UIImage(systemName: "star")!.applyingSymbolConfiguration(.init(pointSize: 25)), for: .normal)
            //HACKY, looks like we can't assign to it because regular documents is get only
            self.documentModel!._documents[indexPath.row].favorite = false
            if(self.role == .some(.favorites)) {
                self.documentModel!.refresh()
            }
        } else {
            //Is not a favorite, we should favorite it
            sender.setImage(UIImage(systemName: "star.fill")!.applyingSymbolConfiguration(.init(pointSize: 25)), for: .normal)
            self.documentModel!._documents[indexPath.row].favorite = true
        }
    }
    
    @objc func backlogTapped(sender: UIButton) {
        print("backlog!")
        self.feedbackGenerator.selectionChanged()
        let touchPoint = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: touchPoint)!
        if(self.documentModel!.documents[indexPath.row].backlog) {
            //Already in backlog, remove
            sender.setImage(UIImage(systemName: "plus.square.fill")!.applyingSymbolConfiguration(.init(pointSize: 25)), for: .normal)
            print("setting false")
            self.documentModel!._documents[indexPath.row].backlog = false
            if(self.role == .some(.backlog)) {
                //Simply refresh the data model which will cause data reload when ready
                self.documentModel!.refresh()
            }
        } else {
            //Add to backlog
            sender.setImage(UIImage(systemName: "minus.square.fill")!.applyingSymbolConfiguration(.init(pointSize: 25)), for: .normal)
            print("setting true")
            self.documentModel!._documents[indexPath.row].backlog = true
        }
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
    }
    

}
