//
//  ShoppingListItemCellTableViewCell.swift
//  Reminder
//
//  Created by Jason on 2017/9/10.
//  Copyright © 2017年 Iowa State University Com S 309. All rights reserved.
//

import UIKit
import CoreData

/// The Tepmlate cell for displaying Shopping List Item
class ShoppingListItemCellTableViewCell: UITableViewCell,BEMCheckBoxDelegate {

    /// Item From the CoreData corrsbonding to this edit
    var Item:ShoppingListItem?


    

    @objc func MarkDone()
    {
        Item!.done = !Item!.done
        
        
        
        if(!(Item?.UpdateToServer())!)
        {
            print("Cannt Update To Server")
        }
        
        Item?.updateDate=Date()
        Item?.updateDate?.addTimeInterval(-60*60*5)
        
        
        try? AppDelegate.PersistentContainer.viewContext.save()
        
        
    }
    private var context=AppDelegate.PersistentContainer.viewContext
    
    /// Label for Dispalying Item Name
    @IBOutlet weak var ItemName: UILabel!
    
    /// Label to display the time reminding for the Item
    @IBOutlet weak var NeedBy: UILabel!
    
    /// Label to display the amount and unit
    @IBOutlet weak var AmountAndUnit: UILabel!
    {
        didSet{
            AmountAndUnit.alpha = 0.6
        }
    }
    
    /// Check Mark that display and control the done state for the Item
    @IBOutlet weak var CheckMark: BEMCheckBox!
    {
        didSet{
            CheckMark.delegate=self
            
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    
    /// Get Call when user tap a cetain check box that is managed by this current class object
    ///
    /// - Parameter checkBox: The Check Box
    func didTap(_ checkBox: BEMCheckBox) {
        MarkDone()
    }

    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
