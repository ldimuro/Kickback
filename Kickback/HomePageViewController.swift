//
//  HomePageViewController.swift
//  Kickback
//
//  Created by Lou DiMuro on 7/15/18.
//  Copyright © 2018 Lou DiMuro. All rights reserved.
//

import UIKit
import Firebase

class HomePageViewController: UIViewController, UITableViewDelegate , UITableViewDataSource {

    @IBOutlet weak var stationTableView: UITableView!
    
    var array = ["1", "2", "3"]
    var stationArray = [Station]()
    let user = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTasks()

        stationTableView.delegate = self
        stationTableView.dataSource = self
        
        // Do any additional setup after loading the view.
        stationTableView.register(UINib(nibName: "StationTableViewCell", bundle: nil), forCellReuseIdentifier: "stationCell")
    }
    
    //setup functions sideNave main TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "stationCell")! as! StationTableViewCell
        let station = stationArray[indexPath.row]
        
        cell.textLabel?.text = station.station
        
        return cell
    }
    
    @IBAction func addStation(_ sender: Any) {
        
        var textfield = UITextField()
        
        let alert = UIAlertController(title: "Create New Station", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Create", style: .default) { (action) in
            
            self.saveStation(station: textfield.text!)
            
            self.stationTableView.reloadData()
        }
        
        let stop = UIAlertAction(title: "Cancel", style: .default) { (cancel) in
            //Do nothing
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new station"
            textfield = alertTextField
        }
        
        alert.addAction(action)
        alert.addAction(stop)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //Save tasks to phone using Codable
    func saveStation(station: String) {
        
        let addStation = Database.database().reference().child("Stations")
        let station = station
        let email = user!.email
        
        let postDictionary = ["Station Name": station,
                              "User": email]
        
        addStation.childByAutoId().setValue(postDictionary) {
            (error, reference) in
            
            if(error != nil) {
                print(error!)
            }
            else {
                print("Station saved successfully")
            }
        }
    }
    
    //Load tasks from phone using Codable
    func loadTasks() {
        
        let stationDB = Database.database().reference().child("Stations")
        
        stationDB.observe(.childAdded) { (snapshot) in
            
//            let key = snapshot.key
            
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            
            let station = snapshotValue["Station Name"]!
            let user = snapshotValue["User"]!
            
            let dbStation = Station()
            dbStation.station = station
            dbStation.user = user
            
            self.stationArray.append(dbStation)
            
            self.stationTableView.reloadData()
        }
    }
    

}
