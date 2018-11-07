//
//  AddPlaylistViewController.swift
//  Kickback
//
//  Created by Lou DiMuro on 11/7/18.
//  Copyright © 2018 Lou DiMuro. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class AddPlaylistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var playlistTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playlistTable.delegate = self
        playlistTable.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserDataArray.playlists.count
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = playlistTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = UserDataArray.playlists[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

}
