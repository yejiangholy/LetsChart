//
//  RecentTableViewCell.swift
//  LetsChart
//
//  Created by JiangYe on 6/11/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import UIKit

class RecentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var lastMessageLable: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func bindData(recent:NSDictionary){
        
          if (recent.objectForKey("withUserUserId") as? [String]) != nil
          {
            avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width/2
            avatarImageView.layer.masksToBounds = true
            
            self.avatarImageView.image = UIImage(named: "avatarPlaceholder")
            
            let withUsersId = recent.objectForKey("withUserUserId") as! [String]
            
            //1. put all withUser's image into images array && name into names
            
            let imageLink = recent.objectForKey("image") as! String
            
            if imageLink == "" {
                
            getImagesFromId(withUsersId, images: { (images) in
                
                if images.count != 0 {
                    
                    let combinedImage = imageFromImages(images)
                    
                    uploadAvatar(combinedImage, result: { (imageLink) in
                        
                        recent.setValue(imageLink, forKey: "image")
                    })
                    
                    self.avatarImageView.image = combinedImage
                    
                } else {
                    
                    uploadAvatar(UIImage(named: "avatarPlaceholder")!, result: { (imageLink) in
                        
                        recent.setValue(imageLink, forKey: "image")
                    })
                }
            })
            }else {
                
                getImageFromURL(imageLink, result: { (image) in
                    
                    self.avatarImageView.image = image
                })
                
            }
         
            nameLable.text = recent.objectForKey("name") as? String
            
            lastMessageLable.text = recent["lastMessage"] as? String
            counterLabel.text = ""
            
            if(recent["counter"] as? Int)! != 0 {
                counterLabel.text = "\(recent["counter"]!) New"
            }
            
            let date = dataFormatter().dateFromString((recent["date"] as? String)!)
            let seconds = NSDate().timeIntervalSinceDate(date!)
            dateLabel.text = TimeElipsed(seconds)

        }
            
        else {
       avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width/2
        avatarImageView.layer.masksToBounds = true
        
        self.avatarImageView.image = UIImage(named: "avatarPlaceholder")
        
        let withUserId = (recent.objectForKey("withUserUserId") as? String)
        
        //get the backendless user and download profile image 
        
        let whereClause = "objectId = '\(withUserId!)'"
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = whereClause
        
        let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())
        
        dataStore.find(dataQuery, response: { (users : BackendlessCollection!) ->Void in
            
            let withUser = users.data[0] as! BackendlessUser
            
            if let avatarURL = withUser.getProperty("Avatar") {
                getImageFromURL(avatarURL as! String, result: { (image) in
                    
                    self.avatarImageView.image = image
                })
            }
            
            
        }) {(fault:Fault!)-> Void in
            print("error, cound't get user image: \(fault)")
        }
        nameLable.text = recent["withUserUserName"]as? String
        lastMessageLable.text = recent["lastMessage"] as? String
        counterLabel.text = ""
        
        if(recent["counter"] as? Int)! != 0 {
            counterLabel.text = "\(recent["counter"]!) New"
        }
        
        let date = dataFormatter().dateFromString((recent["date"] as? String)!)
        let seconds = NSDate().timeIntervalSinceDate(date!)
        dateLabel.text = TimeElipsed(seconds)
        }
        
    }
    
    func getMixedImg(image1: UIImage, image2: UIImage) -> UIImage {
        
        let size = CGSizeMake(image1.size.width, image1.size.height + image2.size.height)
        
        UIGraphicsBeginImageContext(size)
        
        image1.drawInRect(CGRectMake(0,0,size.width, image1.size.height))
        image2.drawInRect(CGRectMake(0,image1.size.height,size.width, image2.size.height))
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage
    }
 
    
    func nameFromNames(names: [String]) -> String
    {
        
        var name : String = names[0]
        
        for i in 1..<names.count{
            name = name.stringByAppendingString(" , ")
            name = name.stringByAppendingString(names[i])
        }
        
        return name
    }
    
}
