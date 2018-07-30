//
//  ViewController.swift
//  Notes
//
//  Created by Samiul Hoque Limo on 7/28/18.
//  Copyright © 2018 Samiul Hoque Limo. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var note: Notes? = Notes()
    var notes = [Notes]()
    lazy var searchBar:UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 9, width: 200, height: 20))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        addData()
        
        searchBar.placeholder = "Search Notes"
        searchBar.delegate = self
        
        self.navigationItem.titleView = searchBar
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.notes = self.fetchData()
        self.tableView.reloadData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func addData() {
        for n in 1...100 {
            let date: String = generateRandomDate(daysBack: n)!
            addNote(title: randomString(length: 12), details: randomString(length: 150), modified: date)
        }
    }
    
    func randomString(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
    
    func generateRandomDate(daysBack: Int)-> String?{
        let day = arc4random_uniform(UInt32(daysBack))+1
        let hour = arc4random_uniform(23)
        let minute = arc4random_uniform(59)
        
        let today = Date(timeIntervalSinceNow: 0)
        let gregorian  = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        var offsetComponents = DateComponents()
        offsetComponents.day = Int(day - 1)
        offsetComponents.hour = Int(hour)
        offsetComponents.minute = Int(minute)
        
        let date = gregorian?.date(byAdding: offsetComponents, to: today, options: .init(rawValue: 0) )
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM, yyyy h:mm a"
        
        return formatter.string(from: date!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.notes = self.fetchData()
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editNote" {
            let destView = segue.destination as! EditViewController
            let indexpath = self.tableView.indexPathForSelectedRow
            destView.note_ = notes[(indexpath?.row)!]
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
         self.performSegue(withIdentifier: "editNote", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)  as! TableViewCell
        
        cell.title.text = notes[indexPath.row].title
        cell.details.text = notes[indexPath.row].details
        cell.modified.text = notes[indexPath.row].modified
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit", handler: { (action, indexPath) in
            let alertController = UIAlertController(title: "Edit Notes", message: "", preferredStyle: .alert)
            
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Title"
                textField.text = self.notes[indexPath.row].title
            }
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Details"
                textField.text = self.notes[indexPath.row].details
            }
            
            let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
                let title = alertController.textFields![0] as UITextField
                let details = alertController.textFields![1] as UITextField
                
                if((title.text?.isEmpty)! || (details.text?.isEmpty)!){
                    return
                }
                
                self.addNote(title: title.text!, details: details.text!)
                
                self.notes[indexPath.row].title = title.text
                self.notes[indexPath.row].details = details.text
                
                self.save()
                self.tableView.reloadData()
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action : UIAlertAction!) -> Void in })
            
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        })
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            self.delete(self.notes[indexPath.row])
            self.notes.remove(at: indexPath.row)
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
        })
        
        return [deleteAction, editAction]
    }
    
    func fetchData() -> [Notes] {
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do{
            let notes = try managedContext.fetch(Notes.fetch())
            return notes
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return []
        }
    }
    
    func fetchData(by textFilter: String) -> [Notes] {
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do{
            let request = Notes.fetch()
            request.predicate = NSPredicate(format: "title contains[cd] %@ OR details contains[cd] %@", textFilter)
            let notes = try managedContext.fetch(request)
            return notes
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return []
        }
    }
    
    func delete(_ note: Notes) {
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        managedContext.delete(note)
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
    
    func addNote(title: String, details: String) {
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: Notes.entityName, in: managedContext) else { return }
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM, yyyy h:mm a"
        let modified = formatter.string(from: date)
        
        let note = Notes(entity: entity, insertInto: managedContext)
        note.title = title
        note.details = details
        note.modified = modified
        self.save()
    }
    
    func addNote(title: String, details: String, modified: String) {
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: Notes.entityName, in: managedContext) else { return }
        
        let note = Notes(entity: entity, insertInto: managedContext)
        note.title = title
        note.details = details
        note.modified = modified
        self.save()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.isEmpty){
            self.notes = self.fetchData()
            self.tableView.reloadData()
        } else {
            self.notes = self.fetchData(by: searchText)
            self.tableView.reloadData()
        }
    }
}

