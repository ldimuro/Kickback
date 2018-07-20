//
//  SettingsViewController.swift
//  Kickback
//
//  Created by Lou DiMuro on 7/19/18.
//  Copyright © 2018 Lou DiMuro. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func logOutButton(_ sender: Any) {
        
        try! Auth.auth().signOut()
        
        //Logs user out on phone
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
        UserDefaults.standard.synchronize()
        
        self.performSegue(withIdentifier: "logout", sender: self)
    }
    

}
