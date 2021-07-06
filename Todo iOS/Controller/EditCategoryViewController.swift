//
//  EditCategoryViewController.swift
//  Todo iOS
//
//  Created by Sebastian Morado on 7/6/21.
//

import UIKit

class EditCategoryViewController: UIViewController {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var dateField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func dismissScreen(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeColor(_ sender: UIButton) {
    }
    
    @IBAction func finishEditing(_ sender: UIButton) {
    }
}
