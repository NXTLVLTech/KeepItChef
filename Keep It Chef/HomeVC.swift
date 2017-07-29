//
//  HomeVC.swift
//  Keep It Chef
//
//  Created by amrun on 28/07/17.
//  Copyright © 2017 NXTLVL. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

class HomeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.hideTransparentNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.hideTransparentNavigationBar()
    }
    
    @IBAction func sidemenu(_ sender: Any) {
        
        slideMenuController()?.toggleLeft()
        self.slideMenuController()?.addLeftGestures()
    }

    @IBAction func signout(_ sender: Any) {
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            
            
            SVProgressHUD.show()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                try! Auth.auth().signOut()
                FBSDKAccessToken.setCurrent(nil)  //facebook
                
                self.performSegue(withIdentifier: "unwindToLoginVC", sender: self)
                SVProgressHUD.dismiss()
            }
            
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
