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
import AlamofireObjectMapper

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
            .responseArray(keyPath: "items") { (response: DataResponse<[Song]>) in
                if response.result.isSuccess {
                    
                    print("Success! Got the songs")
                    
                    let songArray = response.result.value!;
                    
                    var count = 1
                    for song in songArray {
                        print("\(count).\t\"\(song.name!)\" - \(song.artist!) (\(song.id!))")
                        count += 1
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
