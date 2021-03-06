//
//  WelcomeViewController.swift
//  LetsChart
//
//  Created by JiangYe on 6/11/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class WelcomeViewController: UIViewController {
    
    
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    
    override func viewWillAppear(animated: Bool) {
        
        backendless.userService.setStayLoggedIn(true)
        
        if backendless.userService.currentUser != nil {
            
            dispatch_async(dispatch_get_main_queue()){ // make sure UI changing will happend in the main queue 
                
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ChatVC") as! UITabBarController
            self.presentViewController(vc, animated: true, completion: nil)
            vc.selectedIndex = 0
                
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true

        fbLoginButton.readPermissions = ["public_profile" , "email"]
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
