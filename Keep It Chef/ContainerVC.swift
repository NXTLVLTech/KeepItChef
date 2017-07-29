//
//  ContainerVC.swift
//  Keep It Chef
//
//  Created by amrun on 28/07/17.
//  Copyright © 2017 NXTLVL. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift

class ContainerVC: SlideMenuController {

    override func awakeFromNib() {
        
        SlideMenuOptions.contentViewScale = 1
        
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") {
            self.mainViewController = controller
        }
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "LeftVC") {
            self.leftViewController = controller
        }
        super.awakeFromNib()
    }
}
