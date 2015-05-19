//
//  TasksTableViewController.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 08.05.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import Foundation
import UIKit

class TasksTableViewController: UITableViewController {

    let jahiaServerServices : JahiaServerServices = JahiaServerServices.sharedInstance
    var workflowTasks : [Task] = [Task]()
    var needsRefreshing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl!.addTarget(self, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)
        dispatch_async(dispatch_get_main_queue()) {
            self.workflowTasks = self.jahiaServerServices.getWorkflowTasks()
            self.tableView.reloadData()
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
        
    func refreshData(sender:AnyObject) {
        // Code to refresh table view
        dispatch_async(dispatch_get_main_queue()) {
            self.workflowTasks = self.jahiaServerServices.getWorkflowTasks()
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if (needsRefreshing) {
            self.tableView.reloadData()
            needsRefreshing = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return workflowTasks.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("taskExtractCell", forIndexPath: indexPath) as! TaskExtractTableViewCell
        
        // Configure the cell...
        let currentIndex : Int = indexPath.row
        let task = workflowTasks[currentIndex]
        
        if let title = task.title {
            cell.titleLabel.text = title
        }
        
        if let dueDate = task.dueDate {
            cell.dueDateLabel.text = JahiaServerServices.getRelativeTime(dueDate)
        } else {
            cell.dueDateLabel.text = ""
        }
        
        if let assignee = task.assigneeUserKey {
            cell.assigneeLabel.text = assignee
        } else {
            cell.assigneeLabel.text = "not assigned"
        }
        
        
        if let state = task.state {
            cell.stateLabel.text = state
        }
        
        if let description = task.description {
            cell.extractLabel.text = description
        }
        
        return cell
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        let taskDetailViewController = segue.destinationViewController as! TaskDetailViewController
        let selectedIndexPath = self.tableView.indexPathForSelectedRow()
        if let indexPath = selectedIndexPath {
            let task = workflowTasks[indexPath.row]
            taskDetailViewController.task = task
            taskDetailViewController.tasksTableViewController = self
            taskDetailViewController.taskIndex = indexPath.row
        }
    }
    
    func displaySpecificTask(taskIdentifier : String) {
        dispatch_async(dispatch_get_main_queue()) {
            self.workflowTasks = self.jahiaServerServices.getWorkflowTasks()
            self.tableView.reloadData()
            if (self.workflowTasks.count == 0) {
                return;
            }
            var i=0
            for workflowTask in self.workflowTasks {
                if workflowTask.identifier! == taskIdentifier {
                    self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.Top)
                    break
                }
                i++
            }
            self.performSegueWithIdentifier("displayTask", sender: self)
        }
    }
    
}
