//
//  ProfilePageViewController.swift
//  Kickback
//
//  Created by Lou DiMuro on 7/23/18.
//  Copyright © 2018 Lou DiMuro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import Photos

class ProfilePageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var backdrop: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getProfilePicture()
        
        imagePicker.delegate = self
        
        //Makes profile picture a circle
        profilePicture.layer.masksToBounds = false
        profilePicture.layer.borderColor = UIColor.black.cgColor
        profilePicture.layer.cornerRadius = profilePicture.frame.height/2
        profilePicture.clipsToBounds = true
        
        profilePicture.image = UIImage(named: UserDefaults.standard.string(forKey: "profilePicture")!)
        backdrop.image = UIImage(named: UserDefaults.standard.string(forKey: "profilePicture")!)
        
        usernameLabel.text = UserDefaults.standard.string(forKey: "username")
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        
        try! Auth.auth().signOut()
        
        //Logs user out on phone
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
        UserDefaults.standard.synchronize()
        
        self.performSegue(withIdentifier: "logout", sender: self)
    }
    
    
    @IBAction func editProfilePicture(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        checkPermission()
        
//        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profilePicture.contentMode = .scaleAspectFill
            backdrop.contentMode = .scaleToFill
            backdrop.image = pickedImage
            profilePicture.image = pickedImage
            
            
            //Save Profile Picture to Firebase
            var data = Data()
            data = UIImageJPEGRepresentation(profilePicture.image!, 0.8)!
            
            let filepath = "Profile Pictures/\(UserDefaults.standard.string(forKey: "username")!)-profile"
            let storageRef = Storage.storage().reference().child(filepath)
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
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
                            UserDefaults.standard.set("\(downloadURL)", forKey: "profilePicture")
                        }
                    })
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoAuthorizationStatus {
            case .authorized:
                print("Access is granted by user")
                present(imagePicker, animated: true, completion: nil)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({
                    (newStatus) in
                    print("status is \(newStatus)")
                    if newStatus ==  PHAuthorizationStatus.authorized {
                        self.present(self.imagePicker, animated: true, completion: nil)
                        print("success")
                    }
                })
                print("It is not determined until now")
            case .restricted:
                // same same
                print("User do not have access to photo album.")
            case .denied:
                // same same
                print("User has denied the permission.")
        }
    }
    
    func getProfilePicture() {
        let username = UserDefaults.standard.string(forKey: "username")
        
        Database.database().reference().child("Users").child(username!).observeSingleEvent(of: .value, with: { (snapshot) in
            // check if user has photo
            if snapshot.hasChild("Profile Picture"){
                // set image locatin
                let filePath = "Profile Pictures/\(username!)-profile"
                // Assuming a < 10MB file, though you can change that
                Storage.storage().reference().child(filePath).getData(maxSize: 10*1024*1024, completion: { (data, error) in
                    
                    let userPhoto = UIImage(data: data!)
                    self.profilePicture.image = userPhoto
                    self.backdrop.image = userPhoto
                })
            }
        })
    }
    
}
