//
//  ShoppingListMainViewController.swift
//  Reminder
//
//  Created by Jason on 2017/9/10.
//  Copyright © 2017年 Iowa State University Com S 309. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

/// Main View Conrtoller for shopping List
class ShoppingListMainViewController: ReminderStandardViewController,UITableViewDelegate{


    override func viewDidLoad() {
        super.viewDidLoad()
        

        self.transitioningDelegate=nil
        
        MainTableViewController.refreshController=UIRefreshControl()
        
        
        MainTableViewController.tableView.refreshControl=MainTableViewController.refreshController
        MainTableViewController.refreshControl=MainTableViewController.refreshController
        
        
        
        

        
        

        
        
        navigationBarCGSize=navigationController?.navigationBar.frame
        
        AddToolBar.UnitPickerView=ShoppingListPickerView(Type: "Unit")
        

        
        AddToolBar.Unit.inputView=AddToolBar.UnitPickerView
        
        AddToolBar.CategoryPickerView=ShoppingListPickerView(Type: "Category")
        AddToolBar.CategoryField.inputView=AddToolBar.CategoryPickerView
        
        AddToolBar.NeedByDatePicker=UIDatePicker()
        AddToolBar.Dueby.inputView=AddToolBar.NeedByDatePicker
        AddToolBar.isHidden=true
        AddToolBar.frame=CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
        // Do any additional setup after loading the view.
        
        
        
        CategoryToolBar = AddToolBar.CategoryField.inputAccessoryView as?UIToolbar
        
    }
    
    
    private var MainTableViewController:ShoppingListTableViewController = ShoppingListTableViewController()
    
    private var context = AppDelegate.PersistentContainer.viewContext

    private var navigationBarCGSize:CGRect?
    
    private var CategoryToolBar:UIToolbar?
    {
        didSet{

            CategoryToolBar!.items![2].action=#selector(AddCategorySegue)
            
        }
    }
    
    /// Segue to Add Category View Controller
    @objc func AddCategorySegue(){

        performSegue(withIdentifier: "AddCategoryFromMain", sender: self)
        
    }
    
    
    
    /// Add Action Done by Add Tool Bar
    ///
    /// - Parameter sender: A Bar Button Item display on view
    @IBAction func AddAction(_ sender: UIBarButtonItem) {
        
        


            self.navigationController?.navigationBar.isHidden=true

            UIApplication.shared.isStatusBarHidden=true
        
            self.FixTableViewSizeAndAddToolBar(isAddToolBarHidding: false)
        
            self.AddToolBar.ItemName.becomeFirstResponder()



        
    }

    /// Done button is push by Addtool bar
    ///
    /// - Parameter sender: button display on view
    @IBAction func DoneButtonPushed(_ sender: UIButton) {
        FixTableViewSizeAndAddToolBar(isAddToolBarHidding: true)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section==0)
        {
            return 28
            
        }
        
        return 28
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        
        
        let Delete=UITableViewRowAction(style: .normal, title: "Delete", handler: DeleteShoppingItem)
        Delete.backgroundColor=UIColor.red
        
