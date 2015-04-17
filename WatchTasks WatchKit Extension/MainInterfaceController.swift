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
    
    override func awakeWithContext(context: AnyObject?) {
        println("Starting Jahia Watcher Watch Application...")
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
            println("handleActionWithIdentifier(\(identifier))")

            let jahiaServerServices : JahiaServerServices = JahiaServerServices.sharedInstance
            jahiaServerServices.login()
            
            let userName = ""
            let nodeIdentifier = remoteNotification["nodeIdentifier"] as! String
            
            switch identifier! {
            case "viewPostAction" :
                println("View post action")
                let latestPosts = jahiaServerServices.getLatestPosts()
                var post : NSDictionary?;
                for currentPost in latestPosts {
                    if (currentPost["id"] as! String == nodeIdentifier) {
                        post = currentPost as? NSDictionary
                    }
                }
                if (post != nil) {
                    pushControllerWithName("postDetailController", context: post)
                }
            case "blockUserAction" :
                println("Block user action")
                jahiaServerServices.blockUser(userName)
            case "markPostAsSpamAction" :
                println("Mark as spam action")
                jahiaServerServices.markAsSpam(nodeIdentifier)
            default:
                println("Unrecognized action")
            }
    }
}