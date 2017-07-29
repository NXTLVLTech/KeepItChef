//
//  ViewController.swift
//  Keep It Chef
//
//  Created by amrun on 27/07/17.
//  Copyright © 2017 NXTLVL. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import SkyFloatingLabelTextField

class LoginVC: UIViewController {
    
    @IBOutlet weak var emailField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordField: SkyFloatingLabelTextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var fblogin: UIButton!
    @IBOutlet weak var forgotPassword: UIButton!
    @IBOutlet weak var signupButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.presentTransparentNavigationBar()
        
        signInButton.layer.cornerRadius = 5
        signInButton.layer.masksToBounds = true
        signInButton.addTarget(self, action:#selector(self.signInPressed), for: .touchUpInside)
        
        fblogin.layer.cornerRadius = 5
        fblogin.layer.masksToBounds = true
        fblogin.addTarget(self, action:#selector(self.fbloginPressed), for: .touchUpInside)
        
        forgotPassword.addTarget(self, action:#selector(self.forgotPasswordPressed), for: .touchUpInside)
        
        signupButton.addTarget(self, action:#selector(self.signupPressed), for: .touchUpInside)
        
        isAppAlreadyLaunchedOnce()
       
    }
    
    func signupPressed() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func forgotPasswordPressed() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "recoverPasswordVC") as! recoverPasswordVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func signInPressed() {
        SVProgressHUD.show()
        
        if requiredFieldsAreNotEmpty() {
            
            Auth.auth().signIn(withEmail: self.emailField.text!, password: self.passwordField.text!, completion: {
                user, error in
                
                if error == nil {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.updateUIElements()
                        SVProgressHUD.dismiss()
                    }
                    
                } else {
                    
                    SVProgressHUD.dismiss()
                    let alert = UIAlertController(title: "Alert!", message: "\(error!)", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        } else {
            
            SVProgressHUD.dismiss() //indicator dismiss
            
            let alert = UIAlertController(title: "Empty Field", message: "Please enter an email and password", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    func fbloginPressed() {
        
        let facebookLogin = FBSDKLoginManager()
        
        print("Logging In")
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self, handler:{(facebookResult, facebookError) -> Void in
            
            if facebookError != nil {
                
                print("Facebook login failed.Error \(facebookError!)")
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: "Alert!", message: "\(facebookError!)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
                
            else if (facebookResult?.isCancelled)! {
                
                print("Facebook login was cancelled.")
                SVProgressHUD.dismiss()
            }
                
            else {
                print("You’re in")
                SVProgressHUD.show()
                
                let accessToken = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                
                Auth.auth().signIn(with: accessToken) { (user, error) in
                    
                    if error != nil {
                        print("Login Failed, \(error!)")
                        SVProgressHUD.dismiss()
                        let alert = UIAlertController(title: "Alert!", message: "\(error!)", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                    }else {
                        SVProgressHUD.show()
                        print("Logged in! \(user!)")
                        
                        self.checkIfUserExists(user!, completionHandler: { (exists) in
                            
                            if(exists){
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    self.updateUIElements()
                                    SVProgressHUD.dismiss()
                                }
                            }else{
                                
                                let params: [String : Any] = ["redirect": false, "height": 400, "width": 400, "type": "large"]
                                let pictureRequest = FBSDKGraphRequest(graphPath: "me/picture", parameters: params, httpMethod: "GET")
                                pictureRequest?.start(completionHandler: {
                                    (connection, result, error) -> Void in
                                    if error == nil {
                                        print("\(result!)")
                                        
                                        let dictionary = result as? [String:Any]
                                        let dataDic = dictionary?["data"] as? [String:Any]
                                        let urlPic = dataDic?["url"] as? String
                                        
                                        userModel.imageURL = urlPic!
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            
                                            SVProgressHUD.dismiss()
                                            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                            let vc = storyboard.instantiateViewController(withIdentifier: "ContainerNav") as! UINavigationController
                                            vc.modalPresentationStyle = .custom
                                            vc.modalTransitionStyle = .crossDissolve
                                            self.present(vc, animated: true, completion: nil)
                                        }
                                        
                                    } else {
                                        print("\(error)")
                                        SVProgressHUD.dismiss()
                                        let alert = UIAlertController(title: "Alert!", message: "\(error!)", preferredStyle: UIAlertControllerStyle.alert)
                                        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                                        self.present(alert, animated: true, completion: nil)
                                        
                                    }
                                })
                                
                                userModel.fullName = user!.displayName! as String
                                userModel.email = user!.email! as String
//                              donorModel.imageURL = user!.photoURL!.absoluteString as String
                                userModel.uid = user!.uid as String
                            }
                        })
                    }
                }
            }
        });
        
    }
    
    func checkIfUserExists(_ user: User, completionHandler: @escaping (Bool) -> ()) {
        Database.database().reference().child("users").child(user.uid).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            if snapshot.value is NSNull {
                completionHandler(false)
            } else {
                let userDict:[String:AnyObject] = snapshot.value as! [String:AnyObject]
                if(userDict["createdAt"] != nil){
                    completionHandler(true)
                } else{
                    completionHandler(false)
                }
            }
        }
    }
    
    func requiredFieldsAreNotEmpty() -> Bool {
        return !(self.emailField.text == "" || self.passwordField.text == "")
    }
    
    func updateUIElements() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ContainerNav") as! UINavigationController
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
    //Launch only First Time
    func isAppAlreadyLaunchedOnce()->Bool{
        
        let defaults = UserDefaults.standard
        if defaults.string(forKey: "isAppAlreadyLaunchedOnce") != nil{
            
            SVProgressHUD.show()
            print("App already launched")
            
            if (Auth.auth().currentUser) != nil {
                
                SVProgressHUD.show()
                let user = Auth.auth().currentUser
                self.checkIfUserExists(user!, completionHandler: { (exists) in
                    SVProgressHUD.show()
                    if(exists){
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.updateUIElements()
                            SVProgressHUD.dismiss()
                        }
                    }else{
                        SVProgressHUD.show()
                        
                        let params: [String : Any] = ["redirect": false, "height": 400, "width": 400, "type": "large"]
                        let pictureRequest = FBSDKGraphRequest(graphPath: "me/picture", parameters: params, httpMethod: "GET")
                        pictureRequest?.start(completionHandler: {
                            (connection, result, error) -> Void in
                            if error == nil {
                                print("\(result!)")
                                
                                let dictionary = result as? [String:Any]
                                let dataDic = dictionary?["data"] as? [String:Any]
                                let urlPic = dataDic?["url"] as? String
                                
                                userModel.imageURL = urlPic
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    
                                    SVProgressHUD.dismiss()
                                    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                    let vc = storyboard.instantiateViewController(withIdentifier: "ContainerNav") as! UINavigationController
                                    vc.modalPresentationStyle = .custom
                                    vc.modalTransitionStyle = .crossDissolve
                                    self.present(vc, animated: true, completion: nil)
                                }
                                
                            } else {
                                print("\(error)")
                            }
                        })
                        
                        userModel.fullName = user!.displayName! as String
                        userModel.email = user!.email! as String
                        userModel.uid = user!.uid as String
                        
                    }
                })
                
            }else {
                SVProgressHUD.dismiss()
            }
            return true
        }
        else {
            
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            print("App launched first time")
            
            do {
                SVProgressHUD.dismiss()
                try Auth.auth().signOut()
                walkthrough()
            }catch {
                //
            }
            
            return false
        }
    }
    
    func walkthrough() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "OnboardingVC") as! OnboardingVC
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    
    }
    
    @IBAction func unwindToLoginVC(segue: UIStoryboardSegue) {}

}

