//
//  CategoryViewController.swift
//  Todo iOS
//
//  Created by Sebastian Morado on 5/18/21.
//

import UIKit
import CoreData
import SwipeCellKit
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    private var categoryArray : [Category] = []
    private var rowToEdit : IndexPath?
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else { fatalError()}
        navBar.backgroundColor = UIColor.white
        navBar.tintColor = UIColor.label
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
    }


    
    // MARK: - TableView data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name
        cell.backgroundColor = UIColor.init(hexString: categoryArray[indexPath.row].color!)
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: K.segueFromCategoryToItems, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.segueFromCategoryToItems {
            if let destinationVC = segue.destination as? TodoViewController, let indexPath = tableView.indexPathForSelectedRow{
                destinationVC.selectedCategory = categoryArray[indexPath.row]
            }
        } else if segue.identifier == K.segueFromItemsToDetails {
            if let destinationVC = segue.destination as? EditCategoryViewController{
                destinationVC.selectedCategory = categoryArray[rowToEdit!.row]
                destinationVC.delegate = self
            }
        }
        
    }
    
    
    //MARK: - Data Manipulation
    
    private func saveCategories() {
        do {
            try context.save()
        } catch {
            print(error)
        }
        tableView.reloadData()
    }
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print(error)
        }
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        context.delete(categoryArray[indexPath.row])
        categoryArray.remove(at: indexPath.row)
        saveCategories()
    }
    
    override func editItems(at indexPath: IndexPath) {
        rowToEdit = indexPath
        performSegue(withIdentifier: K.segueFromItemsToDetails, sender: self)
    }
    
    //MARK: - Add new categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text
            newCategory.color = UIColor.randomFlat().hexValue()
            self.categoryArray.append(newCategory)
            self.saveCategories()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }

    
    

}

