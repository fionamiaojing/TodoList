//
//  ViewController.swift
//  TodoList
//
//  Created by Fiona Miao on 3/4/18.
//  Copyright © 2018 Fiona Miao. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

//need to change the class and module to Swipexxx and Swipekit to inherit the super class
class ToDoListViewController: SwipeTableViewController {
    
    var toDoItems: Results<Item>?
    
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory : Category? {
        //function in the didSet{} will happend as soon as Category get selected
        didSet{
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none
        
//        //use fileManager to store the default array
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
//
//        //Load default array saved in phone - since the data type is not specified when set default value ,therefore needs to downcasting to [string]
//        if let items = defaults.array(forKey: defaultArrayKey) as? [Item] {
//            itemArray = items
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        title = selectedCategory?.name
        
        guard let colorHex = selectedCategory?.color else {(fatalError())}
        
        updateNavBar(withHexCode: colorHex)
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        updateNavBar(withHexCode: "FFCECC")
    }
    
    
    //MARK: - Nev Bar Setup Methods
    
    func updateNavBar(withHexCode colorHexCode: String) {
        //use guard let if you don't need an else statement and 99% you think it won't fail
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation Controller does not exist")}
        
        guard let navBarColor = UIColor(hexString: colorHexCode) else {(fatalError())}
        
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        searchBar.barTintColor = navBarColor
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
        
        
    }

    //MARK: Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = toDoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
        
            
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(toDoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
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
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status \(error)")
            }
        }
        
        tableView.reloadData()
        
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
    
    //MARK: - delete data from Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let itemTobeDeleted = toDoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(itemTobeDeleted)
                }
            } catch {
                print("Error deleting items \(error)")
            }
        }
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




