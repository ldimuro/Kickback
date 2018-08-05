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
import FirebaseStorage
import PKHUD

class ViewController: UIViewController {

    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var login: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        login.layer.cornerRadius = 25
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func loginButton(_ sender: Any) {
        
        HUD.show(.labeledProgress(title: "Logging In" , subtitle: ""))
        
        Auth.auth().signIn(withEmail: usernameTextfield.text!, password: passwordTextfield.text!) { (user, error) in
            
            if error != nil {
                print("error")
                HUD.hide()
                HUD.flash(.labeledError(title: "Login Failed", subtitle: "Re-enter email or password") , delay: 2)
                self.passwordTextfield.text = ""
            }
            else {
                print("Login successful")
                HUD.hide()
                HUD.flash(.labeledSuccess(title: "Login Successful", subtitle: ""), delay: 0.2)
                
                self.getUser()
                
                //Saves login so user doesn't have to sign in every time the app is launched
                UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
                UserDefaults.standard.synchronize()
                
                self.performSegue(withIdentifier: "goToHome", sender: self)
            }
        }
    }
    
    func getUser() {
        
        let email = usernameTextfield.text!
        let ref = Database.database().reference().child("Users").queryOrdered(byChild: "Email").queryEqual(toValue: email)
        
        ref.observeSingleEvent(of: .value, with:{ (snapshot: DataSnapshot) in
            
            for snap in snapshot.children {
                
                let snapKey = snap as! DataSnapshot
                let key = snapKey.key
                
                let value = snapKey.value as! Dictionary<String,Any>
                let profilePic = value["Profile Picture"] as! String
                
                UserDefaults.standard.set(key, forKey: "username")
                UserDefaults.standard.set(profilePic, forKey: "profilePicture")
                UserDefaults.standard.synchronize()
                
                let filePath = "Profile Pictures/\(key)-profile"
                // Assuming a < 10MB file, though you can change that
                Storage.storage().reference().child(filePath).getData(maxSize: 10*1024*1024, completion: { (data, error) in
                    
                    let userPhoto = UIImage(data: data!)
                    UserDataArray.profilePicture = userPhoto
                })
            }
        })
    }


}

struct UserDataArray {
    static var profilePicture : UIImage?
}

