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
    
    @IBOutlet weak var tasksTable: WKInterfaceTable!
    
    var workflowTasks : [Task]?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        
        jahiaServerServices.login()

        workflowTasks = jahiaServerServices.getWorkflowTasks()

        var openTaskCount = 0;
        
        if (workflowTasks!.count > 0) {
            println("\(workflowTasks!.count) tasks found.")
            for task in workflowTasks! {
                if (task.state! != "finished") {
                    openTaskCount++;
                }
            }
        }

        if (openTaskCount == 0) {
            tasksLabel.setText("No tasks waiting");
        } else if (openTaskCount == 1) {
            tasksLabel.setText("One task waiting.");
        } else if (openTaskCount > 1) {
            tasksLabel.setText("You have \(openTaskCount) tasks waiting.");
        }
        
        if (workflowTasks!.count > 0) {
            tasksTable.setNumberOfRows(workflowTasks!.count, withRowType: "taskRow")
            for i in 0...workflowTasks!.count-1 {
                let tasksRowController = tasksTable.rowControllerAtIndex(i) as! TasksRowController
                let task = workflowTasks![i]
                tasksRowController.taskNameLabel.setText(task.name)
                tasksRowController.taskAssigneeUserKeyLabel.setText(task.assigneeUserKey)
                tasksRowController.taskDescriptionLabel.setText(task.description)
                tasksRowController.taskStateLabel.setText(task.state)
            }
        }
        
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table:WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        return workflowTasks![rowIndex]
    }
    
    @IBAction func viewTasks() {
        
        WKInterfaceController.openParentApplication(["viewTasks" : "root"], reply: { (reply, error) -> Void in
        })
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.invalidateUserActivity()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
