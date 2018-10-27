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
                    
                    print("Success! Got the songs")
                    let dataJSON : JSON = JSON(response.result.value!)
                    
                    //Parse songs
                    var y = 0
                    
                    while (dataJSON["items"][y] != JSON.null) {
                        
                        let name = dataJSON["items"][y]["track"]["name"].string!
                        let artist = dataJSON["items"][y]["track"]["artists"][0]["name"].string!
                        let id = dataJSON["items"][y]["track"]["id"].string!
                        
                        let song = Song()
                        
                        song.name = name
                        song.artist = artist
                        song.id = id
                        
                        print("\(y + 1).\t \"\(name)\" - \(artist)")
                        
                        y += 1
                    }
                    
                    print("Got all songs")
                    
                }
                else {
                    print("Error: \(String(describing: response.result.error!))")
                }
        }
        
        playlistTableview.deselectRow(at: indexPath, animated: true)
        
    }
    
}
