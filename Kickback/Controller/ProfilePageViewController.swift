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
    @IBOutlet weak var editProfilePictureButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    let defaultProfilePictures = [#imageLiteral(resourceName: "default-user-red"), #imageLiteral(resourceName: "default-user-blue"), #imageLiteral(resourceName: "default-user-green"), #imageLiteral(resourceName: "default-user-orange"), #imageLiteral(resourceName: "default-user-purple"), #imageLiteral(resourceName: "default-user-lightblue")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePicture.image = UserDataArray.profilePicture
        backdrop.image = UserDataArray.profilePicture
        
        imagePicker.delegate = self
        
        //Makes profile picture a circle
        profilePicture.layer.masksToBounds = false
        profilePicture.layer.borderColor = UIColor.black.cgColor
        profilePicture.layer.cornerRadius = profilePicture.frame.height/2
        profilePicture.clipsToBounds = true
        
//        profilePicture.image = UIImage(named: UserDefaults.standard.string(forKey: "profilePicture")!)
//        backdrop.image = UIImage(named: UserDefaults.standard.string(forKey: "profilePicture")!)
        
        usernameLabel.text = UserDefaults.standard.string(forKey: "username")
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        profilePicture.alpha = 1.0
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        
        try! Auth.auth().signOut()
        
        //Logs user out on phone
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
        UserDefaults.standard.synchronize()
        
        self.performSegue(withIdentifier: "logout", sender: self)
    }
    
    
    @IBAction func editProfilePicture(_ sender: Any) {
//        editProfilePictureButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Selected)
        profilePicture.alpha = 0.5
        
        showAlert()
        
//        present(imagePicker, animated: true, completion: nil)
    }
    
    func showAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Choose Photo", style: .default , handler:{ (UIAlertAction)in
            print("User clicked Choose Photo")
            
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            
            self.checkPermission()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive , handler:{ (UIAlertAction)in
            print("User clicked Delete button")
            self.profilePicture.alpha = 1.0
            
            var image = self.defaultProfilePictures[Int(arc4random_uniform(UInt32(self.defaultProfilePictures.count)))]
            image = image.resizeWithWidth(width: 256)!
            self.profilePicture.image = image
            self.backdrop.image = image
            
            UserDataArray.profilePicture = image
            
            self.savePictureToFirebase()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            print("Cancelled")
            self.profilePicture.alpha = 1.0
        }))
        
        self.present(alert, animated: true, completion: {
            
        })
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if var pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            pickedImage = pickedImage.resizeWithWidth(width: 256)!
            
            profilePicture.contentMode = .scaleAspectFill
            backdrop.contentMode = .scaleToFill
            backdrop.image = pickedImage
            profilePicture.image = pickedImage
            
            UserDataArray.profilePicture = pickedImage
            
            savePictureToFirebase()
            
//            //Save Profile Picture to Firebase
//            var data = Data()
//            data = UIImageJPEGRepresentation(profilePicture.image!, 0.2)!
//
//            let filepath = "Profile Pictures/\(UserDefaults.standard.string(forKey: "username")!)-profile"
//            let storageRef = Storage.storage().reference().child(filepath)
//            let metaData = StorageMetadata()
//            metaData.contentType = "image/jpeg"
//            storageRef.putData(data, metadata: metaData){(metaData, error) in
//                if let error = error {
//                    print(error.localizedDescription)
//                    return
//                } else {
//                    storageRef.downloadURL(completion: { (url, error) in
//                        if let error = error {
//                            print(error)
//                        } else {
//                            let downloadURL = url
//                            Database.database().reference().child("Users").child(UserDefaults.standard.string(forKey: "username")!).updateChildValues(["Profile Picture": "\(downloadURL!)"])
//                            UserDefaults.standard.set("\(downloadURL!)", forKey: "profilePicture")
//                        }
//                    })
//                }
//            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func savePictureToFirebase() {
        //Save Profile Picture to Firebase
        var data = Data()
        data = UIImageJPEGRepresentation(profilePicture.image!, 0.2)!
        
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
                    }
                })
            }
        }
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
    
}


