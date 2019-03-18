//
//  ExpenseTableViewCell.swift
//  ExpenseTracker
//
//  Created by Bei Zhao on 11/25/17.
//  Copyright © 2017 Bei Zhao. All rights reserved.
//

import UIKit

class ExpenseTableViewCell: UITableViewCell {

    @IBOutlet weak var CategoryImage: UIImageView!
    @IBOutlet weak var ItemCategory: UILabel!
    @IBOutlet weak var ItemCost: UILabel!
    @IBOutlet weak var ItemDescription: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
