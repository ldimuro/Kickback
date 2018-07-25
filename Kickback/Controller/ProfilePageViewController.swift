//
//  ProfilePageViewController.swift
//  Kickback
//
//  Created by Lou DiMuro on 7/23/18.
//  Copyright © 2018 Lou DiMuro. All rights reserved.
//

import UIKit
import Firebase

class ProfilePageViewController: UIViewController {

    @IBOutlet weak var profilePicture: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePicture.image = UIImage(named: UserDefaults.standard.string(forKey: "profilePicture")!)
        navigationItem.title = UserDefaults.standard.string(forKey: "username")
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        
        try! Auth.auth().signOut()
        
        //Logs user out on phone
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
        UserDefaults.standard.synchronize()
        
        self.performSegue(withIdentifier: "logout", sender: self)
    }
    
    
}
