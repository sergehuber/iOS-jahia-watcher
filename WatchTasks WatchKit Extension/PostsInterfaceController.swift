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
    var latestPosts = [Post]()
    
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
            let latestPost = latestPosts[i]
            postsRowController.postTitle.setText(latestPost.title)
            postsRowController.postExtract.setText(latestPost.content)
            // postsRowController.postDate.setText("\(latestPost.date.relativeTime)")
            postsRowController.postAuthor.setText(latestPost.author)
        }
        
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table:WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        return latestPosts[rowIndex]
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        for i in 0...latestPosts.count-1 {
            let postsRowController = postsTable.rowControllerAtIndex(i) as! PostsRowController
            let latestPost = latestPosts[i]
            if (latestPost.spam!) {
                postsRowController.postSpamMarker.setHidden(false)
            } else {
                postsRowController.postSpamMarker.setHidden(true)
            }
        }
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}