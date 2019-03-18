//
//  UITextField Extension.swift
//  Student Tool
//
//  Created by Jason on 2017/9/2.
//  Copyright © 2017年 N/A. All rights reserved.
//

import Foundation
import UIKit

extension UITextField
{
    func addToolbar(DoneButton:Bool,CancelButton:Bool,AddCategory:Bool)->Void{
        
        let toolbar=UIToolbar()
        
        let Done=(target:self,action:#selector(DoneButtonTapped))
        let Cancel=(target:self,action:#selector(CancelButtonTapped))
        let AddCategoryButton=(target:self,action:#selector(AddCategoryTapped))
        
        if(DoneButton && CancelButton && !AddCategory)
        {
            toolbar.items=[UIBarButtonItem(title: "Cancel", style: .plain, target: Cancel, action: Cancel.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: Done, action: Done.action)]
            
        }else if(DoneButton && CancelButton && AddCategory){
            
            toolbar.items=[UIBarButtonItem(title: "Cancel", style: .plain, target: Cancel, action: Cancel.action),
                           UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
                           UIBarButtonItem(title: "Add Category", style: .plain, target: AddCategoryButton, action: AddCategoryButton.action),
                           UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
                           UIBarButtonItem(title: "Done", style: .done, target: Done, action: Done.action)]
            
        }else if(DoneButton && !CancelButton && !AddCategory)
        {
            toolbar.items=[
                           UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
                           UIBarButtonItem(title: "Done", style: .done, target: Done, action: Done.action)]
        }
        
        toolbar.sizeToFit()
        self.inputAccessoryView=toolbar
    }
    

    @objc func CancelButtonTapped() {
        self.text=nil

        self.resignFirstResponder()
    }
    @objc func DoneButtonTapped(){
        
        self.resignFirstResponder()
        
    }
    @objc func AddCategoryTapped(){
        //require overrding to segue

    }
    

    
    

}
