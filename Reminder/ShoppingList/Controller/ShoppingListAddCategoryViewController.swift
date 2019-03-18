//
//  ShoppingListAddCategoryViewController.swift
//  Reminder
//
//  Created by Jason on 2017/10/1.
//  Copyright © 2017年 Iowa State University Com S 309. All rights reserved.
//

import UIKit
import CoreData

/// The Controller that mandage add custom category view
class ShoppingListAddCategoryViewController: UIViewController,UITextFieldDelegate {

    private var context=AppDelegate.PersistentContainer.viewContext
    
    /// Add the user custom category from CoreData
    func AddCustomCategoryFromCoreData(){
        ShoppingListPickerView.CategoryDorpDownInformation=["None","Grocery","Apparel","Tools","Other"]
        
        let CategoryRequest:NSFetchRequest<Category>=Category.fetchRequest()
        CategoryRequest.sortDescriptors=[NSSortDescriptor(key:"title",ascending:true)]
        let Result = try? context.fetch(CategoryRequest)
        
        if(Result != nil)
        {
            
            for Object in Result! {
                
                
                ShoppingListPickerView.CategoryDorpDownInformation.append(Object.title! )
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.alpha=0.94
        InputCategoryName.becomeFirstResponder()
        CategoryView.backgroundColor=UIColor.gray

        // Do any additional setup after loading the view.
    }

    /// Dismiss the current view conrtoller
    ///
    /// - Parameter sender: Button on the screen
    @IBAction func Dismiss(_ sender: UIButton) {
        InputCategoryName.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }

    /// Text Field that allow user to input custom name for category
    @IBOutlet weak var InputCategoryName: UITextField!
        {
        didSet{
            InputCategoryName.delegate=self
        }
    }

    /// Add the custom user Category to CoreData
    ///
    /// - Parameter sender: Button in View
    @IBAction func AddAction(_ sender: UIButton) {
        InputCategoryName.resignFirstResponder()
        if(InputCategoryName.text?.isEmpty)!
        {
            CategoryView.backgroundColor=UIColor.red
            
        }else{
            CategoryView.backgroundColor=UIColor.gray
            let newCategory=Category(context: context)
            newCategory.title=InputCategoryName.text
            try? context.save()
            
            AddCustomCategoryFromCoreData()
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    /// the view that manage the window of category adding
    @IBOutlet weak var CategoryView: UIView!

    @IBAction func CancelAction(_ sender: UIButton) {
        InputCategoryName.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        CategoryView.backgroundColor=UIColor.gray
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
