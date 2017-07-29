//
//  recoverPasswordVC.swift
//  Keep It Chef
//
//  Created by amrun on 28/07/17.
//  Copyright © 2017 NXTLVL. All rights reserved.
//

import UIKit
import Firebase
import SkyFloatingLabelTextField

class recoverPasswordVC: UIViewController {

    @IBOutlet weak var emailField: SkyFloatingLabelTextField!
    @IBOutlet weak var recoverPassword: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setBackButton()
        self.title = "RECOVER PASSWORD"
        
        recoverPassword.layer.cornerRadius = 5
        recoverPassword.layer.masksToBounds = true
        recoverPassword.addTarget(self, action:#selector(self.recoverPasswordPressed), for: .touchUpInside)

    }
    
    func recoverPasswordPressed() {
        
    }
    
}
