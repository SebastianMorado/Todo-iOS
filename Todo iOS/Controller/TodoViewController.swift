//
//  ViewController.swift
//  Todo iOS
//
//  Created by Sebastian Morado on 5/13/21.
//

import UIKit
import CoreData
import ChameleonFramework

class TodoViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var itemToEdit : Item?
    private var showCompleted : Bool = false
    var itemArray : [Item] = []
    var completedArray : [Item] = []
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 70
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Change colors of navbar and titles
        let bgColor = UIColor(hexString: selectedCategory!.color!) ?? UIColor.white
        let textColor = ContrastColorOf(bgColor, returnFlat: true)
        guard let navBar = navigationController?.navigationBar else { fatalError()}
        navBar.tintColor = textColor
        navBar.backgroundColor = bgColor
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : textColor]
        title = selectedCategory!.name
        searchBar.barTintColor = bgColor
        searchBar.searchTextField.backgroundColor = UIColor.white
    }
    
    
    //MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        //TableView has 2 sections, one for active items and one for completed items
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //First section should not have header height
        return section == 0 ? CGFloat.leastNormalMagnitude : 50
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //First section should not have a header
        if section == 0 {
            return nil
        }
        
        //Create a view to customize the header for the 2nd section
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        //Create and design a button that will allow you to toggle to show the 2nd section
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        let buttonTitle = showCompleted ? "Hide Completed" : "Show Completed"
        button.setTitle(buttonTitle, for: .normal)
        button.addTarget(self, action: #selector(toggleCompletedItems(sender:)), for: .touchUpInside)
        button.setTitleColor(.darkGray, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.8929959174, green: 0.8929959174, blue: 0.8929959174, alpha: 1)
        button.layer.borderWidth = 0.4
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        view.addSubview(button)
        
        return view
    }
    
    @objc private func toggleCompletedItems(sender: UIButton) {
        //function for toggling to show completed items
        showCompleted.toggle()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //number of rows depends on section, and whether completed items are going to show
        if section == 0 {
            return itemArray.count
        } else if section == 1 && showCompleted {
            return completedArray.count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //create cell for item info
        let currentItem : Item = indexPath.section == 0 ? itemArray[indexPath.row] : completedArray[indexPath.row]
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        cell.textLabel?.text = currentItem.title
        cell.accessoryType = currentItem.done ? .checkmark : .none
        
        return cell
    }
    
    
    //MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //toggle items when the row is pressed
        let currentItem : Item = indexPath.section == 0 ? itemArray[indexPath.row] : completedArray[indexPath.row]
        
        currentItem.done.toggle()
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    //MARK: - Add New Items

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todo Item", message: "", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (action) in
        }
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            //Create a new Item and save it to the database (if the alert is clicked)
            let newItem = Item(context: self.context)
            newItem.title = textField.text ?? "New Item"
            newItem.done = false
            newItem.dateCreated = Date()
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            self.saveItems()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(cancel)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manipulation Methods
    
    private func saveItems() {
        //save and reload items
        do {
            try context.save()
        } catch {
            print(error)
        }
        tableView.reloadData()
    }
    
    func loadItems(with requestItemNotCompleted: NSFetchRequest<Item> = Item.fetchRequest()) {
        //will be used to fetch items that have been completed already
        let requestItemCompleted: NSFetchRequest<Item> = Item.fetchRequest()
        
        //the base predicate for all requests
        let predicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        //compound predicate which finds all items that have NOT been completed
        let predicateNotCompleted = NSPredicate(format: "done = %d", false)
        var predicateResultNotCompleted = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicateNotCompleted])
        
        //compound predicate which fins all items that have been completed
        let predicateCompleted = NSPredicate(format: "done = %d", true)
        var predicateResultCompleted = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicateCompleted])
        
        //add any search modifiers inputted by the user
        if let initialPredicate = requestItemNotCompleted.predicate {
            predicateResultNotCompleted = NSCompoundPredicate(andPredicateWithSubpredicates: [initialPredicate, predicateResultNotCompleted])
            predicateResultCompleted = NSCompoundPredicate(andPredicateWithSubpredicates: [initialPredicate, predicateResultCompleted])
        }
        
        //attach appropriate predicate to search for items that have NOT been completed
        requestItemNotCompleted.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: true)]
        requestItemNotCompleted.predicate = predicateResultNotCompleted
        
        //attach appropriate predicate to search for items that have been completed
        requestItemCompleted.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: true)]
        requestItemCompleted.predicate = predicateResultCompleted
        
        do {
            itemArray = try context.fetch(requestItemNotCompleted)
            completedArray = try context.fetch(requestItemCompleted)
        } catch {
            print(error)
        }
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        //if row is swiped and deleted, this function will update the database
        context.delete(itemArray[indexPath.row])
        itemArray.remove(at: indexPath.row)
        saveItems()
    }
    
    override func editItems(at indexPath: IndexPath) {
        //if row is swiped and edited, this function will present the edit window
        itemToEdit = indexPath.section == 0 ? itemArray[indexPath.row] : completedArray[indexPath.row]
        performSegue(withIdentifier: K.segueFromItemsToDetails, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //before edit window is presented, we will pass the item we want to edit to the next view controller
        if segue.identifier == K.segueFromItemsToDetails {
            if let destinationVC = segue.destination as? EditItemViewController{
                destinationVC.selectedItem = itemToEdit
                destinationVC.delegate = self
            }
        }
        
    }

}

//MARK: - UISearchBarDelegate

extension TodoViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //search the database depending on user's input
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        loadItems(with: request)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            //if there is no text, deselect the search bar and remove the keyboard
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        } else {
            //search the database automatically depending on what was input by the user in the search bar
            let request : NSFetchRequest<Item> = Item.fetchRequest()
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            
            loadItems(with: request)
        }
    }
    
    
}

