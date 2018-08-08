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
import SwipeCellKit

class HomePageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var stationTableView: UITableView!
    @IBOutlet weak var stationSwitcher: UISegmentedControl!
    
    var stationArray = [Station]()
    let user = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("VIEW DID LOAD")
        
        addNavBarImage()
        loadStations()

        stationTableView.delegate = self
        stationTableView.dataSource = self
        
        // Do any additional setup after loading the view.
        stationTableView.register(UINib(nibName: "StationTableViewCell", bundle: nil), forCellReuseIdentifier: "stationCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        filterData()
    }
    
    func filterData() {
        
        //Filters so only the current user's tasks are loaded
        UserDataArray.stations = stationArray.filter {$0.user == UserDefaults.standard.string(forKey: "username")}
        
        //Orders the tasks based on when they were created
        UserDataArray.stations = UserDataArray.stations.sorted(by: {$0.timestamp >= $1.timestamp})
        
        stationTableView.reloadData()
    }
    
    //setup functions sideNave main TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserDataArray.stations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "stationCell")! as! StationTableViewCell
        let station = UserDataArray.stations[indexPath.row]
        
        cell.delegate = self
        cell.selectionStyle = .none
        
        if station.friends.contains("N/A") && station.friends.count == 1 {
            cell.userCount.text = "0"
        } else {
            cell.userCount.text = "\(station.friends.count)"
        }

        if station.playlists.contains("N/A") && station.playlists.count == 1 {
            cell.songCount.text = "0"
        } else {
            cell.songCount.text = "\(station.playlists.count)"
        }
        
        cell.stationName.text = station.stationName
        cell.userLabel.text = station.user
        
        return cell
    }
    
//    @IBAction func addStation(_ sender: Any) {
//
//        var textfield = UITextField()
//
//        let alert = UIAlertController(title: "Create New Station", message: "", preferredStyle: .alert)
//        
//        let action = UIAlertAction(title: "Create", style: .default) { (action) in
//
//            self.saveStation(station: textfield.text!)
//
//            self.stationTableView.reloadData()
//        }
//
//        let stop = UIAlertAction(title: "Cancel", style: .default) { (cancel) in
//            //Do nothing
//        }
//
//        alert.addTextField { (alertTextField) in
//            alertTextField.placeholder = "Create new station"
//            textfield = alertTextField
//        }
//
//        alert.addAction(action)
//        alert.addAction(stop)
//
//        present(alert, animated: true, completion: nil)
//    }
    
    //Save tasks to Firebase
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
    
    //Load tasks from Firebase
    func loadStations() {
        
        HUD.show( .labeledProgress(title: "Loading Stations", subtitle: ""))
        
        let stationDB = Database.database().reference().child("Stations")

        stationDB.observe(.childAdded) { (snapshot) in

            let key = snapshot.key

            let snapshotValue = snapshot.value as! Dictionary<String,Any>

            let station = snapshotValue["Name"]! as! String
            let user = snapshotValue["User"]! as! String
            let playlists = snapshotValue["Playlists"]! as! [String]
            let friends = snapshotValue["Friends"]! as! [String]
            let timestamp = snapshotValue["Timestamp"]! as! String
            
            let dbStation = Station()
            dbStation.stationName = station
            dbStation.user = user
            dbStation.playlists = playlists
            dbStation.friends = friends
            dbStation.timestamp = timestamp
            dbStation.key = key
            
            self.stationArray.append(dbStation)
            
            self.filterData()
            
            HUD.hide()

        }
    }
    
    @IBAction func stationSwitch(_ sender: Any) {
        switch stationSwitcher.selectedSegmentIndex {
        case 0: //MY STATIONS
            print("My Stations")
        case 1: //SHARED WITH ME
            print("Shared With Me")
        default:
            break
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

extension HomePageViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            
            // handle action by updating model with deletion
            print("DELETED \(UserDataArray.stations[indexPath.row].stationName)")
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Delete \(UserDataArray.stations[indexPath.row].stationName)", style: .destructive , handler:{ (UIAlertAction)in
                print("User clicked Delete button")
                
                Database.database().reference().child("Stations").child(UserDataArray.stations[indexPath.row].key).removeValue()
                
                //Remove from total station array
                var x = 0
                var found = false
                while x < self.stationArray.count && !found{
                    if self.stationArray[x].key == UserDataArray.stations[indexPath.row].key {
                        print(self.stationArray[x].stationName)
                        self.stationArray.remove(at: x)
                        
                        found = true
                    }
                    else {
                        x += 1
                    }
                }
                
                UserDataArray.stations.remove(at: indexPath.row)

                action.fulfill(with: .delete)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
                print("Cancelled")
                action.fulfill(with: .reset)
            }))
            
            self.present(alert, animated: true, completion: {
                
            })
            
            
//            //hacky way to ensure the delete animation is smooth
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
//            })
            
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive(automaticallyDelete: false)
        options.transitionStyle = .border
        return options
    }
}
