//
//  SwipeTableViewController.swift
//  Todo iOS
//
//  Created by Sebastian Morado on 5/19/21.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barStyle = .black
    }
    
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        //adds swipe functionality to each row
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.updateModel(at: indexPath)
        }
        
        let editAction = SwipeAction(style: .destructive, title: "Edit") { action, indexPath in
            self.editItems(at: indexPath)
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        editAction.image = UIImage(systemName: "pencil")
        editAction.backgroundColor = UIColor.flatGreen()
        
        return [deleteAction, editAction]
    }


    func updateModel(at indexPath: IndexPath) {
        //used to delete swiped cells, overriden in subclasses
    }
    
    func editItems(at indexPath: IndexPath) {
        //used to edit swiped cells, overriden in subclasses
    }
    

}
