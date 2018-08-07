//
//  AddFriendsViewController.swift
//  Kickback
//
//  Created by Lou DiMuro on 8/6/18.
//  Copyright © 2018 Lou DiMuro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class AddFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var addFriendsTableView: UITableView!
    
    var friendArray = [AddFriend]()
    var arrayToSend = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getFriends()

        addFriendsTableView.delegate = self
        addFriendsTableView.dataSource = self
        addFriendsTableView.tableFooterView = UIView()
        
        addFriendsTableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "searchCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("FRIENDS: \(AddStationData.addedFriends)")
        arrayToSend = AddStationData.addedFriends
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTableViewCell
        
        if AddStationData.addedFriends.contains(friendArray[indexPath.row].user) {
            friendArray[indexPath.row].added = true
        }
        
        cell.usernameLabel.text = friendArray[indexPath.row].user
        cell.profilePicture.image = friendArray[indexPath.row].profilePic
        
        if friendArray[indexPath.row].added {
            
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
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        friendArray[indexPath.row].added = !friendArray[indexPath.row].added
        
        if friendArray[indexPath.row].added {
            arrayToSend.append(friendArray[indexPath.row].user)
        } else {
            arrayToSend = arrayToSend.filter {$0 != friendArray[indexPath.row].user}
        }
        
        print(arrayToSend)
        AddStationData.addedFriends = arrayToSend
        
        tableView.reloadData()
    }
    
    func getFriends() {
        
        let userDB = Database.database().reference().child("Users")

        userDB.observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key

                let addFriendDB = AddFriend()
                
                if UserDataArray.friends.contains(key) {
                    
                    addFriendDB.user = key
                    
                    let filePath = "Profile Pictures/\(key)-profile"
                    Storage.storage().reference().child(filePath).getData(maxSize: 10*1024*1024, completion: { (data, error) in
                        
                        let userPhoto = UIImage(data: data!)
                        addFriendDB.profilePic = userPhoto
                        
                        self.friendArray.append(addFriendDB)
                        
                        self.friendArray = self.friendArray.sorted{$0.user < $1.user}
                        
                        let range = NSMakeRange(0, self.addFriendsTableView.numberOfSections)
                        let sections = NSIndexSet(indexesIn: range)
                        self.addFriendsTableView.reloadSections(sections as IndexSet, with: .automatic)
                        
                    })
                }
            }
        })
    }

}
