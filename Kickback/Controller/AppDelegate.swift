//
//  AppDelegate.swift
//  Kickback
//
//  Created by Lou DiMuro on 7/15/18.
//  Copyright © 2018 Lou DiMuro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        //Checks whether or not the user is signed in
        let userLoginStatus = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
        
        if(userLoginStatus)
        {
            print("USER IS LOGGED IN")
            
            let username = UserDefaults.standard.string(forKey: "username")
            
            //Load Profile Picture
            let filePath = "Profile Pictures/\(username!)-profile"
            Storage.storage().reference().child(filePath).getData(maxSize: 10*1024*1024, completion: { (data, error) in
                
                let userPhoto = UIImage(data: data!)
                UserDataArray.profilePicture = userPhoto
            })
            
            //Get user friends
            let friendRef = Database.database().reference().child("Users").child(UserDefaults.standard.string(forKey: "username")!).child("Friends")
            
            friendRef.observeSingleEvent(of: .value) { (snapshot) in
                for snap in snapshot.children {
                    
                    let friend = (snap as! DataSnapshot).value! as! String
                    
                    if friend != "N/A" {
                        UserDataArray.friends.append(friend)
                    }
                }
            }
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main" , bundle: nil)
            
            let homepage = mainStoryboard.instantiateViewController(withIdentifier: "mainTab") as! TabBarViewController
            window!.rootViewController = homepage
            window!.makeKeyAndVisible()
            
        } else {
            print("USER IS NOT LOGGED IN")
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

