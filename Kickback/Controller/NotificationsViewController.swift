//
//  NotificationsViewController.swift
//  Kickback
//
//  Created by Lou DiMuro on 7/31/18.
//  Copyright © 2018 Lou DiMuro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import CRRefresh

class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var notificationsTableview: UITableView!
    
    let data = ["Notification1", "Notification2", "Notification3"]
    var notificationArray = [Notification]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadNotifications()
        checkNotifications()
        
        /// animator: your customize animator, default is NormalHeaderAnimator
        notificationsTableview.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            
            print("REFRESH")
            
            self?.checkNotifications()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                /// Stop refresh when your job finished, it will reset refresh footer if completion is true
                self?.notificationsTableview.cr.endHeaderRefresh()
            })
        }
        
        notificationsTableview.delegate = self
        notificationsTableview.dataSource = self

        notificationsTableview.register(UINib(nibName: "NotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "notificationCell")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationTableViewCell
        
        if !notificationArray[indexPath.row].message.contains("friended") {
            cell.followButton.isHidden = true
        } else {
            cell.followButton.isHidden = false
        }
        
        let filePath = "Profile Pictures/\(notificationArray[indexPath.row].user)-profile"
        Storage.storage().reference().child(filePath).getData(maxSize: 10*1024*1024, completion: { (data, error) in
            
            let userPhoto = UIImage(data: data!)
            cell.profilePicture.image = userPhoto
        })
        
        cell.messageLabel.text = notificationArray[indexPath.row].message
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationArray.count
    }
    
    func loadNotifications() {
        let notificationDB = Database.database().reference().child("Notifications").child(UserDefaults.standard.string(forKey: "username")!)
        
        notificationDB.observeSingleEvent(of: .value, with:{ (snapshot: DataSnapshot) in
            
            for snap in snapshot.children {
                
                let snapKey = snap as! DataSnapshot
                
                let snapMatch = (snap as! DataSnapshot).value! as! Dictionary<String,Any>
                
                let key = snapKey.key
                let message = snapMatch["Message"]! as! String
                let user = snapMatch["User"]! as! String
                let recipient = snapMatch["Recipient"]! as! String
                let timestamp = snapMatch["Timestamp"]! as! String
                
                let dbNotification = Notification()
                dbNotification.message = message
                dbNotification.user = user
                dbNotification.recipient = recipient
                dbNotification.timestamp = timestamp
                dbNotification.key = key
                
                self.notificationArray.append(dbNotification)
                
                self.notificationArray = self.notificationArray.sorted(by: {$0.timestamp >= $1.timestamp})
                
                self.notificationsTableview.reloadData()
                
            }
            
        })
    }
    
    //Searches through "Unread Notifications" for current user
    func checkNotifications() {
        
        let ref = Database.database().reference().child("Unread Notifications").child(UserDefaults.standard.string(forKey: "username")!)
        
        ref.observeSingleEvent(of: .value, with:{ (snapshot: DataSnapshot) in
            
            for snap in snapshot.children {
                
                let snapKey = snap as! DataSnapshot
                let key = snapKey.key
                
                let snapMatch = (snap as! DataSnapshot).value! as! Dictionary<String,Any>
                
                let message = snapMatch["Message"]! as! String
                let user = snapMatch["User"]! as! String
                let recipient = snapMatch["Recipient"]! as! String
                let timestamp = snapMatch["Timestamp"]! as! String
                
                self.addNotification(message: message, user: user, recipient: recipient, timestamp: timestamp, key: key)
                
            }
            
            print("FINISHED")
            
        })
        
    }
    
    //Creates a new Notification based on matching notification found in "Unread Notifications"
    func addNotification(message: String, user: String, recipient: String, timestamp: String, key: String) {
        
        let addNotification = Database.database().reference().child("Notifications").child(UserDefaults.standard.string(forKey: "username")!)
        
        let postDictionary = ["Message": message,
                              "User": user,
                              "Recipient": recipient,
                              "Timestamp": timestamp] as [String : Any]
        
        let autoID = addNotification.childByAutoId()
        
        autoID.setValue(postDictionary) {
            (error, reference) in
            
            if(error != nil) {
                print(error!)
            }
            else {
                print("Refreshed")
                
                let dbNotification = Notification()
                dbNotification.message = message
                dbNotification.user = user
                dbNotification.recipient = recipient
                dbNotification.timestamp = timestamp
                dbNotification.key = autoID.key
                
                self.notificationArray.append(dbNotification)
                
                self.notificationArray = self.notificationArray.sorted(by: {$0.timestamp >= $1.timestamp})
                
                self.notificationsTableview.reloadData()
                
                Database.database().reference().child("Unread Notifications").child(UserDefaults.standard.string(forKey: "username")!).child(key).removeValue()
            }
        }
    }
    

}
