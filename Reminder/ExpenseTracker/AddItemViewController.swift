//
//  AddItemViewController.swift
//  ExpenseTracker
//
//  Created by Bei Zhao on 11/25/17.
//  Copyright © 2017 Bei Zhao. All rights reserved.
//

import UIKit

class AddItemViewController: ReminderStandardViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
   // @IBOutlet weak var Category: UITextField!
    
    @IBOutlet weak var Cost: UITextField!
    @IBOutlet weak var Content: UITextField!
    @IBOutlet weak var Category: UILabel!
    @IBOutlet weak var CategorypickerView: UIPickerView!
    
   let categorys = ["Clothes", "Food", "Furniture", "Makeup", "Sports", "Transportation", "Others"]
    
    //Implement the picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categorys[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categorys.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        Category.text = categorys[row]
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    //Action Editing
    @IBAction func btnTapped(_ sender: Any) {
        
       let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
       let item = EItem(context: context)
       item.category = Category.text!
       item.content = Content.text!
        
        if (Cost.text?.isEmpty)!{
            item.cost = 0.0
        }else{
       item.cost = Double(Cost.text!)!
        }
        
       //Save the data to coredata
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func checkEnteringContent(){
        
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
