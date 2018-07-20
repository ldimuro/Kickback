//
//  ViewController.swift
//  Kickback
//
//  Created by Lou DiMuro on 7/15/18.
//  Copyright © 2018 Lou DiMuro. All rights reserved.
//

import UIKit
import UIKit
import Firebase
import PKHUD

class ViewController: UIViewController {

    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButton(_ sender: Any) {
        HUD.show(.labeledProgress(title: "Logging In" , subtitle: ""))
        
        Auth.auth().signIn(withEmail: usernameTextfield.text!, password: passwordTextfield.text!) { (user, error) in
            
            if error != nil {
                print("error")
                HUD.hide()
                HUD.flash(.labeledError(title: "Login Failed", subtitle: "Re-enter email and Password") , delay: 2.5)
            }
            else {
                print("Login successful")
                HUD.hide()
                HUD.flash(.labeledSuccess(title: "Login Successful", subtitle: ""), delay: 0.2)
                
                //Saves login so user doesn't have to sign in every time the app is launched
                UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
                UserDefaults.standard.synchronize()
                
                self.performSegue(withIdentifier: "goToHome", sender: self)
            }
            //            HUD.hide()
            //            HUD.flash(.labeledSuccess(title: "Login Successful", subtitle: ""), delay: 0.2)
            //            self.performSegue(withIdentifier: "goToHome", sender: self)
        }
    }


}

