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
    let serverServices : ServerServices = ServerServices.sharedInstance
    var latestPosts = [Post]()
    var needsRefreshing : Bool = true
    var jahiaServerSession : JahiaServerSession?
    
    override func awakeWithContext(context: AnyObject?) {
        
        // Configure interface objects here.
        jahiaServerSession = JahiaServerSession()
        
        jahiaServerSession!.areServicesAvailable()
        
        latestPosts = jahiaServerSession!.getLatestPosts()
        if (needsRefreshing) {
            refreshTable()
            needsRefreshing = false
        }
        
        let postDetailContext = context as? PostDetailContext
        if (postDetailContext != nil) {
            postDetailContext?.postsController = self
            postDetailContext?.jahiaServerSession = jahiaServerSession
            pushControllerWithName("postDetailController", context: postDetailContext)
        }
    }
    
    func refreshTable() {
        if (latestPosts.count == 0) {
            noPostFoundLabel.setHidden(false)
        } else {
            noPostFoundLabel.setHidden(true)
        }
        postsTable.setNumberOfRows(latestPosts.count, withRowType: "postRow")
        
        if (latestPosts.count > 0) {
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
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table:WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        let postDetailContext = PostDetailContext()
        postDetailContext.post = latestPosts[rowIndex]
        postDetailContext.postsController = self
        postDetailContext.postIndex = rowIndex
        postDetailContext.jahiaServerSession = jahiaServerSession
        return postDetailContext
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        if (needsRefreshing) {
            refreshTable()
            needsRefreshing = false
        }
        self.invalidateUserActivity()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}