//
//  GroupMemberTableViewCell.swift
//  Reminder
//
//  Created by Jason on 2017/12/2.
//  Copyright © 2017年 Yijia Huang. All rights reserved.
//

import UIKit

class GroupMemberTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var ProfliePictureView: DesignableView!
    
    @IBOutlet weak var Name: UILabel!
    
    @IBOutlet weak var Selection: BEMCheckBox!
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
