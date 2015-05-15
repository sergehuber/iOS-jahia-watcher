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
        
        let latestPosts = jahiaServerServices.getLatestPosts()
        var lastestPostDate : NSDate = NSDate(timeIntervalSince1970: NSTimeInterval(0))
        var uniqueUsers = [String:String]()

        for latestPost in latestPosts {
            if (latestPost.author != nil) {
                uniqueUsers[latestPost.author!] = latestPost.author
            }
            if (lastestPostDate.compare(latestPost.date!) == NSComparisonResult.OrderedAscending) {
                lastestPostDate = latestPost.date!
            }
        }

        lastPostDate.setText("\(lastestPostDate.relativeTime)")
        last24hoursUsers.setText("\(uniqueUsers.count)")
        
        let workflowTasks = jahiaServerServices.getWorkflowTasks()
        var openTaskCount = 0;
        
        if (workflowTasks.count > 0) {
            println("\(workflowTasks.count) tasks found.")
            for task in workflowTasks {
                if (task.state != "finished") {
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
