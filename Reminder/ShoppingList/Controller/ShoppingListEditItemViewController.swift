//
//  ShoppingListEditItemViewController.swift
//  Reminder
//
//  Created by Jason on 2017/9/30.
//  Copyright © 2017年 Iowa State University Com S 309. All rights reserved.
//

import UIKit
import CoreData


/// View Controller that managed the Edit Item for Shopping List
class ShoppingListEditItemViewController: ReminderStandardViewController,UIPickerViewDelegate,UITextFieldDelegate {

    private let context = AppDelegate.PersistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ParseItem()
        UnitPickerView=ShoppingListPickerView(Type: "Unit")
        CategoryPickerView=ShoppingListPickerView(Type:"Category")
        
        NeedByDatePicker=UIDatePicker()
        NeedByDatePicker?.date=Date(timeIntervalSince1970: (EditItem?.dueDate?.timeIntervalSince1970) ?? Date().timeIntervalSince1970)
            
        TextFieldBoarderColor=ItemNameView.backgroundColor
        
        CategoryToolBar = Category.inputAccessoryView as?UIToolbar
        // Do any additional setup after loading the view.
    }

    /// turn the object into information needed for the view controller
    private func ParseItem(){
        ItemName.text=EditItem?.itemName
        if let intAmount=(EditItem?.amount ?? 1).toInt()
        {
            Amount.text=String(describing: intAmount)
        }else{
            Amount.text=String(describing: (EditItem?.amount ?? 1))
        }
        
        Unit.text=EditItem?.amountUnit
        Category.text=EditItem?.category
        
        if(EditItem?.dueDate == nil)
        {
            NeedBy.text="Optional Input"
            DeleteNeedByDateButton.isHidden=true
        }
        else{
            let Formater=ReminderDateFormatter()

            DeleteNeedByDateButton.isHidden=false
            
            NeedBy.text=Formater.string(from: (EditItem?.dueDate! as Date?)!)
        }
        

        
    }
    
    /// Category ToolBar that would use for done cancel and add custoom category
    var CategoryToolBar:UIToolbar?
    {
        didSet{
            CategoryToolBar!.items![2].action=#selector(AddCategorySegue)
        }
    }
    
    @objc private func AddCategorySegue(){
        performSegue(withIdentifier: "AddCategoryFromEdit", sender: self)
        Category.becomeFirstResponder()
    }
    
    @IBAction private func SaveAction(_ sender: UIBarButtonItem) {
        if(ItemName.text?.isEmpty)!
        {
            ItemNameView.backgroundColor=UIColor.red
        }else
        {
            ItemNameView.backgroundColor=TextFieldBoarderColor
            
            SaveChanges()
            
            if(!(EditItem?.UpdateToServer())!)
            {
                print("Offline Edit")
            }
            EditItem?.updateDate=Date()
            EditItem?.updateDate?.addTimeInterval(-5*60*60)
            try? context.save()
            self.navigationController?.popViewController(animated: true)
            
        }
    }
    
    /// Saves the Changes that user have made
    func SaveChanges()
    {
        EditItem?.itemName=ItemName.text
        EditItem?.amount = Double(Amount.text ?? "1.0")!
        EditItem?.amountUnit=Unit.text
        EditItem?.category=Category.text
        
        
        LocalNotifications.DeleteNotifications(TypeObject: "ShoppingList", ObjectID: Int(EditItem!.id))
        if(NeedBy.text=="Optional Input")
        {
            EditItem?.dueDate=nil
            
        }
        else{
            EditItem?.dueDate=NeedByDatePicker?.date
            
            EditItem?.AddNotification()
        }
        
    }
    
    @IBOutlet private weak var DeleteNeedByDateButton: UIButton!
    
    
    
    /// Delete the Need By Date
    ///
    /// - Parameter sender: button on view
    @IBAction func DeleteNeedByDate(_ sender: UIButton) {
        NeedBy.text="Optional Input"
        DeleteNeedByDateButton.isHidden=true
    }

    
    /// The Core Data Item of Current Editting Item
    var EditItem:ShoppingListItem?
    
    private var TextFieldBoarderColor:UIColor?
    
    /// UI View for Item Name
    @IBOutlet weak var ItemNameView: UIView!
    

    
    /// UI View for Amount View
    @IBOutlet weak var AmountView: UIView!
    
    
    /// Ui View for Category View
    @IBOutlet weak var CategoryView: UIView!
    
    
    /// Ui View for needby view
    @IBOutlet weak var NeedByView: UIView!
    
    
    /// Text Field For Item Name
    @IBOutlet weak var ItemName: UITextField!
    {
        didSet{
            ItemName.delegate=self
            ItemName.delegate=self
        }
    }
    
    /// Text Field For Amount
    @IBOutlet weak var Amount: UITextField!
    {
        didSet{
            Amount.addToolbar(DoneButton: true, CancelButton: true, AddCategory: false)
        }
    }
    
    /// Text Field For Unit
    @IBOutlet weak var Unit: UITextField!
    {
        didSet{
            Unit.addToolbar(DoneButton: true, CancelButton: true, AddCategory: false)
            Unit.delegate=self
            Unit.tintColor = UIColor.clear
        }
    }
    
    
    /// Text Field For Category
    @IBOutlet weak var Category: UITextField!
    {
        didSet{
            Category.delegate=self
            Category.addToolbar(DoneButton: true, CancelButton: true, AddCategory: true)
            Category.tintColor = UIColor.clear
        }
    }
    
    
    /// Text Field For Need By
    @IBOutlet weak var NeedBy: UITextField!
    {
        didSet{
            NeedBy.addToolbar(DoneButton: true, CancelButton: true, AddCategory: false)
            NeedBy.delegate=self
            NeedBy.tintColor = UIColor.clear
        }
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField==ItemName)
        {
            textField.resignFirstResponder()
            if(!(textField.text?.isEmpty)!)
            {
                ItemNameView.backgroundColor=TextFieldBoarderColor
            }
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        
        switch textField
        {

        case NeedBy:
            let Formater=ReminderDateFormatter()
            
            if(textField.text==nil || textField.text=="")
            {
                if(EditItem?.dueDate == nil)
                {
                    NeedBy.text="Optional Input"
                    return true
                }
                NeedBy.text=Formater.string(from: (EditItem?.dueDate! as Date?)!)
                return true
            }
            NeedBy.text=Formater.string(from: NeedByDatePicker?.date ?? Date())
            DeleteNeedByDateButton.isHidden=false
            
        case Category:
            if(textField.text==nil || textField.text=="")
            {
                textField.text=EditItem?.category
                
            }
        case Unit:
            if(textField.text==nil || textField.text=="")
            {
                textField.text=EditItem?.amountUnit
            }
        case Amount:
            if (textField.text==nil || textField.text=="")
            {
                if let intAmount=(EditItem?.amount ?? 1).toInt()
                {
                    Amount.text=String(describing: intAmount)
                }else{
                    Amount.text=String(describing: (EditItem?.amount ?? 1))
                }
            }
        case ItemName:
            if(!(textField.text?.isEmpty)!)
            {
                ItemNameView.backgroundColor=TextFieldBoarderColor
            }
        default:
            break
        }
        
        

        return true
    }
    
    
    
    var UnitPickerView:ShoppingListPickerView?
    {
        didSet{
            UnitPickerView?.delegate=self
            Unit.inputView=UnitPickerView
        }
    }
    
    var CategoryPickerView:ShoppingListPickerView?
    {
        didSet{
            CategoryPickerView?.delegate=self
            Category.inputView=CategoryPickerView
        }
    }
    
    var NeedByDatePicker:UIDatePicker?
    {
        didSet{
            NeedByDatePicker?.datePickerMode = .date
            NeedBy.inputView=NeedByDatePicker

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
                Category.text=ShoppingListPickerView.CategoryDorpDownInformation[row]
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
    
    // MARK: - Navigation
/*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
*/
}
