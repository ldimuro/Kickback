//
//  SearchViewController.swift
//  Kickback
//
//  Created by Lou DiMuro on 7/23/18.
//  Copyright © 2018 Lou DiMuro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var searchTable: UITableView!
    
    var isSearching = false
    var userArray = [SearchUser]()
    var filteredArray = [SearchUser]()
    var profilePicArray = [UIImage]()
    var userFriends = [String]()
     var previousCount = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAllUsers()
        getUserFriends()
        
        searchTable.delegate = self
        searchTable.dataSource = self
        searchbar.delegate = self
        searchbar.returnKeyType = UIReturnKeyType.done
        
        // Do any additional setup after loading the view.
        searchTable.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "searchCell")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        searchbar.text = ""
        filteredArray.removeAll()
        searchTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTableViewCell
        
        cell.selectionStyle = .none
        
        if userFriends.contains(filteredArray[indexPath.row].user) {
            filteredArray[indexPath.row].followed = true
        } else {
            filteredArray[indexPath.row].followed = false
        }
        
        cell.usernameLabel.text = filteredArray[indexPath.row].user
        cell.profilePicture.image = filteredArray[indexPath.row].profilePic
//        cell.profilePicture.image = UIImage(named: filteredArray[indexPath.row].profilePic)
//        cell.profilePicture.image = profilePicArray[1]
        
        cell.followButton.addTarget(self, action: #selector(self.followedTapped(sender:)), for: .touchUpInside)
        cell.followButton.tag = indexPath.row
        
        if filteredArray[indexPath.row].followed {
            
            //Fade in animation
            UIView.transition(with: cell.followButton as UIView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                cell.followButton.setImage(UIImage(named: "checked-button"), for: .normal)
            }, completion: nil)
            
            
        } else {
            
            //Fade out animation
            UIView.transition(with: cell.followButton as UIView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                cell.followButton.setImage(UIImage(named: "empty-button"), for: .normal)
            }, completion: nil)
        }
        
        let filePath = "Profile Pictures/\(self.filteredArray[indexPath.row].user)-profile"
        Storage.storage().reference().child(filePath).getData(maxSize: 10*1024*1024, completion: { (data, error) in
            
            let userPhoto = UIImage(data: data!)
            cell.profilePicture.image = userPhoto
            
        })
        
        return cell
    }
    
    @objc func followedTapped(sender : UIButton) {
        
        if filteredArray[sender.tag].followed {
            userFriends = userFriends.filter {$0 != filteredArray[sender.tag].user}
        } else {
            userFriends.append(filteredArray[sender.tag].user)
        }
        
        Database.database().reference().child("Users").child(UserDefaults.standard.string(forKey: "username")!).child("Friends").setValue(userFriends){
            (error, reference) in
            
            if(error != nil) {
                print(error!)
            }
            else {
                print("Friend Added!")
            }
        }
        
        print(userFriends)
        
        searchTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredArray.count
    }
    
    //Search Bar functionality
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        
        if(searchBar.text == nil || searchBar.text == "") {
            isSearching = false
//            view.endEditing(true)
            
            print("IS SEARCHING: \(isSearching)")
            
            filteredArray = [SearchUser]()
            
            previousCount = 0
            
            let range = NSMakeRange(0, self.searchTable.numberOfSections)
            let sections = NSIndexSet(indexesIn: range)
            self.searchTable.reloadSections(sections as IndexSet, with: .automatic)
            
        }
        else {
            isSearching = true
            print("IS SEARCHING = \(isSearching)")
            print(userFriends)
            print("IMAGE ARRAY: \(profilePicArray.count)")
            
            filteredArray = userArray.filter({($0.user.contains(searchbar.text!.lowercased()))})
            
            //Ensures smooth row animation
            if previousCount != 0 && filteredArray.count == previousCount {
                searchTable.reloadData()
            } else {
                let range = NSMakeRange(0, self.searchTable.numberOfSections)
                let sections = NSIndexSet(indexesIn: range)
                self.searchTable.reloadSections(sections as IndexSet, with: .automatic)
            }
            
            previousCount = filteredArray.count
            
        }
        
    }
    
    
    //Creates an array of all users in Firebase
    func getAllUsers() {
        
        let userDB = Database.database().reference().child("Users")
        
        userDB.observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key
                
                let snapshotValue = snap.value as! Dictionary<String,Any>
                let profilePic = snapshotValue["Profile Picture"] as! String
                
                let searchUserDB = SearchUser()
                
                let filePath = "Profile Pictures/\(key)-profile"
                // Assuming a < 10MB file, though you can change that
                Storage.storage().reference().child(filePath).getData(maxSize: 10*1024*1024, completion: { (data, error) in
                    
                    let userPhoto = UIImage(data: data!)
                    searchUserDB.profilePic = userPhoto
//                    self.profilePicArray.append(userPhoto!)
                })

                
//                searchUserDB.profilePic = profilePic
                
                if key != UserDefaults.standard.string(forKey: "username") {
                    searchUserDB.user = key
                }
                
                self.userArray.append(searchUserDB)
                
//                let filePath = "Profile Pictures/\(key)-profile"
//                // Assuming a < 10MB file, though you can change that
//                Storage.storage().reference().child(filePath).getData(maxSize: 10*1024*1024, completion: { (data, error) in
//
//                    let userPhoto = UIImage(data: data!)
//                    self.profilePicArray.append(userPhoto!)
//                })
                
            }
        })
    }
    
    func getUserFriends() {
        let ref = Database.database().reference().child("Users").child(UserDefaults.standard.string(forKey: "username")!).child("Friends")
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            for snap in snapshot.children {
                
                let friend = (snap as! DataSnapshot).value! as! String
                
                if friend != "N/A" {
                    self.userFriends.append("\(friend)")
                }
            }
        }
    }
    
    
}
