//
//  StandardTaskCell.swift
//  TodoStanderd
//
//  Created by Geng Sun on 10/7/17.
//  Copyright © 2017 Iowa State University. All rights reserved.
//

import UIKit

class StandardTaskCell: UITableViewCell {
    @IBOutlet weak var TaskName: UILabel!
    @IBOutlet weak var Data: UILabel!
    @IBOutlet weak var TimeLeft: UILabel!
    
    
    @IBOutlet weak var repeatFreqence: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
