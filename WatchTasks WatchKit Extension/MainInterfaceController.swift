//
//  MainInterfaceController.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 08.04.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import Foundation
import WatchKit

class MainInterfaceController: WKInterfaceController {
    
    let jahiaServerServices : JahiaServerServices = JahiaServerServices.sharedInstance
    
    override func awakeWithContext(context: AnyObject?) {
        println("Starting Jahia Watcher Watch Application...")
        JahiaServerServices.messageDelegate = DefaultMessageDelegate()
    }
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    override func handleActionWithIdentifier(identifier: String?,
        forRemoteNotification remoteNotification: [NSObject : AnyObject]) {
            println("enter - handleActionWithIdentifier(\(identifier))")

            JahiaServerServices.messageDelegate = DefaultMessageDelegate()
            
            let jahiaServerSession = JahiaServerSession()
            jahiaServerSession.areServicesAvailable()
            
            let userName = ""
            let nodeIdentifier = remoteNotification["nodeIdentifier"] as! String
            
            switch identifier! {
            case "viewPostAction" :
                println("View post action")
                let latestPosts = jahiaServerSession.getLatestPosts()
                var post : Post?
                var postIndex = 0
                if latestPosts.count == 0 {
                    return
                }
                if (nodeIdentifier == "123456789") {
                    // this is a special case if using simulated notifications
                    post = latestPosts[0]
                    postIndex = 0
                } else {
                    var index = 0
                    for currentPost in latestPosts {
                        if (currentPost.identifier == nodeIdentifier) {
                            post = currentPost
                            postIndex = index
                            break
                        }
                        index++;
                    }
                }
                if (post != nil) {
                    let postDetailContext = PostDetailContext()
                    postDetailContext.post = post
                    postDetailContext.postIndex = postIndex
                    pushControllerWithName("postsController", context: postDetailContext)
                }
            case "viewTaskAction" :
                let workflowTasks = jahiaServerSession.getWorkflowTasks()
                var task : Task?
                if (workflowTasks.count == 0) {
                    return
                }
                if (nodeIdentifier == "123456789") {
                    // this is a special case if using simulated notifications
                    task = workflowTasks[0]
                } else {
                    for currentTask in workflowTasks {
                        if (currentTask.identifier == nodeIdentifier) {
                            task = currentTask
                            break
                        }
                    }
                }
                if (task != nil) {
                    pushControllerWithName("taskDetailController", context: task)
                }
            default:
                println("Unrecognized action")
            }
            println("finish - handleActionWithIdentifier(\(identifier))")
            
    }
}