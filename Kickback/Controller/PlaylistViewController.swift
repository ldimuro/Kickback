//
//  PlaylistViewController.swift
//  Kickback
//
//  Created by Lou DiMuro on 10/21/18.
//  Copyright © 2018 Lou DiMuro. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class PlaylistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var playlistTableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playlistTableview.delegate = self
        playlistTableview.dataSource = self
        
        

        // Do any additional setup after loading the view.
    }
    
    //setup functions sideNave main TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return UserDataArray.playlists.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = playlistTableview.dequeueReusableCell(withIdentifier: "cell")!
        
        cell.textLabel?.text = UserDataArray.playlists[indexPath.row].name
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToPlaylistSongs", sender: self)
        
        let header = ["Authorization": "Bearer \(UserDataArray.accessToken!)"]
        
        Alamofire.request(UserDataArray.playlists[indexPath.row].href, method: .get, parameters: [:], headers: header)
            .responseJSON { response in
                if response.result.isSuccess {
                    
                    print("Success! Got the data")
                    let dataJSON : JSON = JSON(response.result.value!)
                    
                    print(dataJSON["items"][0]["track"]["name"].string!)
                    
//                    self.getPlaylistSongs(json: dataJSON)
                    
                }
                else {
                    print("Error: \(String(describing: response.result.error!))")
                }
        }
        
        playlistTableview.deselectRow(at: indexPath, animated: true)
    }
    
    func getPlaylistSongs(json: JSON) {
        
        var x = 0
        
        while (json["items"][x]["name"].string != nil) {
            
            let song = Song()
            
            let name = json["items"][x]["track"]["name"].string!
            let artist = json["items"][x]["track"]["artists"][0]["name"].string!
            let id = json["items"][x]["track"]["id"].string!
            
            print("\(x). \(name) - \(artist)")
            
            x += 1
            
        }
        
    }
    
}
