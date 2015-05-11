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
    var workflowTasks : NSDictionary = NSDictionary()
    var workflowTasksChildren : NSDictionary = NSDictionary()
    var taskArray : [AnyObject] = Array()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        workflowTasks = jahiaServerServices.getWorkflowTasks()
        if (workflowTasks.count == 0) {
            return
        }
        workflowTasksChildren = workflowTasks["children"] as! NSDictionary
        
        let workflowTaskChildrenDict = workflowTasksChildren as Dictionary
        taskArray = Array(workflowTaskChildrenDict.keys)
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
        return workflowTasksChildren.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("taskExtractCell", forIndexPath: indexPath) as! TaskExtractTableViewCell
        
        // Configure the cell...
        let currentIndex : Int = indexPath.row
        let taskName = taskArray[currentIndex] as! String
        let workflowTask : NSDictionary = workflowTasksChildren[taskName] as! NSDictionary
        let task : Task = Task(taskName: taskName, fromNSDictionary: workflowTask)
        
        if let title = task.title {
            cell.titleLabel.text = title
        }
        
        if let dueDate = task.dueDate {
            cell.dueDateLabel.text = JahiaServerServices.getRelativeTime(dueDate)
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
            let taskName = taskArray[indexPath.row] as! String
            let workflowTask : NSDictionary = workflowTasksChildren[taskName] as! NSDictionary
            let task = Task(taskName: taskName, fromNSDictionary: workflowTask)
            taskDetailViewController.task = task
        }
    }

}
