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
    var needsRefreshing : Bool = true
    
    override func awakeWithContext(context: AnyObject?) {
        
        // Configure interface objects here.
        jahiaServerServices.login()
        
        latestPosts = jahiaServerServices.getLatestPosts()
        if (needsRefreshing) {
            refreshTable()
            needsRefreshing = false
        }        
    }
    
    func refreshTable() {
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
            if (latestPost.spam!) {
                postsRowController.postSpamMarker.setHidden(false)
            } else {
                postsRowController.postSpamMarker.setHidden(true)
            }
        }
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table:WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        let postDetailContext = PostDetailContext()
        postDetailContext.post = latestPosts[rowIndex]
        postDetailContext.postsInterfaceController = self
        postDetailContext.postIndex = rowIndex
        return postDetailContext
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        if (needsRefreshing) {
            refreshTable()
            needsRefreshing = false
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}