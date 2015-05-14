//
//  PostsTableViewController.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 08.04.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import UIKit

class PostsTableViewController: UITableViewController {

    let jahiaServerServices : JahiaServerServices = JahiaServerServices.sharedInstance
    var latestPosts : NSArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl!.addTarget(self, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)
        // self.tableView.addSubview(refreshControl)
    }
    
        
    func refreshData(sender:AnyObject) {
        // Code to refresh table view
        latestPosts = jahiaServerServices.getLatestPosts()
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        latestPosts = jahiaServerServices.getLatestPosts()
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
        return latestPosts.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("postExtractCell", forIndexPath: indexPath) as! PostExtractTableViewCell

        // Configure the cell...
        let currentIndex : Int = indexPath.row
        let post : Post = Post(fromNSDictionary: latestPosts[currentIndex] as! NSDictionary)
        
        if let postTitle = post.title {
            cell.postTitleLabel.text = postTitle
        }

        if let postContent = post.content {
            cell.postExtractLabel.text = postContent
        }
        
        if let postDate = post.date {
            cell.postDateLabel.text = JahiaServerServices.getRelativeTime(postDate)
        }
        
        if let postAuthor = post.author {
            cell.postAuthorLabel.text = postAuthor
        }
        
        if let postSpam = post.spam {
            if (postSpam) {
                cell.postMarkedAsSpamLabel.hidden = false
            } else {
                cell.postMarkedAsSpamLabel.hidden = true
            }
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
        let postDetailViewController = segue.destinationViewController as! PostDetailViewController
        let selectedIndexPath = self.tableView.indexPathForSelectedRow()
        if let indexPath = selectedIndexPath {
            let post = Post(fromNSDictionary: latestPosts[indexPath.row] as! NSDictionary)
            postDetailViewController.post = post
        }
    }

}
