//
//  PostDetailInterfaceController.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 08.04.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import WatchKit
import Foundation

class PostDetailInterfaceController: WKInterfaceController {

    let jahiaServerServices : JahiaServerServices = JahiaServerServices.sharedInstance
    
    @IBOutlet weak var postTitleLabel: WKInterfaceLabel!
    @IBOutlet weak var postDateLabel: WKInterfaceLabel!
    @IBOutlet weak var postAuthorLabel: WKInterfaceLabel!
    @IBOutlet weak var postBodyLabel: WKInterfaceLabel!
    
    var postTitle : String = ""
    var postIdentifier : String = ""
    var postAuthor : String = ""
    var postDate : NSDate = NSDate()
    var postContent : String = ""
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        let post = context as! NSDictionary
        postIdentifier = post["id"] as! String
        let postProperties : NSDictionary = post["properties"] as! NSDictionary
        let titleProperty : NSDictionary = postProperties["jcr__title"] as! NSDictionary
        postTitle = titleProperty["value"] as! String
        postTitleLabel.setText(postTitle as String)
        let contentProperty : NSDictionary? = postProperties["content"] as? NSDictionary
        let createdProperty  : NSDictionary? = postProperties["jcr__created"] as? NSDictionary
        let createdByProperty  : NSDictionary? = postProperties["jcr__createdBy"] as? NSDictionary
        if (contentProperty != nil) {
            var postContent : String = contentProperty!["value"] as! String
            postContent = jahiaServerServices.stripHTML(postContent)
            postBodyLabel.setText(postContent)
        }
        if (createdProperty != nil) {
            let createdValue : NSNumber = createdProperty!["value"] as! NSNumber
            let postDateTimeInterval = NSTimeInterval(createdValue.longValue / 1000)
            postDate = NSDate(timeIntervalSince1970: postDateTimeInterval)
            postDateLabel.setText("\(postDate)")
        }
        if (createdByProperty != nil) {
            postAuthor = createdByProperty!["value"] as! String
            postAuthorLabel.setText(postAuthor)
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func viewOnPhone() {
        println("Viewing post on phone...")
    }
    
    @IBAction func markAsSpam() {
        println("Marking post \(postIdentifier) as spam...")
        jahiaServerServices.markAsSpam(postIdentifier)
    }
    
    @IBAction func deletePost() {
        println("Deleting post...")
    }
    
    @IBAction func blockUser() {
        println("Blocking user \(postAuthor)...")
        jahiaServerServices.blockUser(postAuthor)
    }
}
