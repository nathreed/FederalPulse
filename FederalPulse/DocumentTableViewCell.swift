//
//  DocumentTableViewCell.swift
//  FederalPulse
//
//  Created by Nathan Reed on 1/18/21.
//

import UIKit

class DocumentTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var agenciesLabel: UILabel!
    @IBOutlet weak var multiUseButton: UIButton!
    @IBOutlet weak var backlogOnlyButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        //Remove all targets from both buttons
        let multiUseTargets = self.multiUseButton.allTargets
        multiUseTargets.forEach { (target) in
            self.multiUseButton.removeTarget(target, action: nil, for: .touchUpInside)
        }
        
        let backlogTargets = self.backlogOnlyButton.allTargets
        backlogTargets.forEach { (target) in
            self.backlogOnlyButton.removeTarget(target, action: nil, for: .touchUpInside)
        }
        
        //Unhide both buttons
        self.backlogOnlyButton.isHidden = false
        self.multiUseButton.isHidden = false
    }
    
}
