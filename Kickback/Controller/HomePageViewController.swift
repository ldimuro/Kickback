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
import CRRefresh

class HomePageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var stationTableView: UITableView!
    @IBOutlet weak var stationSwitcher: UISegmentedControl!
    @IBOutlet weak var notificationBarButton: UIBarButtonItem!
    
    var filteredArray = [Station]()
    var stationArray = [Station]()
    var sharedStationArray = [Station]()
    let user = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("VIEW DID LOAD")
        
        addNavBarImage()
        loadStations()
        loadSharedStations()
//        getNumOfNotifications()
        
        /// animator: your customize animator, default is NormalHeaderAnimator
        stationTableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            
            print("REFRESH")
            
            self?.loadSharedStations()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                /// Stop refresh when your job finished, it will reset refresh footer if completion is true
                self?.stationTableView.cr.endHeaderRefresh()
            })
        }

        stationTableView.delegate = self
        stationTableView.dataSource = self
        
        // Do any additional setup after loading the view.
        stationTableView.register(UINib(nibName: "StationTableViewCell", bundle: nil), forCellReuseIdentifier: "stationCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        filterData()
        
        addRedBubble()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        let rightBarButton = self.navigationItem.rightBarButtonItem
        rightBarButton?.removeBadge()
    }
    
    func addRedBubble() {
        let rightBarButton = self.navigationItem.rightBarButtonItem
        
        Database.database().reference().child("Unread Notifications").child(UserDefaults.standard.string(forKey: "username")!).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChildren() {
                rightBarButton?.addBadge(text: "")
                print("HAS NOTIFICATIONS")
            } else {
                rightBarButton?.removeBadge()
                print("DOES NOT HAVE NOTIFICATIONS")
            }
        }
    }
    
    //setup functions sideNave main TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return UserDataArray.stations.count
        return filteredArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "stationCell")! as! StationTableViewCell
