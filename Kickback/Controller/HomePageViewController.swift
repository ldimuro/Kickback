//
//  HomePageViewController.swift
//  Kickback
//
//  Created by Lou DiMuro on 7/15/18.
//  Copyright © 2018 Lou DiMuro. All rights reserved.
//

import UIKit
import Firebase
import PKHUD

class HomePageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var stationTableView: UITableView!
    
    var stationArray = [Station]()
    let user = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNavBarImage()
        loadStations()

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
        
        if station.followers.contains("None") {
            station.followers.removeAll()
        }

        if station.songs.contains("None") {
            station.songs.removeAll()
        }
        
        cell.stationName.text = station.stationName
        cell.songCount.text = "\(station.songs.count)"
        cell.userCount.text = "\(station.followers.count)"
        
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
                              "User": email!,
                              "Songs": ["None"],
                              "Followers": ["None"]] as [String : Any]
        
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
    func loadStations() {
        
        HUD.show( .labeledProgress(title: "Loading Stations", subtitle: ""))
        
        let stationDB = Database.database().reference().child("Stations")
        
        stationDB.observe(.childAdded) { (snapshot) in
            
//            let key = snapshot.key
            
            let snapshotValue = snapshot.value as! Dictionary<String,Any>
            
            let station = snapshotValue["Station Name"]!
            let user = snapshotValue["User"]!
            let songs = snapshotValue["Songs"]!
            let followers = snapshotValue["Followers"]!
            
            let dbStation = Station()
            dbStation.stationName = station as! String
            dbStation.user = user as! String
            dbStation.songs = songs as! [String]
            dbStation.followers = followers as! [String]
            
            self.stationArray.append(dbStation)
            
            self.stationTableView.reloadData()
            
            HUD.hide()
        }
    }
    
    func addNavBarImage() {
        
        let navController = navigationController!
        
        let image = #imageLiteral(resourceName: "kickback-logo")
        let imageView = UIImageView(image: image)
        
        let bannerWidth = navController.navigationBar.frame.size.width
        let bannerHeight = navController.navigationBar.frame.size.height
        
        let bannerX = bannerWidth / 2 - image.size.width / 2
        let bannerY = bannerHeight / 2 - image.size.height / 2
        
        imageView.frame = CGRect(x: bannerX, y: bannerY , width: bannerWidth, height: bannerHeight)
        imageView.contentMode = .scaleAspectFit
        
        navigationItem.titleView = imageView
    }
    

}
