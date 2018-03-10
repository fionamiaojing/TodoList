//
//  ViewController.swift
//  TodoList
//
//  Created by Fiona Miao on 3/4/18.
//  Copyright © 2018 Fiona Miao. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoListViewController: UITableViewController {
    
    var toDoItems: Results<Item>?
    
    let realm = try! Realm()
    
    var selectedCategory : Category? {
        //function in the didSet{} will happend as soon as Category get selected
        didSet{
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //use fileManager to store the default array
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        //Load default array saved in phone - since the data type is not specified when set default value ,therefore needs to downcasting to [string]
//        if let items = defaults.array(forKey: defaultArrayKey) as? [Item] {
//            itemArray = items
//        }
        
    }

    //MARK: Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //TableView reuses cells
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoListCell", for: indexPath)
        
        if let item = toDoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            //Ternary operator ==>
            //value = condition ? valueIfTrue : valueIfFalse
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items added"
        }

        
        return cell
        
    }
    
    //MARK： Tableview Delagate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemArray[indexPath.row])
        
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
//                    realm.delete(item)
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status \(error)")
            }
        }
        
        tableView.reloadData()
        
        
//        //remove item from permanent srore (must before the remove function; because the target item at the index of array will be removed upon the call of remove function, then the delete function cannot delete the same item from itemArray)
//        context.delete(itemArray[indexPath.row])
//        
//        //remove the item from view
//        itemArray.remove(at: indexPath.row)

//        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    //MARK: Add new Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new To Do Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            //What will happen once the user clicks the Add Item button on our UIAlert
            
            //since Item is associted with parent Category, we need to save item in both itemArray and the target list in category
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error in saving context \(error)")
                }
                
            }
            
//            Set a default array(Any? - means data type not specified) using specific key XXXXXX
//            self.defaults.set(self.itemArray, forKey: self.defaultArrayKey)
            
            self.tableView.reloadData()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField

        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: Model Manipulating Methods
    
    
    //set default request as input; when you don't want input a parameter everytime, can set the default value to nil and add a ? mark means optional
    func loadItems() {
        
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }


}

//MARK: Search Bar Methods
extension ToDoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
        
    }


    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }

}




