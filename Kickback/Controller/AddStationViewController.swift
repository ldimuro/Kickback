//
//  AddStationViewController.swift
//  Kickback
//
//  Created by Lou DiMuro on 7/18/18.
//  Copyright © 2018 Lou DiMuro. All rights reserved.
//

import UIKit
import Firebase

class AddStationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var stationNameTextfield: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    let cellData = ["Add Playlists", "Add Friends"]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        AddStationData.addedFriends.removeAll()
        AddStationData.addedPlaylists.removeAll()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        //Makes profile picture a circle
        profilePicture.layer.masksToBounds = false
        profilePicture.layer.borderColor = UIColor.black.cgColor
        profilePicture.layer.cornerRadius = profilePicture.frame.height/2
        profilePicture.clipsToBounds = true
        profilePicture.image = UserDataArray.profilePicture
        
        stationNameTextfield.becomeFirstResponder()
        stationNameTextfield.delegate = self
        if (stationNameTextfield.text?.isEmpty)!{
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
        tableView.register(UINib(nibName: "AddStationTableViewCell", bundle: nil), forCellReuseIdentifier: "addStationCell")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "addStationCell", for: indexPath) as! AddStationTableViewCell
        
        cell.label.text = cellData[indexPath.row]
        
        if indexPath.row == 0 {
            if AddStationData.addedPlaylists.count != 0 {
                cell.countLabel.text = "\(AddStationData.addedPlaylists.count)"
            } else {
                cell.countLabel.text = ""
            }
        }
        else if indexPath.row == 1 {
            if AddStationData.addedFriends.count != 0 {
                cell.countLabel.text = "\(AddStationData.addedFriends.count)"
            } else {
                cell.countLabel.text = ""
            }
        }
        
        //Sets highlight color of cell (when selected)
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red: 1.0, green: 0.761, blue: 0.749, alpha: 1.0)
        cell.selectedBackgroundView = bgColorView
        
        return cell
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellData.count
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if !text.isEmpty{
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            self.performSegue(withIdentifier: "goToAddFriends", sender: self)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    @IBAction func createStationButton(_ sender: Any) {
        
        AddStationData.addedFriends.append(UserDefaults.standard.string(forKey: "username")!)
        
        if AddStationData.addedFriends.count == 0 {
            AddStationData.addedFriends.append("N/A")
        }
        
        if AddStationData.addedPlaylists.count == 0 {
            AddStationData.addedPlaylists.append("N/A")
        }
        
        saveStation()
        saveNotification()
        
        print(AddStationData.addedFriends)
        
        stationNameTextfield.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
    }
    
    //Save station to Firebase
    func saveStation() {
        
        let addStation = Database.database().reference().child("Stations").child("\(Auth.auth().currentUser!.uid)")
        let timestamp = "\(Date())"
        
        let postDictionary = ["Name": stationNameTextfield.text!,
                              "User": UserDefaults.standard.string(forKey: "username")!,
                              "Owner": UserDefaults.standard.string(forKey: "username")!,
                              "Friends": AddStationData.addedFriends,
                              "Playlists": AddStationData.addedPlaylists,
                              "Timestamp": timestamp] as [String : Any]
        
        addStation.childByAutoId().setValue(postDictionary) {
            (error, reference) in
            
            if(error != nil) {
                print(error!)
            }
            else {
                print("Station saved successfully")
                self.saveSharedStations(owner: UserDefaults.standard.string(forKey: "username")!)
            }
        }
    }
    
    //Save notification to "Unread Notifications" in Firebase
    func saveNotification() {
        
        for x in 0..<AddStationData.addedFriends.count {
            
            let postDictionary = ["Message": "\(UserDefaults.standard.string(forKey: "username")!) added you to \"\(stationNameTextfield.text!)\"",
                                  "User": UserDefaults.standard.string(forKey: "username")!,
                                  "Recipient": AddStationData.addedFriends[x],
                                  "Timestamp": "\(Date())"] as [String : Any]
            
            let addNotification = Database.database().reference().child("Unread Notifications").child("\(AddStationData.addedFriends[x])")
            
            let autoID = addNotification.childByAutoId()
            
            autoID.setValue(postDictionary) {
                (error, reference) in
                
                if(error != nil) {
                    print(error!)
                }
                else {
                    print("Notification sent successfully")
                    print(autoID.key!)
                }
            }
        }
    }
    
    //Save shared station to "Shared Stations" in Firebase
    func saveSharedStations(owner: String) {
        
        let addSharedStation = Database.database().reference().child("Shared Stations")
        let timestamp = "\(Date())"
        
        for x in 0..<AddStationData.addedFriends.count {
            
            var friendArray = AddStationData.addedFriends.filter {$0 != AddStationData.addedFriends[x]}
            friendArray.append(owner)
            
            if friendArray.isEmpty {
                friendArray.append("N/A")
            }
            
            let postDictionary = ["Name": stationNameTextfield.text!,
                                  "User": AddStationData.addedFriends[x],
                                  "Owner": owner,
                                  "Friends": friendArray,
                                  "Playlists": AddStationData.addedPlaylists,
                                  "Timestamp": timestamp] as [String : Any]
            
            let autoID = addSharedStation.childByAutoId()
            
            autoID.setValue(postDictionary) {
                (error, reference) in
                
                if(error != nil) {
                    print(error!)
                }
                else {
                    print("Station shared successfully")
//                    print(autoID.key)
                }
            }
        }
        
        
        
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        
        if stationNameTextfield.text != "" {
            showAlert()
        } else {
            stationNameTextfield.resignFirstResponder()
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    func showAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler:{ (UIAlertAction)in
            print("User clicked Cancel button")
        }))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive , handler:{ (UIAlertAction)in
            print("User clicked Delete button")
            
            self.stationNameTextfield.resignFirstResponder()
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    

}

struct AddStationData {
    static var addedFriends = [String]()
    static var addedPlaylists = [String]()
}