        return [Delete]
    }
    
    /// Delete the Shopping List Item depends on the row of tableview
    ///
    /// - Parameters:
    ///   - Action: Action
    ///   - row: row of the table view
    func DeleteShoppingItem(_ Action:UITableViewRowAction,row:IndexPath)->Void{
        
        let ToDeleteCoreDataObject=MainTableViewController.fetchedResultController!.sections?[row.section].objects?[row.row] as! ShoppingListItem
        if(ToDeleteCoreDataObject.DeleteFromServer())
        {
            context.delete(ToDeleteCoreDataObject)
            print("Deleted In Server")
        }else{
            ToDeleteCoreDataObject.offLineDeleted=true
            print("Offline Delete")
        }

        try? context.save()
        
    }
    
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        

        if let SectionColor=ReminderStandardViewController.GetCurrentBackGroundThemeColor().SubColor
        {


            (view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor=SectionColor

        }
        

    }

    
    
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let MarkDoneAction=UIContextualAction(style: .normal, title: "Mark Done") { (Action, View, completionHandler: (Bool) -> Void) in
            let Cell=tableView.cellForRow(at: indexPath) as! ShoppingListItemCellTableViewCell
            Cell.MarkDone()
            completionHandler(true)
        }
        
        let swipeConfig=UISwipeActionsConfiguration(actions: [MarkDoneAction])
        return swipeConfig
    }
    

    
    
    private var ToEditItem:ShoppingListItem?
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: false)
        ToEditItem=MainTableViewController.fetchedResultController?.sections?[indexPath.section].objects?[indexPath.row] as? ShoppingListItem

        performSegue(withIdentifier: "EditShoppingListItem", sender: self)

    }
    

    
    
    /// Add Tool bar for Main View Controller
    @IBOutlet weak var AddToolBar: ShoppingListAddToolBar!

    
    @IBOutlet weak var ShoppingListItemTableView: UITableView!
    {
        didSet{
            MainTableViewController.tableView=ShoppingListItemTableView
        }
    }
    
    
    
    /// Fix the size of Add Tooll bar and table View
    ///
    /// - Parameter isAddToolBarHidding: Add Tool Bar Hidding State
    func FixTableViewSizeAndAddToolBar(isAddToolBarHidding:Bool)
    {

        if(isAddToolBarHidding)
        {
            
            AddToolBar.frame=AddToolBar.frame.offsetBy(dx: 0, dy: -AddToolBar.frame.height)
            
            navigationController?.navigationBar.frame=CGRect(x: 0, y: 20, width: navigationBarCGSize!.width, height: navigationBarCGSize!.height)

            AnimateAddToolBar(isAddToolBarHidding: isAddToolBarHidding)

            MainTableViewController.tableView.frame=CGRect(x: 0, y: (navigationController?.navigationBar.frame.maxY)!, width: (navigationController?.navigationBar.frame.maxX)!, height: (view.frame.height-(navigationController?.navigationBar.frame.height)!-20))

        }
        else{
            
            AddToolBar.isHidden=false
            
            AnimateAddToolBar(isAddToolBarHidding: isAddToolBarHidding)

            
            self.MainTableViewController.tableView.frame=CGRect(x: 0, y: self.AddToolBar.frame.maxY, width: (self.navigationController?.navigationBar.frame.maxX)!, height: self.view.frame.height-(self.AddToolBar.frame.height))
            
        }
    }
    
    /// Animate Add Tool Bar
    ///
    /// - Parameter isAddToolBarHidding: Add Tool Bar Hidding State
    func AnimateAddToolBar(isAddToolBarHidding:Bool)
    {
        if(isAddToolBarHidding)
        {
            
            
            
            MainTableViewController.tableView.transform=CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 0, ty: MainTableViewController.tableView.frame.minY-navigationController!.navigationBar.frame.maxY)
            
            AddToolBar.transform=CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 0, ty: AddToolBar.frame.height)
            
            UIView.animate(withDuration: 0.2, delay: 0, options:.curveLinear, animations: {
                
                self.MainTableViewController.tableView.transform=CGAffineTransform.identity
                self.AddToolBar.transform=CGAffineTransform.identity
                
            }) { (success) in
                
                
                self.AddToolBar.isHidden=true
                
                self.AddToolBar.frame=self.AddToolBar.frame.offsetBy(dx: 0, dy: +self.AddToolBar.frame.height)
                
                self.navigationController?.navigationBar.isHidden=false

                
                UIApplication.shared.isStatusBarHidden=false

                
            }

        }
        else{
            MainTableViewController.tableView.transform=CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 0, ty: MainTableViewController.tableView.frame.minY-AddToolBar.frame.maxY)
            AddToolBar.transform=CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 0, ty: -AddToolBar.frame.height)
            
            UIView.animate(withDuration: 0.2, delay: 0, options:.curveLinear, animations: {
                self.MainTableViewController.tableView.transform=CGAffineTransform.identity
                self.AddToolBar.transform=CGAffineTransform.identity
            }) { (success) in
                
            }
        }
    }
    
    



    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier=="EditShoppingListItem")
        {
            self.AddToolBar.isHidden=true
            AddToolBar.ItemName.resignFirstResponder()
            
            FixTableViewSizeAndAddToolBar(isAddToolBarHidding: true)

            let EditView = segue.destination as! ShoppingListEditItemViewController
            EditView.EditItem=ToEditItem
            
            ToEditItem=nil

            AddToolBar.ResignAllResponder(true)


        }
        
        if(segue.identifier=="ShoppingListToMenu")
        {
            let ToVC=segue.destination as! MenuBarViewController
            ToVC.CurrentFeature=2
        }

        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    


}


