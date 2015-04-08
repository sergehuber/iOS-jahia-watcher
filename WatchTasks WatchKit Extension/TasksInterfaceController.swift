//
//  InterfaceController.swift
//  Jahia Watcher WatchKit Extension
//
//  Created by Serge Huber on 09.03.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import WatchKit
import Foundation

class TasksInterfaceController: WKInterfaceController {
    
    let jahiaWatcherSettings : JahiaWatcherSettings = JahiaWatcherSettings.sharedInstance
    let jahiaServerServices : JahiaServerServices = JahiaServerServices.sharedInstance
    
    @IBOutlet weak var tasksLabel: WKInterfaceLabel!
    
    @IBOutlet weak var viewTasksButton: WKInterfaceButton!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        
        jahiaServerServices.login()

        let workflowTasks : NSDictionary = jahiaServerServices.getWorkflowTasks()

        var openTaskCount = 0;
        
        if (workflowTasks.count > 0) {
            let taskChildren : NSDictionary = workflowTasks["children"] as NSDictionary
            println("\(taskChildren.count) tasks found.")
            for (taskName, task) in taskChildren {
                let taskProperties = task["properties"] as NSDictionary
                let taskState = taskProperties["state"] as NSDictionary
                let taskStateValue = taskState["value"] as NSString
                if (taskStateValue != "finished") {
                    openTaskCount++;
                }
            }
        }

        if (openTaskCount == 0) {
            tasksLabel.setText("No tasks waiting");
            viewTasksButton.setHidden(true)
        } else if (openTaskCount == 1) {
            tasksLabel.setText("One task waiting.");
            viewTasksButton.setHidden(false)
        } else if (openTaskCount > 1) {
            tasksLabel.setText("You have \(openTaskCount) tasks waiting.");
            viewTasksButton.setHidden(false)
        }
        
    }
    
    @IBAction func viewTasks() {
        
        WKInterfaceController.openParentApplication(["viewTasks" : "root"], reply: { (reply, error) -> Void in
        })
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
