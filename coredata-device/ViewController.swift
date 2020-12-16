//
//  ViewController.swift
//  coredata-device
//
//  Created by Brian Bansenauer on 10/13/19.
//  Copyright © 2019 Cascadia College. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    //TODO: refactor in-app storage to use NSManagedObject array
    var devices:[NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Devices"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Device")
        
        do{
            devices = try managedContext.fetch(fetchRequest)
        }catch let error as NSError{print ("Could not fetch. \(error), \(error.userInfo)")}
    }
    @IBAction func addDevice(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Device", message: "Enter Device Serial Number", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            action in
            guard let textField = alert.textFields?.first,
                  let serialNumber = textField.text else
            {
                return
            }
            
            self.save(with: serialNumber)
            self.tableView.reloadData()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert,animated: true)
    }
    
    func save(with serialNumber:String){
        //TODO:Use the MOC with the Device entity to create a newDevice object, update it's property and save it to persistent storage
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "Device", in: managedContext) else { return }
        let device = NSManagedObject(entity: entity, insertInto: managedContext)
        device.setValue(serialNumber, forKey: "serialNumber")
        
        do{
            try managedContext.save()
            devices.append(device)
        } catch let error as NSError{
            print ("Could not save. \(error), \(error.userInfo)")
        }
        
    }
}

//MARK _ TableView Data Source: Refactor to use NSManagedObject array
extension ViewController:UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //TODO: refactor to get the device object and use it's value(forKeyPath: ) method to pull the serialNumber text
        let device = devices[indexPath.row]
        cell.textLabel?.text = device.value(forKeyPath: "serialNumber") as? String
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
}
