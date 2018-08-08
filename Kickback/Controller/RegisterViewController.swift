//
//  RegisterViewController.swift
//  Kickback
//
//  Created by Lou DiMuro on 7/23/18.
//  Copyright © 2018 Lou DiMuro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import PKHUD

class RegisterViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    
    let defaultProfilePicArray = ["default-user-lightblue", "default-user-green", "default-user-red", "default-user-orange", "default-user-blue", "default-user-purple"]
    
    let defaultProfilePictures = [#imageLiteral(resourceName: "default-user-red"), #imageLiteral(resourceName: "default-user-blue"), #imageLiteral(resourceName: "default-user-green"), #imageLiteral(resourceName: "default-user-orange"), #imageLiteral(resourceName: "default-user-purple"), #imageLiteral(resourceName: "default-user-lightblue")]
    
    var userArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAllUsers()
        
        signupButton.layer.cornerRadius = 25

        self.hideKeyboardWhenTappedAround()
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
        
        Database.database().reference().child("Users").child(username).setValue(["Email": email,
                                                                                 "Profile Picture": "N/A",
                                                                                 "Friends": ["N/A"]])
        
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.synchronize()
        
        createProfilePic()
        
    }
    
    func createProfilePic() {
        
        var image = defaultProfilePictures[Int(arc4random_uniform(UInt32(defaultProfilePictures.count)))]
        image = image.resizeWithWidth(width: 256)!
        
        UserDataArray.profilePicture = image
        
        //Save Profile Picture to Firebase
        var data = Data()
        data = UIImageJPEGRepresentation(image, 0.5)!
        
        let filepath = "Profile Pictures/\(UserDefaults.standard.string(forKey: "username")!)-profile"
        let storageRef = Storage.storage().reference().child(filepath)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        storageRef.putData(data, metadata: metaData){(metaData, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            } else {
                storageRef.downloadURL(completion: { (url, error) in
                    if let error = error {
                        print(error)
                    } else {
                        let downloadURL = url
                        Database.database().reference().child("Users").child(UserDefaults.standard.string(forKey: "username")!).updateChildValues(["Profile Picture": "\(downloadURL!)"])
                        UserDefaults.standard.set("\(downloadURL!)", forKey: "profilePicture")
                        UserDefaults.standard.synchronize()
                    }
                })
            }
        }
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

extension UIImage {
    func resizeWithPercent(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}
