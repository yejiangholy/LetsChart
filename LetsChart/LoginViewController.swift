//
//  LoginViewController.swift
//  LetsChart
//
//  Created by JiangYe on 6/11/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    let backendless = Backendless.sharedInstance()
    
    var email:String?
    var password:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         self.navigationController?.navigationBarHidden = false
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard as UIInputViewController -> () -> Void))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func CancelButtonPressed(sender: UIBarButtonItem) {
        
       self.navigationController?.popToRootViewControllerAnimated(true)
        
    }
    
    
    

    //MARK: IBActions
    
    @IBAction func loginBarButtonPressed(sender: AnyObject) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            self.email = emailTextField.text
            self.password = passwordTextField.text
            
            
            emailHasBeenRegistered(emailTextField.text!, result: { (result) in
                
                if result == true {
                    // log in user
                    self.loginUser(self.email!, password: self.password!)
                    UIApplication.sharedApplication().registerForRemoteNotifications()
                    
                } else {
                    ProgressHUD.showError("Account do not exist, Please register first")
                }
            })
        } else {
            ProgressHUD.showError("All fields are required")
        }
        
    }
    
    func loginUser(email:String, password: String)
    {
        backendless.userService.login(email, password: password, response: { (user : BackendlessUser!) -> Void in
            
            ProgressHUD.showSuccess("logged in")
            
            self.emailTextField.text = ""
            self.passwordTextField.text = ""
            
              registerUserDeviceId()
            
            //segue to recents view 
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ChatVC") as! UITabBarController
            self.presentViewController(vc, animated: true, completion: nil)
            vc.selectedIndex = 0
            ProgressHUD.dismiss()
            
        }) { (fault:Fault!) -> Void in
            
            ProgressHUD.showError("Invalid password entered, Please try again")
        }
    }
}
