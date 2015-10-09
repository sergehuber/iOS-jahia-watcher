//
//  TaskDetailInterfaceController.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 08.04.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import WatchKit
import Foundation


class TaskDetailInterfaceController: WKInterfaceController {

    @IBOutlet weak var nameLabel: WKInterfaceLabel!
    @IBOutlet weak var assigneeUserKeyLabel: WKInterfaceLabel!
    @IBOutlet weak var descriptionLabel: WKInterfaceLabel!
    
    @IBOutlet weak var stateLabel: WKInterfaceLabel!
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    let serverServices : ServerServices = ServerServices.sharedInstance
    let jahiaJahiaServerSettings : JahiaServerSettings = JahiaServerSettings.sharedInstance
    var taskDetailContext : TaskDetailContext?
    var task : Task?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        taskDetailContext = context as? TaskDetailContext
        task = taskDetailContext!.task
        nameLabel.setText(task!.name)
        if (task!.assigneeUserKey != nil && (task!.assigneeUserKey!).characters.count > 0) {
            assigneeUserKeyLabel.setText(task!.assigneeUserKey)
        } else {
            assigneeUserKeyLabel.setText("not assigned")
        }
        descriptionLabel.setText(task!.description)
        stateLabel.setText(task!.state)
        titleLabel.setText(task!.title)
        
        // Configure interface objects here.
        
        buildTaskActionsMenu()
    }
    
    func buildTaskActionsMenu() {
        clearAllMenuItems()
        let updatedTask = taskDetailContext!.jahiaServerSession!.getTaskActions(task!)
        if (updatedTask.nextActions != nil) {
            for nextAction in updatedTask.nextActions! {
                var actionSelector = Selector(nextAction.name! + "Pressed:")
                if nextAction.finalOutcome != nil {
                    actionSelector = Selector(nextAction.finalOutcome! + "Pressed:")
                }
                addMenuItemWithItemIcon(WKMenuItemIcon.Accept, title: nextAction.displayName!, action: actionSelector)
            }
        }
    }
        
    func assignToMePressed(sender : AnyObject?) {
        print("Assign to me pressed")
        taskDetailContext!.jahiaServerSession!.performTaskAction(task!, actionName: "assignToMe", finalOutcome: nil)
        buildTaskActionsMenu()
        stateLabel.setText("Active")
        assigneeUserKeyLabel.setText(jahiaJahiaServerSettings.jahiaUserName)
    }
    
    func refusePressed(sender: AnyObject?) {
        print("Refuse pressed")
        taskDetailContext!.jahiaServerSession!.performTaskAction(task!, actionName: "refuse", finalOutcome: nil)
        buildTaskActionsMenu()
        stateLabel.setText("Active")
        assigneeUserKeyLabel.setText("Not assigned")
    }

    func startPressed(sender : AnyObject?) {
        print("Start pressed")
        taskDetailContext!.jahiaServerSession!.performTaskAction(task!, actionName: "start", finalOutcome: nil)
        buildTaskActionsMenu()
        stateLabel.setText("Started")
    }

    func suspendPressed(sender : AnyObject?) {
        print("Suspend pressed")
        taskDetailContext!.jahiaServerSession!.performTaskAction(task!, actionName: "suspend", finalOutcome: nil)
        buildTaskActionsMenu()
        stateLabel.setText("Suspended")
    }

    func continuePressed(sender : AnyObject?) {
        print("Continue pressed")
        taskDetailContext!.jahiaServerSession!.performTaskAction(task!, actionName: "continue", finalOutcome: nil)
        buildTaskActionsMenu()
        stateLabel.setText("Started")
    }

    func acceptPressed(sender : AnyObject?) {
        print("Accept pressed")
        taskDetailContext!.jahiaServerSession!.performTaskAction(task!, actionName: "finished", finalOutcome: "accept")
        buildTaskActionsMenu()
        stateLabel.setText("Finished")
    }
    
    func rejectPressed(sender : AnyObject?) {
        print("Reject pressed")
        taskDetailContext!.jahiaServerSession!.performTaskAction(task!, actionName: "finished", finalOutcome: "reject")
        buildTaskActionsMenu()
        stateLabel.setText("Finished")
    }

    func completePressed(sender : AnyObject?) {
        print("Complete pressed")
        taskDetailContext!.jahiaServerSession!.performTaskAction(task!, actionName: "finished", finalOutcome: nil)
        buildTaskActionsMenu()
        stateLabel.setText("Finished")
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        let userInfo : [NSObject : AnyObject] = [ "aps" : [
            "alert" : "View task",
            "category" : "newTask"
            ],
            "nodeIdentifier" : "\(task!.identifier!)"]
        
        self.updateUserActivity("com.jahia.mobile.apps.Jahia-Watcher.watchkitapp.activities.viewTask", userInfo: userInfo, webpageURL: nil)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
