//
//  GlanceController.swift
//  Jahia Watcher WatchKit Extension
//
//  Created by Serge Huber on 09.03.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import WatchKit
import Foundation


class GlanceController: WKInterfaceController {

    @IBOutlet weak var lastPostDate: WKInterfaceLabel!
    @IBOutlet weak var numberOfTasksLabel: WKInterfaceLabel!
    
    @IBOutlet weak var last24hoursUsers: WKInterfaceLabel!
    
    let jahiaServerServices : JahiaServerServices = JahiaServerServices.sharedInstance
    var latestPosts : NSArray = NSArray()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        println("Preparing glance data...")
        
        // Configure interface objects here.
        jahiaServerServices.login()
        
        let latestPosts : NSArray = jahiaServerServices.getLatestPosts()
        var lastPostTime : Int = 0
        var uniqueUsers = [String:String]()

        for latestPost in latestPosts {
            let postProperties : NSDictionary = latestPost["properties"] as! NSDictionary
            let titleProperty : NSDictionary = postProperties["jcr__title"] as! NSDictionary
            let postTitle : NSString = titleProperty["value"] as! NSString
            let contentProperty : NSDictionary? = postProperties["content"] as? NSDictionary
            let createdProperty  : NSDictionary? = postProperties["jcr__created"] as? NSDictionary
            let createdByProperty  : NSDictionary? = postProperties["jcr__createdBy"] as? NSDictionary
            if (contentProperty != nil) {
                let postContent : NSString = contentProperty!["value"] as! NSString
            }
            if (createdProperty != nil) {
                let createdValue : NSNumber = createdProperty!["value"] as! NSNumber
                if (createdValue.longValue > lastPostTime) {
                    lastPostTime = createdValue.longValue
                }
            }
            if (createdByProperty != nil) {
                let createdByValue : String = createdByProperty!["value"] as! String
                uniqueUsers[createdByValue] = createdByValue
            }
        }

        let dateValue : NSDate = NSDate(timeIntervalSince1970: NSTimeInterval(lastPostTime/1000));
        lastPostDate.setText("\(dateValue)")
        last24hoursUsers.setText("\(uniqueUsers.count)")
        
        let workflowTasks : NSDictionary = jahiaServerServices.getWorkflowTasks()
        var openTaskCount = 0;
        
        if (workflowTasks.count > 0) {
            let taskChildren : NSDictionary = workflowTasks["children"] as! NSDictionary
            println("\(taskChildren.count) tasks found.")
            for (taskName, task) in taskChildren {
                let taskProperties = task["properties"] as! NSDictionary
                let taskState = taskProperties["state"] as! NSDictionary
                let taskStateValue = taskState["value"] as! NSString
                if (taskStateValue != "finished") {
                    openTaskCount++;
                }
            }
        }
        
        numberOfTasksLabel.setText("\(openTaskCount)")
        println("Glance data completed.")
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
