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
    
    @IBOutlet weak var statusLabel: WKInterfaceLabel!
    @IBOutlet weak var usersInLastPostsGroup: WKInterfaceGroup!
    @IBOutlet weak var lastPostAndOpenTasksGroup: WKInterfaceGroup!
    
    let jahiaServerServices : JahiaServerServices = JahiaServerServices.sharedInstance
    var latestPosts : NSArray = NSArray()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        JahiaServerServices.messageDelegate = DefaultMessageDelegate()

        println("Preparing glance data...")
        let startDate = NSDate()
        
        let jahiaServerSession = JahiaServerSession()
        
        // Configure interface objects here.        
        usersInLastPostsGroup.setHidden(true)
        lastPostAndOpenTasksGroup.setHidden(true)
        
        let servicesAvailable = jahiaServerSession.areServicesAvailable()

        if (!servicesAvailable) {
            println("Services are not available")
            statusLabel.setText("OFFLINE")
            statusLabel.setTextColor(UIColor.redColor())
        } else {
            statusLabel.setText("LOADING")
        }
        
        statusLabel.setText("LOADING POSTS")
        let latestPosts = jahiaServerSession.getLatestPosts()
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
        
        println("Displaying users in last posts...")
        usersInLastPostsGroup.setHidden(false)
        
        statusLabel.setText("LOADING TASKS")
        
        let workflowTasks = jahiaServerSession.getWorkflowTasks()
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
        
        println("Displaying last post date and open tasks...")
        lastPostAndOpenTasksGroup.setHidden(false)
        
        if (!servicesAvailable) {
            statusLabel.setText("OFFLINE")
            statusLabel.setTextColor(UIColor.redColor())
        }

        let endDate = NSDate()
        let timeInterval: Double = endDate.timeIntervalSinceDate(startDate)
        println("Glance data completed in \(timeInterval) seconds.")
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        println("willActivate called")
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        println("didDeactivate called")
        super.didDeactivate()
    }

}
