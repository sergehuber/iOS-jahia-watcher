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
    var task : Task?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        task = context as? Task
            nameLabel.setText(task!.name)
            assigneeUserKeyLabel.setText(task!.assigneeUserKey)
            descriptionLabel.setText(task!.description)
        stateLabel.setText(task!.state)
        titleLabel.setText(task!.title)
            
            let updatedTask = jahiaServerServices.getTaskActions(task!)
            if (updatedTask.nextActions != nil) {
                for nextAction in updatedTask.nextActions! {
                    let actionSelector = Selector(nextAction.name! + "Pressed:")
                    addMenuItemWithItemIcon(WKMenuItemIcon.Accept, title: nextAction.displayName!, action: actionSelector)
                }
            }
        // Configure interface objects here.
    }
    
    @IBAction func previewChangesPressed() {
        println("Preview button pressed")
        WKInterfaceController.openParentApplication(["viewTasks" : "root"], reply: { (reply, error) -> Void in
        })
    }
    
    func assignToMePressed(sender : AnyObject?) {
        println("Assign to me pressed")
        jahiaServerServices.performTaskAction(task!, actionName: "assignToMe", finalOutcome: nil)
    }
    
    func refusePressed(sender: AnyObject?) {
        println("Refuse pressed")
        jahiaServerServices.performTaskAction(task!, actionName: "refuse", finalOutcome: nil)
    }

    func startPressed(sender : AnyObject?) {
        println("Start pressed")
        jahiaServerServices.performTaskAction(task!, actionName: "start", finalOutcome: nil)
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
