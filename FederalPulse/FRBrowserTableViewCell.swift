//
//  FRBrowserTableViewCell.swift
//  FederalPulse
//
//  Created by Nathan Reed on 1/18/21.
//

import UIKit

class FRBrowserTableViewCell: UITableViewCell {
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //Set corner radius on count label
        self.countLabel.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
