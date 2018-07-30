//
//  DetailsViewController.swift
//  Notes
//
//  Created by Samiul Hoque Limo on 7/29/18.
//  Copyright © 2018 Samiul Hoque Limo. All rights reserved.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var detailsTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveNoteAction(_ sender: Any) {
        if(!((titleTextField.text?.isEmpty)!) && !((detailsTextView.text?.isEmpty)!)){
            addNote(title: titleTextField.text!, details: detailsTextView.text!)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func addNote(title: String, details: String) {
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: Notes.entityName, in: managedContext) else { return }
        
        let note = Notes(entity: entity, insertInto: managedContext)
        note.title = title
        note.details = details

        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM, yyyy h:mm a"
        note.modified = formatter.string(from: date)
        
        self.save()
    }
    
    func save() {
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            try managedContext.save()
        } catch {
            print("Failed saving")
        }
    }
}
