//
//  SettingsTableViewController.swift
//  LetsChart
//
//  Created by JiangYe on 6/18/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class SettingsTableViewController: UITableViewController ,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    
    
    @IBOutlet weak var HeaderView: UIView!
    @IBOutlet weak var ImageUser: UIImageView!
    @IBOutlet weak var UserNameLable: UILabel!
    
    @IBOutlet weak var avatarSwitch: UISwitch!
    @IBOutlet weak var avatarCell: UITableViewCell!
    @IBOutlet weak var termsCell: UITableViewCell!
    @IBOutlet weak var privacyCell: UITableViewCell!
    @IBOutlet weak var logoutCell: UITableViewCell!
    
    var avatarSwitchStatus = true
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    var firstLoad :Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableHeaderView = HeaderView
        
        ImageUser.layer.cornerRadius = ImageUser.frame.size.width / 2
        ImageUser.layer.masksToBounds = true
        
        loadUserDefaults()
        updateUI()
        
        //self.hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: IBActions
    
    
    @IBAction func avatarSwitchValueChanged(switchState: UISwitch) {
        
        if switchState.on {
            avatarSwitchStatus = true
        } else {
            avatarSwitchStatus = false
            
            }
        
       saveUserDefaults()
    }
    
    @IBAction func didClickAvatarImage(sender: AnyObject) {
        
        changePhoto()
        
    }
    
    
    
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
                return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 3
        } else if section == 1 {
            return 1
        } else {
            return 0
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // if first section first cell
        if (indexPath.section == 0) && (indexPath.row == 0) {
            return privacyCell
        }
        if (indexPath.section == 0) && (indexPath.row == 1) {
            return termsCell
        }
        if (indexPath.section == 0) && (indexPath.row == 2) {
            return avatarCell
        }
        if (indexPath.section == 1) && (indexPath.row == 0) {
            return logoutCell
        } else
        {
            return UITableViewCell()
        }
    }
    

    
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 0
        } else {
            return 25
        }
      
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clearColor()
        
        return headerView
        
    }
    
    //MARK: Tableview Delegate functions 
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            
            showLogoutView()
            
        }
        
        if indexPath.section == 0 && indexPath.row == 0 {
            
            showAboutView()
        }
        
        if indexPath.section == 0 && indexPath.row == 1 {
            
           
            self.performSegueWithIdentifier("SettingToTermsOfService", sender: self)
            
        }
    }
    
    //MARK: Change photo 
    
    func changePhoto() {
        
        let camera = Camera(delegate_: self)
    
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .Default) { (alert: UIAlertAction!) -> Void in
            
            camera.PresentPhoteCamera(self, canEdit: true)
        }
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .Default) { (alert :UIAlertAction!) -> Void in
            
            camera.PresentPhotoLibrary(self, canEdit: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert: UIAlertAction!) ->Void in
            
            print("Cancel")
        }
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    
    //MARK: UIImagePickerControllerDelegate functions 
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        
        ImageUser.image = image
        
        uploadAvatar(image!) { (imageLink) in
            let properties = ["Avatar" : imageLink!]
            
            backendless.userService.currentUser!.updateProperties(properties)
            
            backendless.userService.update(backendless.userService.currentUser, response: { (updateUser: BackendlessUser!) in
                print("Updated current user image") 
                
                }, error: { (fault: Fault!) in
                    print("error: \(fault)")
            })
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //MARK: UpdateUI 
    
    func updateUI(){
        UserNameLable.text = backendless.userService.currentUser.name
        
        avatarSwitch.setOn(avatarSwitchStatus, animated: true)
        
        if let imageLink = backendless.userService.currentUser.getProperty("Avatar") as? String {
            getImageFromURL(imageLink , result: { (image) in
                
                self.ImageUser.image = image
                
            })
        }
    }
    
    //MARK: Display views 
    
    func showAboutView(){
        
        self.performSegueWithIdentifier("SettingToAboutView", sender: self)

         }

    
    func showLogoutView() {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let logoutAction = UIAlertAction(title: "Log out", style: .Destructive) { (alert: UIAlertAction) in
            
            self.logOutUser()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert: UIAlertAction) in
            
            
    }
        optionMenu.addAction(logoutAction)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated:true , completion: nil)
    }
    
   func  showAboutUsView()
    {
        let aboutUsView = storyboard!.instantiateViewControllerWithIdentifier("aboutUsView")
        
        self.presentViewController(aboutUsView, animated: true, completion: nil)
        
    }
    
    func logOutUser()
    {
        
        removeDeviceIdFromUser()
        
        backendless.userService.logout()
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            //log out facebook User
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
        }
        
        // unregister user's device from push notification
        PushUserResign()
        
        //show login view 
        
        let loginView = storyboard!.instantiateViewControllerWithIdentifier("LoginView")
        
        self.presentViewController(loginView, animated: true, completion: nil)
        
        
        
        
    }
    //MARK: UserDefalts 
    
    func saveUserDefaults() {
        
        userDefaults.setBool(avatarSwitchStatus, forKey: KAVATARSTATE)
        userDefaults.synchronize()
    }
    
    func loadUserDefaults() {
        
        firstLoad = userDefaults.boolForKey(KFIRSTRUN)
        
        if !(firstLoad!) {
            userDefaults.setBool(true, forKey: KFIRSTRUN)
            userDefaults.setBool(avatarSwitchStatus, forKey: KAVATARSTATE)
            userDefaults.synchronize()
        }
        avatarSwitchStatus = userDefaults.boolForKey(KAVATARSTATE)
    }
}
