//
//  GroupEditingTableViewController.swift
//  LetsChart
//
//  Created by JiangYe on 7/1/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import UIKit

class GroupEditingTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var changeNameCell: UITableViewCell!
    @IBOutlet weak var changePictureCell: UITableViewCell!
    @IBOutlet weak var addFriendsCell: UITableViewCell!
    @IBOutlet weak var leaveGroupCell: UITableViewCell!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var groupImage: UIImageView!
    @IBOutlet weak var groupNameLable: UILabel!
    
    var groupChatViewController: GroupChatViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableHeaderView = headerView
        
        groupImage.layer.cornerRadius = groupImage.frame.size.width / 2
        groupImage.layer.masksToBounds = true
        
         updateUI()
    }
    
    func updateUI() {
        
    groupNameLable.text = groupChatViewController.groupName
    
    groupImage.image = groupChatViewController.groupImage
        
    }
    
    @IBAction func didClickGroupImage(sender: UIButton) {
        
        changePhoto()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            return changeNameCell
        }
        if (indexPath.section == 0) && (indexPath.row == 1) {
            return changePictureCell
        }
        if (indexPath.section == 0) && (indexPath.row == 2) {
            return addFriendsCell
        }
        if (indexPath.section == 1) && (indexPath.row == 0) {
            return leaveGroupCell
        } else
        {
            return UITableViewCell()
        }

    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 10
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
            
            //leaveGroupCellPressed()
            
        }
        
        if indexPath.section == 0 && indexPath.row == 0 {
            
            //changeGroupNamePressed()
        }
        
        if indexPath.section == 0 && indexPath.row == 1 {
            
            changePhoto()
            
        }
        if indexPath.section == 0 && indexPath.row == 2 {
            
            //addFriendsCellPressed()
        }
        
    }
    
    
    
    //MARK: UIImagePickerControllerDelegate functions
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        
        groupChatViewController.groupImage = image
        
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

    
    
    // MARK : change photo
    
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
    
    
    
    
    
    
    
    

}