//
//  TabBarViewController.swift
//  Kickback
//
//  Created by Lou DiMuro on 7/18/18.
//  Copyright © 2018 Lou DiMuro. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self

        // Do any additional setup after loading the view.
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        // If your view controller is emedded in a UINavigationController you will need to check if it's a UINavigationController and check that the root view controller is your desired controller (or subclass the navigation controller)
        if viewController is AddStationNavigationViewController {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let controller = storyboard.instantiateViewController(withIdentifier: "stationNav") as? AddStationNavigationViewController {
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true, completion: nil)
            }
            
            return false
        }
        
        // Tells the tab bar to select other view controller as normal
        return true
    }
    
//    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        print("Selected item")
//    }
//
//    // UITabBarControllerDelegate
//    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        print("Selected view controller: \(viewController)")
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
