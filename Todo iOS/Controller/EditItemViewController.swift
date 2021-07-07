//
//  EditViewController.swift
//  Todo iOS
//
//  Created by Sebastian Morado on 7/6/21.
//

import UIKit
import CoreData

class EditItemViewController: UIViewController {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var dateField: UILabel!
    
    var selectedItem : Item?
    var delegate : TodoViewController?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let dateFormatter = DateFormatter()
        
        if let item = selectedItem {
            titleField.text = item.title
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
            dateField.text = "Created on " + dateFormatter.string(from: item.dateCreated!)
        }
    }

    @IBAction func dismissScreen(_ sender: UIButton) {
        if let todoViewController = self.delegate {
            todoViewController.loadItems()
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func finishEditing(_ sender: UIButton) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title MATCHES %@", selectedItem!.title!)
        request.predicate = predicate
        
        do {
            let results = try context.fetch(request)
            if results.count != 0 { // Atleast one was returned
                results[0].setValue(titleField.text, forKey: "title")
            }
            try context.save()
        } catch {
            print(error)
        }
        
        if let todoViewController = self.delegate {
            todoViewController.loadItems()
        }
        dismiss(animated: true, completion: nil)
    }
}
