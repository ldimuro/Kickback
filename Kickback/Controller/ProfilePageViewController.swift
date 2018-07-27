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
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var backdrop: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePicture.layer.masksToBounds = false
        profilePicture.layer.borderColor = UIColor.black.cgColor
        profilePicture.layer.cornerRadius = profilePicture.frame.height/2
        profilePicture.clipsToBounds = true
        
        profilePicture.image = UIImage(named: UserDefaults.standard.string(forKey: "profilePicture")!)
        backdrop.image = UIImage(named: UserDefaults.standard.string(forKey: "profilePicture")!)
        
        usernameLabel.text = UserDefaults.standard.string(forKey: "username")
//        navigationItem.title = UserDefaults.standard.string(forKey: "username")
        
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
