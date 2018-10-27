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
        
        self.hideKeyboardWhenTappedAround()
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
                
                self.getUser { (success) -> Void in
                    
                    if success {
                        print("GOT USER INFO FOR: \(UserDefaults.standard.string(forKey: "username")!)")
                        
                        //DELAYS FOR A SECOND TO GIVE TIME TO COMMUNICATE INFORMATION WITH SERVER
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // in a second...
                            
                            //Go to home page
                            self.performSegue(withIdentifier: "goToHome", sender: self)
                            
                            //Saves login so user doesn't have to sign in every time the app is launched
                            UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
                            UserDefaults.standard.synchronize()
                        }
                    }
                }
            }
        }
    }
    
    func getUser(completion: (_ success: Bool) -> Void) {
        
        let email = usernameTextfield.text!
        let ref = Database.database().reference().child("Users").queryOrdered(byChild: "Email").queryEqual(toValue: email)
        
        ref.observeSingleEvent(of: .value, with:{ (snapshot: DataSnapshot) in
            
            for snap in snapshot.children {
                
                let snapKey = snap as! DataSnapshot
                let key = snapKey.key
                
                print("Username: \(key)")
                
                let value = snapKey.value as! Dictionary<String,Any>
                let profilePic = value["Profile Picture"] as! String
                
                UserDefaults.standard.set(key, forKey: "username")
                UserDefaults.standard.set(profilePic, forKey: "profilePicture")
                UserDefaults.standard.synchronize()
                
                print("USERNAME: \(key)")
                
                let filePath = "Profile Pictures/\(key)-profile"
                // Assuming a < 10MB file, though you can change that
                Storage.storage().reference().child(filePath).getData(maxSize: 10*1024*1024, completion: { (data, error) in
                    
                    let userPhoto = UIImage(data: data!)
                    UserDataArray.profilePicture = userPhoto
                })
                
                //GET USER FRIENDS
                let friendRef = Database.database().reference().child("Users").child(UserDefaults.standard.string(forKey: "username")!).child("Friends")
                
                friendRef.observeSingleEvent(of: .value) { (snapshot) in
                    for snap in snapshot.children {
                        
                        let friend = (snap as! DataSnapshot).value! as! String
                        
                        if friend != "N/A" {
                            UserDataArray.friends.append(friend)
                        }
                    }
                }
            }
        })
        
        completion(true)
        
    }


}

struct UserDataArray {
    static var profilePicture : UIImage?
    static var friends = [String]()
    static var playlists = [Playlist]()
    static var accessToken : String?
//    static var stations = [Station]()
}

//Adds the click away from keyboard functionality for use in any view controller with self.hideKeyboard when tapped around
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

