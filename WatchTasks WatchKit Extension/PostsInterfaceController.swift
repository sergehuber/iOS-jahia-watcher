//
//  PostsInterfaceController.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 08.04.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import Foundation
import WatchKit

class PostsInterfaceController: WKInterfaceController {
    
    @IBOutlet weak var postsTable: WKInterfaceTable!

    @IBOutlet weak var noPostFoundLabel: WKInterfaceLabel!
    let jahiaServerServices : JahiaServerServices = JahiaServerServices.sharedInstance
    var latestPosts : NSArray = NSArray()
    
    override func awakeWithContext(context: AnyObject?) {
        
        // Configure interface objects here.
        jahiaServerServices.login()
        
        latestPosts = jahiaServerServices.getLatestPosts()
        if (latestPosts.count == 0) {
            noPostFoundLabel.setHidden(false)
        } else {
            noPostFoundLabel.setHidden(true)
        }
        postsTable.setNumberOfRows(latestPosts.count, withRowType: "postRow")
        
        for i in 0...latestPosts.count-1 {
            let postsRowController = postsTable.rowControllerAtIndex(i) as! PostsRowController
            let latestPost = latestPosts[i] as! NSDictionary
            let postProperties : NSDictionary = latestPost["properties"] as! NSDictionary
            let titleProperty : NSDictionary = postProperties["jcr__title"] as! NSDictionary
            let postTitle : NSString = titleProperty["value"] as! NSString
            postsRowController.postTitle.setText(postTitle as String)
            let contentProperty : NSDictionary? = postProperties["content"] as? NSDictionary
            let createdProperty  : NSDictionary? = postProperties["jcr__created"] as? NSDictionary
            let createdByProperty  : NSDictionary? = postProperties["jcr__createdBy"] as? NSDictionary
            if (contentProperty != nil) {
                let postContent : NSString = contentProperty!["value"] as! NSString
                postsRowController.postExtract.setText(postContent as String)
            }
            if (createdProperty != nil) {
                let createdValue : NSNumber = createdProperty!["value"] as! NSNumber
                let postDateTimeInterval = NSTimeInterval(createdValue.longValue / 1000)
                let postDate = NSDate(timeIntervalSince1970: postDateTimeInterval)
                // postsRowController.postDate.setText("\(postDate)")
            }
            if (createdByProperty != nil) {
                let createdByValue : String = createdByProperty!["value"] as! String
                postsRowController.postAuthor.setText(createdByValue)
            }
            
            
        }
        
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table:WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        return latestPosts[rowIndex] as! NSDictionary
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}