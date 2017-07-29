//
//  SignUpVC.swift
//  Keep It Chef
//
//  Created by amrun on 28/07/17.
//  Copyright © 2017 NXTLVL. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import SkyFloatingLabelTextField
import SDWebImage

class SignUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var usernameField: SkyFloatingLabelTextField!
    @IBOutlet weak var emailField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordField: SkyFloatingLabelTextField!
    @IBOutlet weak var signUP: UIButton!
    @IBOutlet weak var uploadImage: UIButton!
    @IBOutlet weak var profileImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setBackButton()
        self.title = "SIGN UP"
        
        profileImage.contentMode = .scaleAspectFill
        profileImage.clipsToBounds = true
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        
        signUP.addTarget(self, action:#selector(signUpPressed), for: .touchUpInside)
    }
    
    func signUpPressed() {
        
        SVProgressHUD.show()
        
        if requiredFieldsAreNotEmpty() {
            
        Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!, completion: {
            user, error in
            
            if error == nil {
                
                let key = Database.database().reference().child("Photos").childByAutoId().key
                let storageRef = Storage.storage().reference()
                let pictureStorageRef = storageRef.child("users/\(Auth.auth().currentUser!.uid)/photos/\(key)")
                
                let Data = UIImageJPEGRepresentation(self.profileImage.image!, 0.5)
                
                if(Data != nil){
                    
                    let uploadTask = pictureStorageRef.putData(Data!,metadata: nil)
                    {metadata,error in
                        
                        if(error == nil)
                        {
                            let downloadUrl = metadata!.downloadURL()
                            
                            let newUser:[String:Any] = [
                                "email"    : self.emailField.text! as String,
                                "createdAt": "\(Date.init().timeIntervalSince1970)" as String,
                                "uid": Auth.auth().currentUser!.uid as String,
                                "username": self.usernameField.text! as String,
                                "image": downloadUrl!.absoluteString as String,
                                 ]
                            
                            Database.database().reference().child("users").child((user?.uid)!).updateChildValues(newUser) { (error, ref) in
                                if error == nil{
                                    
                                    SVProgressHUD.dismiss()
                                    
                                    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                    let vc = storyboard.instantiateViewController(withIdentifier: "ContainerNav") as! UINavigationController
                                    vc.modalPresentationStyle = .custom
                                    vc.modalTransitionStyle = .crossDissolve
                                    self.present(vc, animated: true, completion: nil)
                            
                                }else{
                                    // error creating user
                                    print(error!.localizedDescription)
                                    SVProgressHUD.dismiss()
                                    let alert = UIAlertController(title: "Alert!", message: "\(error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                            
                        }else{
                            print(error!.localizedDescription)
                            SVProgressHUD.dismiss()
                            let alert = UIAlertController(title: "Alert!", message: "\(error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
                if(Data == nil){
                    print("image data is nil")
                }
            }else{
                
                print(error!.localizedDescription)
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: "Alert!", message: "\(error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
      }else{
            SVProgressHUD.dismiss()
            let alert = UIAlertController(title: "Empty Field", message: "Please provide all information.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
      }
    }
    
    @IBAction func addPhotoPressed(_ sender: Any) {
        let alert = UIAlertController.init(title: "Upload Profile Image", message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction.init(title: "Camera", style: .default) { (action) in
            self.openImagePicker(.camera)
        }
        let action2 = UIAlertAction.init(title: "Photos", style: .default) { (action) in
            self.openImagePicker(.photoLibrary)
        }
        let action3 = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in }
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openImagePicker(_ sourceType:UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = sourceType
        imagePicker.navigationBar.titleTextAttributes = [
          NSForegroundColorAttributeName : UIColor.white
        ]
        self.navigationController?.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        self.profileImage.image = image
        self.uploadImage.setImage(nil, for: .normal)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func requiredFieldsAreNotEmpty() -> Bool {
        return !(self.usernameField.text == "" || self.emailField.text == "" || self.passwordField.text == "" || self.profileImage.image == nil)
    }

}
