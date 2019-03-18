//
//  ShoppingListAddToolBar.swift
//  Reminder
//
//  Created by Jason on 2017/9/17.
//  Copyright © 2017年 Iowa State University Com S 309. All rights reserved.
//

import UIKit
import UserNotifications
import CoreData

/// The View manage Add feature of Shopping List
class ShoppingListAddToolBar: UIView,UITextFieldDelegate,UIPickerViewDelegate{
    
    
    
    /// context of the current program for core data
    private var context = AppDelegate.PersistentContainer.viewContext
    
    
    /// Item Name Text Field
    @IBOutlet weak var ItemName: UITextField!
        {
        didSet{
            ItemName.delegate=self
            ItemName.addToolbar(DoneButton: true, CancelButton: true, AddCategory: false)
        }
    }
    
    /// Item Amount Text Field
    @IBOutlet weak var ItemAmount: UITextField!
        {
        didSet{
            ItemAmount.delegate=self
            ItemAmount.addToolbar(DoneButton: true, CancelButton: true, AddCategory: false)
        }
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField==ItemName)
        {
            DoneButton(self)
        }
        return true
    }
    
    
    /// Unit for the add item text field
    @IBOutlet weak var Unit:UITextField!
    {
        didSet{
            Unit.delegate=self
            Unit.addToolbar(DoneButton: true, CancelButton: true, AddCategory: false)
            Unit.tintColor=UIColor.clear
        }
    }
    
    /// Due by Selection of TextField
    @IBOutlet weak var Dueby:UITextField!
    {
        didSet{
            Dueby.delegate=self
            Dueby.addToolbar(DoneButton: true, CancelButton: true, AddCategory: false)
            Dueby.tintColor=UIColor.clear
        }
    }
    
    /// Category Selection of TextField
    @IBOutlet weak var CategoryField:UITextField!
    {
        didSet{
            CategoryField.delegate=self
            CategoryField.addToolbar(DoneButton: true, CancelButton: true, AddCategory: true)
            CategoryField.tintColor=UIColor.clear
        }
    }
    
    /// Fix the target TextField if any of the were nil, reset it to default value
    ///
    /// - Parameter textField: the target textfield
    func FixTextFieldText(_ textField:UITextField)
    {

        switch textField
        {
            case Dueby:
                if(textField.text==nil || textField.text=="")
                {
                    textField.text="Need By"
                    
                }else{
                    let Formater=ReminderDateFormatter()
                    Dueby.text=Formater.string(from: NeedByDatePicker?.date ?? Date())
                }
            case CategoryField:
                if(textField.text==nil || textField.text=="")
                {
                    textField.text="Category"
                    
                }
            case Unit:
                if(textField.text==nil || textField.text=="")
                {
                    textField.text="Unit"
                }
            default:
                break
        }
        
        
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        
        FixTextFieldText(textField)
        
        return true
    }
    

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if(textField==CategoryField)
        {
            
            if let Selected = CategoryPickerView?.selectedRow(inComponent: 0){

                    CategoryField.text=ShoppingListPickerView.CategoryDorpDownInformation[Selected]
                }

        }
        
        return true
    }

    
    /// Resign All Responder so that no keyboard or input view is displaying
    ///
    /// - Parameter ExceptItemName: Exception of Item Name Text Field
    func ResignAllResponder(_ ExceptItemName:Bool){

        CategoryField.resignFirstResponder()
        Unit.resignFirstResponder()
        ItemAmount.resignFirstResponder()
        Dueby.resignFirstResponder()
        
        if(ExceptItemName==false)
        {
            ItemName.resignFirstResponder()
        }
    }
    
    /// Save the Object to CoreData and Server if possible
    func SaveObject(){
        let newItem=ShoppingListItem(context: context)
        
        newItem.itemName=ItemName.text
        
        newItem.amount=Double((ItemAmount.text ?? "1")) ?? 1.0
        
        
        if(CategoryField.text=="Category")
        {
            newItem.category="None"
        }
        else{
            newItem.category=CategoryField.text
        }
        
        
        if(Dueby.text != "Need By")
        {
            
            if(NeedByDatePicker!.date.timeIntervalSince(Date()) > (-600) && NeedByDatePicker!.date.timeIntervalSince(Date())<0)
            {
                newItem.dueDate=Date()
                newItem.dueDate?.addTimeInterval(5)
            }else{
                
                newItem.dueDate=NeedByDatePicker?.date
            }
            
        }
        
        newItem.username=ShoppingListServerObject.getUid() ?? "Default"
        
        newItem.amountUnit=Unit.text
        
        try? context.save()
        
        newItem.AddToServer()
        
        newItem.AddNotification()
    }
    
    @IBAction func DoneButton(_ sender: Any) {
        
        
        if(ItemName.hasText)
        {
            SaveObject()
            ItemAmount.text=nil
            ItemName.backgroundColor=UIColor.clear
            ItemName.text=nil
            if let _ = sender as? UIButton{
                ResignAllResponder(false)
            }else{
                ResignAllResponder(true)
            }
            

        }
        else{
            if let _ = sender as? ShoppingListAddToolBar{
            ItemName.backgroundColor=UIColor(red: 1, green: 0, blue: 0, alpha: 0.7)
            }else{
                ItemName.text=nil

            }
            
            ResignAllResponder(false)


            ResetTextField()

            
        }
        
        ItemAmount.text=nil
    }
    
    /// Reset ALl textField
    func ResetTextField()
    {
        Unit.text=nil
        Dueby.text=nil
        CategoryField.text=nil
        
        
        FixTextFieldText(Unit)
        FixTextFieldText(Dueby)
        FixTextFieldText(CategoryField)
    }

    
    /// Picker View For Unit
    var UnitPickerView:ShoppingListPickerView?
    {
        didSet{
            UnitPickerView?.delegate=self

            UnitPickerView?.backgroundColor=UIColor.white
            UnitPickerView?.showsSelectionIndicator=true
        }
    }
    
    /// Date Picker View for Need By Text Field
    var NeedByDatePicker:UIDatePicker?
    {
        didSet{
            
            NeedByDatePicker?.backgroundColor=UIColor.white
            NeedByDatePicker?.datePickerMode = .date
            
        }
    }
    
    

    /// Category Picker View for Category Selection Text Field
    var CategoryPickerView:ShoppingListPickerView?
    {
        didSet{
            CategoryPickerView?.delegate=self

            CategoryPickerView?.backgroundColor=UIColor.white
            CategoryPickerView?.showsSelectionIndicator=true
            
        }
    
    }
    

        
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let ShoppingListPicker=pickerView as! ShoppingListPickerView
        
        switch ShoppingListPicker.ShoppingListPickerViewType!
        {
            case "Unit":
                Unit.text=ShoppingListPickerView.UnitDropDownInformation[row]
                break
            case "Category":
                CategoryField.text=ShoppingListPickerView.CategoryDorpDownInformation[row]
            default: break
            
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let ShoppingListPicker=pickerView as! ShoppingListPickerView
        
        switch ShoppingListPicker.ShoppingListPickerViewType!
        {
            case "Unit":
                return ShoppingListPickerView.UnitDropDownInformation[row]
            case "Category":
                return ShoppingListPickerView.CategoryDorpDownInformation[row]
            default:
                return "No Item"
        }
    }
    
    


}
