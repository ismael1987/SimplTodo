//
//  ViewController.swift
//  SimpleToDo
//
//  Created by ismael alali on 27.01.20.
//  Copyright © 2020 ismael alali. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITextFieldDelegate,UITableViewDelegate, UITableViewDataSource {
    //NSManagedObject represents a single object stored in Core Data; you must use it to create, edit, save and delete from your Core Data persistent store.
    var tasks : [NSManagedObject] = []

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
          }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //1 -Before you can do anything with Core Data, you need a managed object context.
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2- As the name suggests, NSFetchRequest is the class responsible for fetching from Core Data.
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Todo")
        
        //3- you hand the fetch request over to the managed object context to do the heavy lifting.
        do {

            let sort = NSSortDescriptor(key: "title", ascending: true)
            fetchRequest.sortDescriptors = [sort]
            tasks = try managedContext.fetch(fetchRequest)

            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    var titleTextField: UITextField!
    
    //add func when you preess on + the alert will pop
    @IBAction func add(_ sender: UIBarButtonItem) {
        //for the input
        var textFields: UITextField?

        // create the alert
        let alert = UIAlertController(title: "My ToDo", message: "My ToDo", preferredStyle: UIAlertController.Style.alert)
        // add the actions (buttons)
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self, weak alert] action in
            //This takes the text in the text field and passes it over to a new method named addNewTask()
            guard let newItem = alert?.textFields?[0].text else { return }
            if newItem == ""{
                let alert = UIAlertController(title: "warning", message: "This field was empty !!!!!!!", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            } else{
                self?.addNewTask(newItem)
                //after success adding new action we reload the table view then the new cell will appear
                self?.tableView.reloadData()
                print("clicked")
            }
            
        }
        
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
            print("You've pressed Cancel")
        }
        
        alert.addTextField { (textField) in
            textFields = textField
            textFields?.placeholder = "Type your Task"
        }
        alert.addAction(addAction)
        alert.addAction(CancelAction)
    
        // show the alert
        self.present(alert, animated: true, completion: nil)
        self.tableView.reloadData()

        
        
    }
    
    //this func will call if u add a new task and clicked add
    func addNewTask(_ newItem: String){
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // 1- get your hands on an NSManagedObjectContext
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        // 2- You create a new managed object and insert it into the managed object context
        let entity =
            NSEntityDescription.entity(forEntityName: "Todo",
                                       in: managedContext)!
        
        let todo = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        // 3- With an NSManagedObject in hand, you set the name attribute using key-value coding.
        todo.setValue(newItem, forKeyPath: "title")
        
        // 4- You commit your changes to todo and save to disk by calling save on the managed object context.
        do {
            try managedContext.save()
            tasks.append(todo)
        } catch let error as NSError {
            print("Could not save. \(error)")
        }
        
        print("it called the add func")
        
    }
  
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            return tasks.count
        
    }
    
    //view the table in cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell!
        
        let task = tasks[indexPath.row]

        //re-use cells by adding a prototype cell
        cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        cell?.textLabel?.text = task.value(forKeyPath: "title") as? String
        
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // handle delete (by removing the data from your array and updating the tableview)
           guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext =
                appDelegate.persistentContainer.viewContext
            
            let task = tasks[indexPath.row]

            
            do {
                 managedContext.delete(task)
                tasks.remove(at: indexPath.row)
                //this line to reload the view table
                //tableView.deleteRows(at: [indexPath], with: .fade)
                try managedContext.save()
                //this line do same work reload the view table after save the delet
                self.tableView.reloadData()


            } catch let error as NSError {
                print("Could not save. \(error)")
            }
            
        }
        
    }
    

}

