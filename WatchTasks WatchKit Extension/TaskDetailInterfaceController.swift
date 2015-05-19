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
    let jahiaServerServices : JahiaServerServices = JahiaServerServices.sharedInstance
    let jahiaWatcherSettings : JahiaWatcherSettings = JahiaWatcherSettings.sharedInstance
    var task : Task?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        task = context as? Task
        nameLabel.setText(task!.name)
        if (task!.assigneeUserKey != nil && count(task!.assigneeUserKey!) > 0) {
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
        let updatedTask = jahiaServerServices.getTaskActions(task!)
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
    
    @IBAction func previewChangesPressed() {
        println("Preview button pressed")
        var userInfo : [NSObject : AnyObject] = ["action": "previewTaskChanges",
            "previewUrl": jahiaWatcherSettings.contentRenderUrl(task!.previewUrl!)]
        WKInterfaceController.openParentApplication(userInfo, reply: { (reply, error) -> Void in
            println("parent application replied reply=\(reply) error=\(error)")
        })
    }
    
    func assignToMePressed(sender : AnyObject?) {
        println("Assign to me pressed")
        jahiaServerServices.performTaskAction(task!, actionName: "assignToMe", finalOutcome: nil)
        buildTaskActionsMenu()
        stateLabel.setText("Active")
        assigneeUserKeyLabel.setText(jahiaServerServices.getUserName())
    }
    
    func refusePressed(sender: AnyObject?) {
        println("Refuse pressed")
        jahiaServerServices.performTaskAction(task!, actionName: "refuse", finalOutcome: nil)
        buildTaskActionsMenu()
        stateLabel.setText("Active")
        assigneeUserKeyLabel.setText("Not assigned")
    }

    func startPressed(sender : AnyObject?) {
        println("Start pressed")
        jahiaServerServices.performTaskAction(task!, actionName: "start", finalOutcome: nil)
        buildTaskActionsMenu()
        stateLabel.setText("Started")
    }

    func suspendPressed(sender : AnyObject?) {
        println("Suspend pressed")
        jahiaServerServices.performTaskAction(task!, actionName: "suspend", finalOutcome: nil)
        buildTaskActionsMenu()
        stateLabel.setText("Suspended")
    }

    func continuePressed(sender : AnyObject?) {
        println("Continue pressed")
        jahiaServerServices.performTaskAction(task!, actionName: "continue", finalOutcome: nil)
        buildTaskActionsMenu()
        stateLabel.setText("Started")
    }

    func acceptPressed(sender : AnyObject?) {
        println("Accept pressed")
        jahiaServerServices.performTaskAction(task!, actionName: "finished", finalOutcome: "accept")
        buildTaskActionsMenu()
        stateLabel.setText("Finished")
    }
    
    func rejectPressed(sender : AnyObject?) {
        println("Reject pressed")
        jahiaServerServices.performTaskAction(task!, actionName: "finished", finalOutcome: "reject")
        buildTaskActionsMenu()
        stateLabel.setText("Finished")
    }

    func completePressed(sender : AnyObject?) {
        println("Complete pressed")
        jahiaServerServices.performTaskAction(task!, actionName: "finished", finalOutcome: nil)
        buildTaskActionsMenu()
        stateLabel.setText("Finished")
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
