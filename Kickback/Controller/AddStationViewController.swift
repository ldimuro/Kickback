//
//  AddStationViewController.swift
//  Kickback
//
//  Created by Lou DiMuro on 7/18/18.
//  Copyright © 2018 Lou DiMuro. All rights reserved.
//

import UIKit

class AddStationViewController: UIViewController {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var stationNameTextfield: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePicture.image = UserDataArray.profilePicture
        
        stationNameTextfield.becomeFirstResponder()
        
        let navBarHeight = UIApplication.shared.statusBarFrame.height +
            self.navigationController!.navigationBar.frame.height
        
        let scrollViewHeight = self.view.frame.size.height - navBarHeight
        print("SCROLLVIEW HEIGHT: \(scrollViewHeight)")
        
        let scrollViewDifference = self.view.frame.size.height - scrollViewHeight - 1
        
        print("HEIGHT: \(self.view.frame.size.height)\nSCROLL DIFFERENCE: \(scrollViewDifference)")
        print(self.view.frame.size.height - scrollViewDifference)
        
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height - scrollViewDifference)
        
        
        let tapGestureBackground = UITapGestureRecognizer(target: self, action: #selector(self.backgroundTapped(_:)))
        self.view.addGestureRecognizer(tapGestureBackground)

    }
    
    @objc func backgroundTapped(_ sender: UITapGestureRecognizer) {
        self.isEditing = false
        stationNameTextfield.resignFirstResponder()
        print("background tapped")
    }

    @IBAction func createStationButton(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
