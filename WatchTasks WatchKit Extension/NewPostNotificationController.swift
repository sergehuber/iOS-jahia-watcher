//
//  NotificationController.swift
//  Jahia Watcher WatchKit Extension
//
//  Created by Serge Huber on 09.03.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import WatchKit
import Foundation


class NewPostNotificationController: WKUserNotificationInterfaceController {

    @IBOutlet weak var postTitleLabel: WKInterfaceLabel!
    
    @IBOutlet weak var postDateLabel: WKInterfaceLabel!
    @IBOutlet weak var postAuthorLabel: WKInterfaceLabel!
    @IBOutlet weak var postContentLabel: WKInterfaceLabel!
    override init() {
        // Initialize variables here.
        super.init()
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    override func didReceiveLocalNotification(localNotification: UILocalNotification, withCompletion completionHandler: ((WKUserNotificationInterfaceType) -> Void)) {
        // This method is called when a local notification needs to be presented.
        // Implement it if you use a dynamic notification interface.
        // Populate your dynamic notification interface as quickly as possible.
        //
        // After populating your dynamic notification interface call the completion block.
        completionHandler(.Custom)
    }
    
    override func didReceiveRemoteNotification(remoteNotification: [NSObject : AnyObject], withCompletion completionHandler: ((WKUserNotificationInterfaceType) -> Void)) {
        // This method is called when a remote notification needs to be presented.
        // Implement it if you use a dynamic notification interface.
        // Populate your dynamic notification interface as quickly as possible.
        //
        // After populating your dynamic notification interface call the completion block.
        let notificationObject = remoteNotification as! [String:AnyObject]
        let nodeIdentifier = notificationObject["nodeIdentifier"] as! String
        let customKey = notificationObject["customKey"] as! [String:AnyObject]
        let postTitle = customKey["postTitle"] as! String
        postTitleLabel.setText(postTitle)
        let postDate = customKey["postDate"] as! NSNumber
        let postAuthor = customKey["postAuthor"] as! String
        postAuthorLabel.setText(postAuthor)
        let postContent = customKey["postContent"] as! String
        completionHandler(.Custom)
    }
}
