//
//  SearchViewController.swift
//  Kickback
//
//  Created by Lou DiMuro on 7/23/18.
//  Copyright © 2018 Lou DiMuro. All rights reserved.
//

import UIKit
import Firebase

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var searchTable: UITableView!
    
    var isSearching = false
    var userArray = [String]()
    var filteredArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAllUsers()
        
        searchTable.delegate = self
        searchTable.dataSource = self
        searchbar.delegate = self
        searchbar.returnKeyType = UIReturnKeyType.done
        
        // Do any additional setup after loading the view.
        searchTable.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "searchCell")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTableViewCell
        
        cell.usernameLabel.text = filteredArray[indexPath.row]
        cell.profilePicture.image = UIImage(named: UserDefaults.standard.string(forKey: "profilePicture")!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredArray.count
    }
    
    //Search Bar functionality
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchBar.text == nil || searchBar.text == "") {
            isSearching = false
            view.endEditing(true)
            
            print("IS SEARCHING: \(isSearching)")
            
            filteredArray = [String]()
            
            searchTable.reloadData()
            
        }
        else {
            isSearching = true
            print("IS SEARCHING = \(isSearching)")
            
            filteredArray = userArray.filter({($0.contains(searchbar.text!.lowercased()))})
            
            print("Filtered data count: \(filteredArray.count)")
            print("Row data count: \(userArray.count)")
            
            searchTable.reloadData()
        }
        
    }
    
    //Creates an array of all users in Firebase
    func getAllUsers() {
        
        let userDB = Database.database().reference().child("Users")
        
        userDB.observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key
                
                if key != UserDefaults.standard.string(forKey: "username") {
                    self.userArray.append(key)
                }
            }
        })
    }
    

    
    

}