//        let station = UserDataArray.stations[indexPath.row]
        let station = filteredArray[indexPath.row]
        
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
        cell.userLabel.text = station.owner
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if stationSwitcher.selectedSegmentIndex == 0 {
            self.performSegue(withIdentifier: "goToNowPlaying", sender: self)
        } else {
            self.performSegue(withIdentifier: "goToSharedStation", sender: self)
        }
        
    }
    
    
    //Load stations from Firebase
    func loadStations() {
        
//        HUD.show( .labeledProgress(title: "Loading Stations", subtitle: ""))
        
        let stationDB = Database.database().reference().child("Stations").child("\(Auth.auth().currentUser!.uid)")

        stationDB.observe(.childAdded) { (snapshot) in
            
            let key = snapshot.key

            let snapshotValue = snapshot.value as! Dictionary<String,Any>

            let station = snapshotValue["Name"]! as! String
            let user = snapshotValue["User"]! as! String
            let owner = snapshotValue["Owner"]! as! String
            let playlists = snapshotValue["Playlists"]! as! [String]
            let friends = snapshotValue["Friends"]! as! [String]
            let timestamp = snapshotValue["Timestamp"]! as! String
            
            let dbStation = Station()
            dbStation.stationName = station
            dbStation.user = user
            dbStation.owner = owner
            dbStation.playlists = playlists
            dbStation.friends = friends
            dbStation.timestamp = timestamp
            dbStation.key = key
            
            self.stationArray.append(dbStation)
            
            self.stationArray = self.stationArray.sorted(by: {$0.timestamp >= $1.timestamp})
            
            self.filterData()
            
//            self.stationTableView.reloadData()
            
//            HUD.hide()

        }
        
    }
    
    func getNumOfNotifications() {
        
        let ref = Database.database().reference().child("Unread Notifications").child(UserDefaults.standard.string(forKey: "username")!)
        
        var count = 0
        
        ref.observe(.childAdded) { (snapshot) in
            
            count += 1
            
            print("NOTIFICATION RECEIVED")
            
//            let rightBarButton = self.navigationItem.rightBarButtonItem
//            rightBarButton?.addBadge(text: "\(count)")
//            rightBarButton?.addBadge(text: "")
            
//            self.addRedBubble()
            
        }
        
    }
    
    @IBAction func stationSwitch(_ sender: Any) {
        filterData()
    }
    
    func filterData() {
        switch stationSwitcher.selectedSegmentIndex {
            case 0: //MY STATIONS
                print("My Stations")
                
                filteredArray = stationArray.filter {$0.owner == UserDefaults.standard.string(forKey: "username")}
                
                self.stationTableView.reloadData()
                //Smooth animation when moving cells around (replaces stationTableView.reloadData())
//                let range = NSMakeRange(0, self.stationTableView.numberOfSections)
//                let sections = NSIndexSet(indexesIn: range)
//                self.stationTableView.reloadSections(sections as IndexSet, with: .automatic)
            
            case 1: //SHARED WITH ME
                print("Shared With Me")
                
                filteredArray = stationArray.filter {$0.owner != UserDefaults.standard.string(forKey: "username")}
                print("Filtered Array length: \(filteredArray.count)")
                
                self.stationTableView.reloadData()
                //Smooth animation when moving cells around (replaces stationTableView.reloadData())
//                let range = NSMakeRange(0, self.stationTableView.numberOfSections)
//                let sections = NSIndexSet(indexesIn: range)
//                self.stationTableView.reloadSections(sections as IndexSet, with: .automatic)
            
            default:
                break
        }
    }
    
    //Searches through "Shared Stations" for current user
    func loadSharedStations() {
        
        let ref = Database.database().reference().child("Shared Stations").queryOrdered(byChild: "User").queryEqual(toValue: UserDefaults.standard.string(forKey: "username"))
        
        ref.observeSingleEvent(of: .value, with:{ (snapshot: DataSnapshot) in
            
            for snap in snapshot.children {
                print(snapshot.childrenCount)
                
                let snapKey = snap as! DataSnapshot
                let key = snapKey.key
                
                let snapMatch = (snap as! DataSnapshot).value! as! Dictionary<String,Any>
                
                let station = snapMatch["Name"]! as! String
                let user = snapMatch["User"]! as! String
                let owner = snapMatch["Owner"]! as! String
                let playlists = snapMatch["Playlists"]! as! [String]
                var friends = snapMatch["Friends"]! as! [String]
                let timestamp = snapMatch["Timestamp"]! as! String
                
                if friends.count == 1 && friends.contains("N/A") {
                    friends.removeAll()
                    friends.append(owner)
                } else {
                    friends.append(owner)
                }
                
                let dbSharedStation = Station()
                dbSharedStation.stationName = station
                dbSharedStation.user = user
                dbSharedStation.owner = owner
                dbSharedStation.playlists = playlists
                dbSharedStation.friends = friends
                dbSharedStation.timestamp = timestamp
                dbSharedStation.key = key
                
//                self.stationArray.append(dbSharedStation)
                print(dbSharedStation.stationName)
                
                self.addShareStation(station: station, user: user, owner: owner, playlists: playlists, friends: friends, timestamp: timestamp, key: key)
                print("ADDING SHARED STATION")
                
                
            }
            
//            self.filterData()
            print("FINISHED")
            
        })
        
    }
    
    //Creates a new Task based on matching task found in "Tasks to Share"
    func addShareStation(station: String, user: String, owner: String, playlists: [String], friends: [String], timestamp: String, key: String) {
        
        let addStation = Database.database().reference().child("Stations").child("\(Auth.auth().currentUser!.uid)")
        let timestamp = "\(Date())"
        
        let postDictionary = ["Name": station,
                              "User": user,
                              "Owner": owner,
                              "Friends": friends,
                              "Playlists": playlists,
                              "Timestamp": timestamp] as [String : Any]
        
        addStation.childByAutoId().setValue(postDictionary) {
            (error, reference) in
            
            if(error != nil) {
                print(error!)
            }
            else {
                print("Shared Station saved successfully")
                Database.database().reference().child("Shared Stations").child(key).removeValue()
            }
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
            print("DELETED \(self.stationArray[indexPath.row].stationName)")
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Delete \(self.stationArray[indexPath.row].stationName)", style: .destructive , handler:{ (UIAlertAction)in
                print("User clicked Delete button")
                
                Database.database().reference().child("Stations").child("\(Auth.auth().currentUser!.uid)").child(self.filteredArray[indexPath.row].key).removeValue()
                
                //Remove from total station array
                var x = 0
                var found = false
                while x < self.stationArray.count && !found{
                    if self.stationArray[x].key == self.filteredArray[indexPath.row].key {
                        print(self.stationArray[x].stationName)
                        self.stationArray.remove(at: x)
                        
                        found = true
                    }
                    else {
                        x += 1
                    }
                }
                
                //Remove from filtered array
                self.filteredArray.remove(at: indexPath.row)

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
