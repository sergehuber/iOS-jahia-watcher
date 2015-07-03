//
//  TaskDetailViewController.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 08.05.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import Foundation
import UIKit

class TaskDetailViewController: UIViewController {
    
    let jahiaServerSettings : JahiaServerSettings = JahiaServerSettings.sharedInstance
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var assigneeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var outcomeToolbar: UIToolbar!
    @IBOutlet weak var previewButton: UIButton!
    var taskDetailContext : TaskDetailContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dispatch_async(dispatch_get_main_queue()) {
            self.displayTask()
        }
    }
    
    func displayTask() {
        // Do any additional setup after loading the view.
        if let realTask = taskDetailContext!.task {
            taskDetailContext!.task = taskDetailContext!.jahiaServerSession!.getTaskActions(realTask)
            if let title = realTask.title {
                titleLabel.text = title
            }
            if let assignee = realTask.assigneeUserKey {
                assigneeLabel.text = assignee
            } else {
                assigneeLabel.text = "not assigned"
            }
            if let state = realTask.state {
                statusLabel.text = state
            }
            if let description = realTask.description {
                descriptionLabel.text = description
            }
            if let dueDate = realTask.dueDate {
                dueDateLabel.text = JahiaServerServices.getShortDate(dueDate)
            } else {
                dueDateLabel.text = ""
            }
            outcomeToolbar.items?.removeAll(keepCapacity: false)
            if let nextActions = realTask.nextActions {
                var insertedItems = 0;
                for nextAction in nextActions {
                    if let outcome = nextAction.finalOutcome {
                        let outcomeBarButtonItem = IdUIBarButtonItem(title: nextAction.displayName, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("actionTriggered:"))
                        outcomeBarButtonItem.tag = outcome.hash
                        outcomeBarButtonItem.identifier = nextAction.name
                        outcomeBarButtonItem.subIdentifier = outcome
                        outcomeToolbar.items!.append(outcomeBarButtonItem)
                    } else {
                        let nextActionBarButtonItem = IdUIBarButtonItem(title: nextAction.displayName, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("actionTriggered:"))
                        nextActionBarButtonItem.tag = nextAction.name!.hash
                        nextActionBarButtonItem.identifier = nextAction.name
                        outcomeToolbar.items!.append(nextActionBarButtonItem)
                    }
                    insertedItems++;
                    if (insertedItems < nextActions.count) {
                        outcomeToolbar.items!.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil))
                    }
                }
            }
            if (realTask.previewUrl != nil) {
                previewButton.hidden = false
            } else {
                previewButton.hidden = true
            }
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func actionTriggered(sender : UIBarButtonItem!) {
        if let idSender = sender as? IdUIBarButtonItem {
            self.navigationItem.prompt="Performing action..."
            println("Action triggered for \(idSender.title) with tag \(idSender.tag) identifier=\(idSender.identifier) subIdentifier=\(idSender.subIdentifier)")
            taskDetailContext!.jahiaServerSession!.performTaskAction(taskDetailContext!.task!, actionName: idSender.identifier!, finalOutcome: idSender.subIdentifier)
        } else {
            println("Action triggered for \(sender.title) with tag \(sender.tag)")
        }
        dispatch_async(dispatch_get_main_queue()) {
            self.taskDetailContext!.task = self.taskDetailContext!.jahiaServerSession!.refreshTask(self.taskDetailContext!.task!)
            self.displayTask()
            self.navigationItem.prompt=nil
        }
    }
    
    /*
    // MARK: - Navigation
    */
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        let taskContentPreviewController = segue.destinationViewController as! TaskContentPreviewViewController
        taskContentPreviewController.contentUrl = jahiaServerSettings.contentRenderUrl(taskDetailContext!.task!.previewUrl!)
    }
    
    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController()){
            // we update the list entry
            let tasksTableViewController = taskDetailContext?.tasksController as! TasksTableViewController
            tasksTableViewController.workflowTasks[taskDetailContext!.taskIndex!] = taskDetailContext!.task!
            tasksTableViewController.needsRefreshing = true
        }
    }
    
    
}
