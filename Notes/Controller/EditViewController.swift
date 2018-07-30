//
//  EditViewController.swift
//  Notes
//
//  Created by Samiul Hoque Limo on 7/30/18.
//  Copyright © 2018 Samiul Hoque Limo. All rights reserved.
//

import UIKit
import CoreData

class EditViewController: UIViewController {

    @IBOutlet weak var noteTextView: UITextView!
    
    var note_: Notes? = Notes()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noteTextView.text = (note_?.title)! + "\n" + (note_?.details)!
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let fullName    = noteTextView.text
        let fullNameArr = fullName?.components(separatedBy: "\n")
        
        let title    = fullNameArr![0]
        let details = fullNameArr![1]
        
        print("title: \(title)")
        print("details: \(details)")
        
        addNote(title: title, details: details)
        self.save()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addNote(title: String, details: String) {
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: Notes.entityName, in: managedContext) else { return }
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM, yyyy h:mm a"
        
        let note = Notes(entity: entity, insertInto: managedContext)
        note.title = title
        note.details = details
        note.modified = formatter.string(from: date)
       
        managedContext.delete(note_!)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
