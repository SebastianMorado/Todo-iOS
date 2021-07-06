//
//  EditCategoryViewController.swift
//  Todo iOS
//
//  Created by Sebastian Morado on 7/6/21.
//

import UIKit
import CoreData

class EditCategoryViewController: UIViewController {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var colorButton: UIButton!
    
    let picker = UIColorPickerViewController()
    
    var selectedCategory : Category?
    var delegate : CategoryViewController?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        picker.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let category = selectedCategory {
            titleField.text = category.name
            colorButton.backgroundColor = UIColor.init(hexString: category.color!)
            picker.selectedColor = colorButton.backgroundColor!
        }
    }

    @IBAction func dismissScreen(_ sender: UIButton) {
        if let categoryViewController = self.delegate {
            categoryViewController.loadCategories()
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeColor(_ sender: UIButton) {
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func finishEditing(_ sender: UIButton) {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        let predicate = NSPredicate(format: "name MATCHES %@", selectedCategory!.name!)
        request.predicate = predicate
        
        do {
            let results = try context.fetch(request)
            if results.count != 0 { // Atleast one was returned
                results[0].setValue(titleField.text, forKey: "name")
                results[0].setValue(colorButton.backgroundColor?.hexValue(), forKey: "color")
            }
            try context.save()
        } catch {
            print(error)
        }
        
        if let categoryViewController = self.delegate {
            categoryViewController.loadCategories()
        }
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - UIColor Delegate

extension EditCategoryViewController: UIColorPickerViewControllerDelegate {
    
    //  Called once you have finished picking the color.
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        colorButton.backgroundColor = viewController.selectedColor
        
    }
    
    //  Called on every color selection done in the picker.
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        colorButton.backgroundColor = viewController.selectedColor
    }
}
