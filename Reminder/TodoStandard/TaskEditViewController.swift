//
//  TaskEditViewController.swift
//  TodoStanderd
//
//  Created by Geng Sun on 9/30/17.
//  Copyright © 2017 Iowa State University. All rights reserved.
//

import UIKit
import CoreData

class TaskEditViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var context = AppDelegate.PersistentContainer.viewContext
    

    @IBOutlet weak var SharingWith: UITextField!
    
    // Creates Views
    override func viewDidLoad() {
        super.viewDidLoad()
        TaskDueDatePicker = UIDatePicker()
        Remindtimepicker = UIDatePicker()
        RepeatFrequencePickerView = UIPickerView()
        // Do any additional setup after loading the view.
    }
    // Repeat picker
    @IBOutlet weak var RepeatFrequence: UITextField!
        {
        didSet{
           RepeatFrequence.delegate = self
        }
    }

    var RepeatFrequencePickerView:UIPickerView?
    {
        didSet{
            RepeatFrequence.addToolbar(DoneButton: true, CancelButton: true, AddCategory: false)
            RepeatFrequence.inputView = RepeatFrequencePickerView
            RepeatFrequencePickerView?.dataSource=self
            RepeatFrequencePickerView?.delegate=self
        }
        
    }
  
    let frequence = ["Never","Every Day","Every Week","Week Days","Every Month","Every Year" ]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return frequence[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return frequence.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        RepeatFrequence.text = frequence[row]
    }
    
    @IBOutlet weak var AddTaskName: UITextField!{
        didSet{
            AddTaskName.delegate = self
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == AddTaskName{
            textField.resignFirstResponder()
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == AddTaskName{
              AddTaskName.backgroundColor = UIColor.clear
        }
    }
    
    
    // Remind time picker
    @IBOutlet weak var RemindTime: UITextField!
    {
        didSet{
            RemindTime.delegate = self
        }
    }

    var Remindtimepicker:UIDatePicker!
    {
        didSet{
            RemindTime.addToolbar(DoneButton: true, CancelButton: true, AddCategory: false)
            RemindTime.inputView = Remindtimepicker
        }
    }
    
    // Duedate picker
    @IBOutlet weak var TaskDueDate: UITextField!
        {
        didSet{
            TaskDueDate.delegate = self
        }
    }
    
    var  TaskDueDatePicker:UIDatePicker!
    {
        didSet{
            TaskDueDate.addToolbar(DoneButton: true, CancelButton: true, AddCategory: false)    
            TaskDueDate.inputView = TaskDueDatePicker
            TaskDueDatePicker?.datePickerMode = .date
        }
        
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == TaskDueDate{
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            dateFormatter.locale = Locale(identifier: "en_US")
            TaskDueDate.text = dateFormatter.string(from: TaskDueDatePicker.date)
        }
        else if textField == RemindTime{
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            dateFormatter.locale = Locale(identifier: "en_US")
            RemindTime.text = dateFormatter.string(from: Remindtimepicker.date)
            
        }
        return true
    }
    
    
    
    // save
    @IBAction func Save(_ sender: UIBarButtonItem) {

        if !((AddTaskName.text?.isEmpty)!) {
            let SaveTask = StandardTask(context:context)
            
        
        SaveTask.dueDate = TaskDueDatePicker.date
        SaveTask.reminderTime = Remindtimepicker.date
        SaveTask.frequence = RepeatFrequence.text
        SaveTask.taskName = AddTaskName.text
        SaveTask.username = "Default"
        SaveTask.id=Int64(StandardTaskSeverObject.AddObjectToServer(TypeOfObject: "StandardTask", Dictionary: SaveTask.ToDICT())!)
            
           try? context.save()
            
            if(SaveTask.reminderTime!.timeIntervalSinceReferenceDate > 0){
               
                LocalNotifications.AddLocalNotifications(TypeObject: "StanderTaskNotification", ObjectID: 1, Title: "String", DateTime: Date().addingTimeInterval(3))}
            else{
                
                    LocalNotifications.AddLocalNotifications(TypeObject: "StanderTaskNotification", ObjectID: 1, Title: "String", DateTime: SaveTask.reminderTime!)
                }
            
        LocalNotifications.DeleteNotifications(TypeObject: "String", ObjectID: 1)

        try? context.save()
        self.navigationController?.popViewController(animated: true)
        }
        else {
           AddTaskName.backgroundColor = UIColor.red.withAlphaComponent(0.1)
        }
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
