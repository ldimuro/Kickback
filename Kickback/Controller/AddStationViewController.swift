//
//  AddStationViewController.swift
//  Kickback
//
//  Created by Lou DiMuro on 7/18/18.
//  Copyright © 2018 Lou DiMuro. All rights reserved.
//

import UIKit

class AddStationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var stationNameTextfield: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    let cellData = ["Add Playlists", "Add Friends"]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        tableView.register(UINib(nibName: "AddStationTableViewCell", bundle: nil), forCellReuseIdentifier: "addStationCell")
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "addStationCell", for: indexPath) as! AddStationTableViewCell
        
        cell.label.text = cellData[indexPath.row]
        
        return cell
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellData.count
    }

    @IBAction func createStationButton(_ sender: Any) {
        
        stationNameTextfield.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        
        stationNameTextfield.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
    }
    

}
