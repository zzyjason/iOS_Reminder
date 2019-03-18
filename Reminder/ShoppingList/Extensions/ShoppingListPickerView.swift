//
//  ShoppingListPickerView.swift
//  Reminder
//
//  Created by Jason on 2017/9/30.
//  Copyright © 2017年 Iowa State University Com S 309. All rights reserved.
//

import UIKit
import CoreData
class ShoppingListPickerView: UIPickerView,UIPickerViewDataSource,UIPickerViewDelegate{

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    static var context=AppDelegate.PersistentContainer.viewContext
    
    static func addCustomCategory()
    {
        ShoppingListPickerView.CategoryDorpDownInformation=["None","Grocery","Apparel","Tools","Other"]
        
        let CategoryRequest:NSFetchRequest<Category>=Category.fetchRequest()
        CategoryRequest.sortDescriptors=[NSSortDescriptor(key:"title",ascending:true)]
        let Result = try? context.fetch(CategoryRequest)
        
        if(Result != nil)
        {
            
            for Object in Result! {
                
                ShoppingListPickerView.CategoryDorpDownInformation.append(Object.title!)
            }
            
        }
    }
    
    var ShoppingListPickerViewType:String?
    
    init(Type:String)
    {
        super.init(frame: CGRect())
        ShoppingListPickerViewType=Type

        self.dataSource=self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    static var UnitDropDownInformation=["Unit","g","Kg","Pound","Oz","Cup","Gallon","mL","L"]
    
    static var CategoryDorpDownInformation=["None","Grocery","Apparel","Tools","Other"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        let ShoppingListPicker=pickerView as! ShoppingListPickerView
        
        switch ShoppingListPicker.ShoppingListPickerViewType!
        {
        case "Unit":
            return 1
        case "Category":
            return 1
        default:
            return 1
        }
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        let ShoppingListPicker=pickerView as! ShoppingListPickerView
        
        switch ShoppingListPicker.ShoppingListPickerViewType!
        {
        case "Unit":

            return ShoppingListPickerView.UnitDropDownInformation.count
        case "Category":
 
            return ShoppingListPickerView.CategoryDorpDownInformation.count
        default:
            return 1
        }
    }
    
    
    
    

    
}
