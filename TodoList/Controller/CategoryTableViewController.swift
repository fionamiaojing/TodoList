//
//  CategoryTableViewController.swift
//  TodoList
//
//  Created by Fiona Miao on 3/7/18.
//  Copyright © 2018 Fiona Miao. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryTableViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categoryArray: Results<Category>?
    
    var colorArray : [UIColor] = [FlatRed(),FlatPowderBlue(),FlatYellow(),FlatSand(),FlatLime(),FlatWatermelon(),FlatSkyBlue(),FlatCoffee(),FlatOrange(),FlatMint()]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategory()

    }

    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //means if category isnot nill (true) return categoryArray.count esle return 1
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categoryArray?[indexPath.row] {
            cell.textLabel?.text = category.name
            
            guard let categoryColor = UIColor(hexString: category.color) else {fatalError()}
            cell.backgroundColor = categoryColor
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
        
    }
    
    
    //MARK: - Data Manipulate Methods
    
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error in saving context \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategory() {
        
        categoryArray = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    //MARK: - delete data from Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        //since categoryArray is optional, use if function to test if it is nill
        if let categoryToBeDeleted = self.categoryArray?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryToBeDeleted)
                }
            } catch {
                print("Error deleting categories \(error)")
            }
        }
    }
    
    //MARK: - Add Button Function
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category?", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category()
            
            if textField.text?.isEmpty != true {
                newCategory.name = textField.text!
                
//                newCategory.color = UIColor.randomFlat.hexValue()
                if self.categoryArray?.count != nil {
                    newCategory.color = self.colorArray[(self.categoryArray?.count)!].hexValue()
                } else {
                    newCategory.color = self.colorArray[0].hexValue()
                }
                self.save(category: newCategory)
            } else {
                print("Invalid input")
            }
            
         
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }

}











