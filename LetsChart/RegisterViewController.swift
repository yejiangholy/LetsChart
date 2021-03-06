//
//  RegisterViewController.swift
//  LetsChart
//
//  Created by JiangYe on 6/11/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController , UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    @IBOutlet weak var emailTextField: UITextField!
 
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    var newUser:BackendlessUser?
    var email:String?
    var username:String?
    var password:String?
    var avatarImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = false
        newUser = BackendlessUser()
        
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard as UIInputViewController -> () -> Void))
        view.addGestureRecognizer(tap)
      
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    
    

   //MARK: IBActions
    
    @IBAction func registerButtonPressed(sender: AnyObject) {
        
        if emailTextField.text != "" && usernameTextField.text != "" && passwordTextField.text != "" {
            
            
        // check if it is a valid email address
            if !(isValidEmail(emailTextField.text!)){
                
                ProgressHUD.showError("Please enter a valid e-mail address")
                
            } else {
                
                if (passwordTextField.text!.characters.count < 7)
                {
                    ProgressHUD.showError("password at least have 7 characters")
                    
                }else {
                    
                    emailHasBeenRegistered(emailTextField.text!, result: { (result) in
                        
                        if result == true {
                            
                            ProgressHUD.showError("Account already exist Please Login")
                            
                        } else {
                            
                            ProgressHUD.show("Registering...")
                            
                            self.email = self.emailTextField.text
                            self.username = self.usernameTextField.text
                            self.password = self.passwordTextField.text
                            
                            self.register(self.email!, username: self.username!, password: self.password!, avatarImage: self.avatarImage)
                        }
                    })
                }
            }
            
        } else{
            //worning to user ..
            ProgressHUD.showError("All fields are required")
        }
        
    }
    
    
    @IBAction func uploadPhotoButtonPressed(sender: AnyObject) {
        
    let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let camera = Camera(delegate_: self)
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .Default) { (alert: UIAlertAction!) in
            
            camera.PresentPhoteCamera(self, canEdit: true)
            
            
        }
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .Default) { (alert : UIAlertAction!) in
            
            camera.PresentPhotoLibrary(self, canEdit: true)
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert: UIAlertAction!) in
        }
        
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    //MARK: UIImagepickercontroller delegate  
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        self.avatarImage = info[UIImagePickerControllerEditedImage] as? UIImage
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        
    }
    
    //MARK: Backendless user registration 
    func register(email:String , username:String , password: String , avatarImage: UIImage?)
    {
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        if avatarImage == nil{
            newUser!.setProperty("Avatar", object: "")
        } else {
            
            uploadAvatar(avatarImage!, result: { (imageLink) in
                
                let properties = ["Avatar" : imageLink!]
                
                backendless.userService.currentUser!.updateProperties(properties)
                
                backendless.userService.update(backendless.userService.currentUser, response: { (updatedUser: BackendlessUser!) in
                    print("Updated current user avatar")
                    
                    }, error: { (fault: Fault!) in
                        
                        print("Error could't set avatar image:\(fault)")
                })
            })
        }
        
        newUser!.setProperty("FriendsList", object: "")
        newUser!.email  = email
        newUser!.name = username
        newUser!.password = password
        
        backendless.userService.registering(newUser, response: {(registerUser: BackendlessUser!) -> Void in
            
            ProgressHUD.dismiss() // dismiss log in animation 
            
              //log in new user 
            self.loginUser(email, username: username, password: password)
            
            //empty text fields
             self.emailTextField.text = ""
             self.passwordTextField.text = ""
             self.usernameTextField.text = ""
            
            }, error: {(fault: Fault!)-> Void in
                 print("Server reported an error, could't register new user: \(fault)")})
    }
    
    func loginUser(email:String, username:String, password:String)
    {
        backendless.userService.login(email, password: password, response: { (user : BackendlessUser!) -> Void in
            
              registerUserDeviceId()
            
              //segue to recents view controller
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ChatVC") as! UITabBarController
            self.presentViewController(vc, animated: true, completion: nil)
            
             vc.selectedIndex = 0
            
        }) { (fault:Fault!) -> Void in
                print("Server reported an error: \(fault)")
        }
    }
    
    
}
