//
//  RegisterViewController.swift
//  Kickback
//
//  Created by Lou DiMuro on 7/23/18.
//  Copyright © 2018 Lou DiMuro. All rights reserved.
//

import UIKit
import Firebase
import PKHUD

class RegisterViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    
    let defaultProfilePicArray = ["default-user-lightblue", "default-user-green", "default-user-red", "default-user-orange", "default-user-blue", "default-user-purple"]
    
    var userArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAllUsers()
        
        signupButton.layer.cornerRadius = 25

        // Do any additional setup after loading the view.
    }

    @IBAction func signup(_ sender: Any) {
        
        HUD.show(.labeledProgress(title: "Registering" , subtitle: ""))
        
        if self.userArray.contains(usernameTextfield.text!) {
            print("EXISTS")
            HUD.hide()
            HUD.flash(.labeledError(title: "Username exists", subtitle: "") , delay: 2)
            usernameTextfield.text = ""
        }
        else {
            
            Auth.auth().createUser(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in
                
                if error != nil {
                    print("error")
                    HUD.hide()
                    HUD.flash(.labeledError(title: "Login Failed", subtitle: "Re-enter email and Password") , delay: 2)
                    self.emailTextfield.text = ""
                    self.passwordTextfield.text = ""
                    self.usernameTextfield.text = ""
                }
                else {
                    print("User created")
                    
                    self.addUser()
                    
                    HUD.hide()
                    HUD.flash(.labeledSuccess(title: "User created", subtitle: self.usernameTextfield.text), delay: 0.2)
                    
                    //Saves login so user doesn't have to sign in every time the app is launched
                    UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
                    UserDefaults.standard.synchronize()
                    
                    self.performSegue(withIdentifier: "goToHome", sender: self)
                }
            }
        }
        
        
        
    }
    
    //Adds user to Firebase if this is their first time logging in
    func addUser() {
        
        let email = emailTextfield.text!
        let username = usernameTextfield.text!
        let defaultProfilePic = "\(defaultProfilePicArray[Int(arc4random_uniform(UInt32(defaultProfilePicArray.count)))])"
        
        Database.database().reference().child("Users").child(username).setValue(["Email": email,
                                                                                 "Profile Picture": defaultProfilePic])
        
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(defaultProfilePic, forKey: "profilePicture")
        UserDefaults.standard.synchronize()
        
    }
    
    //Creates an array of all users in Firebase
    func getAllUsers() {
        
        let userDB = Database.database().reference().child("Users")
        
        userDB.observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key
//                let value = snap.value
//                print("key = \(key)  value = \(value!)")
                self.userArray.append(key)
            }
        })
        
    }
    
    

}
