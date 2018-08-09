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

class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var notificationsTableview: UITableView!
    
    let data = ["Notification1", "Notification2", "Notification3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("NOTIFICATIONS LOADED")
        checkNotifications()
        
        notificationsTableview.delegate = self
        notificationsTableview.dataSource = self

        notificationsTableview.register(UINib(nibName: "NotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "notificationCell")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationTableViewCell
        
        cell.messageLabel.text = data[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    //Searches through "Unread Notifications" for current user
    func checkNotifications() {
        
        let ref = Database.database().reference().child("Unread Notifications").queryOrdered(byChild: "Recipient").queryEqual(toValue: UserDefaults.standard.string(forKey: "username"))
        
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
    
    //Creates a new Task based on matching task found in "Tasks to Share"
    func addNotification(message: String, user: String, recipient: String, timestamp: String, key: String) {
        
        let addNotification = Database.database().reference().child("Notifications").child(UserDefaults.standard.string(forKey: "username")!)
        
        let postDictionary = ["Message": message,
                              "User": user,
                              "Recipient": recipient,
                              "Timestamp": timestamp] as [String : Any]
        
        addNotification.childByAutoId().setValue(postDictionary) {
            (error, reference) in
            
            if(error != nil) {
                print(error!)
            }
            else {
                print("Refreshed")
                Database.database().reference().child("Unread Notifications").child(key).removeValue()
            }
        }
    }
    

}
