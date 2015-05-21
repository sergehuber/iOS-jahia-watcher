//
//  PostDetailViewController.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 18.04.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import UIKit

class PostDetailViewController: UIViewController {

    let jahiaServerServices : JahiaServerServices = JahiaServerServices.sharedInstance
    
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postContentLabel: UILabel!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var postAuthorLabel: UILabel!
    @IBOutlet weak var markedAsSpamLabel: UILabel!
    
    @IBOutlet weak var actionsToolbar: UIToolbar!
    var post : Post?
    var postsTableViewController : PostsTableViewController?
    var postIndex : Int?
    var postDeleted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        displayPost()
    }
    
    func displayPost() {
        if let realPost = post {
            post = jahiaServerServices.getPostActions(realPost)            
            if let title = realPost.title {
                postTitleLabel.text = title
            }
            if let content = realPost.content {
                postContentLabel.text = content
            }
            if let author = realPost.author {
                postAuthorLabel.text = author
            }
            if let date = realPost.date {
                postDateLabel.text = JahiaServerServices.getShortDate(date)
            }
            if let spam = realPost.spam {
                if (spam) {
                    markedAsSpamLabel.hidden = false
                } else {
                    markedAsSpamLabel.hidden = true
                }
            }
            actionsToolbar.items?.removeAll(keepCapacity: false)
            if let actions = realPost.actions {
                var insertedItems = 0;
                for action in actions {
                    let actionBarButtonItem = IdUIBarButtonItem(title: action.displayName, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("\(action.name!)ActionPressed:"))
                    actionBarButtonItem.tag = action.name!.hash
                    actionBarButtonItem.identifier = action.name
                    actionsToolbar.items!.append(actionBarButtonItem)
                    insertedItems++;
                    if (insertedItems < actions.count) {
                        actionsToolbar.items!.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil))
                    }
                }
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController()){
            // we update the list entry
            if (postDeleted) {
                postsTableViewController!.latestPosts.removeAtIndex(postIndex!)
            } else {
                postsTableViewController!.latestPosts[postIndex!] = post!
            }
            postsTableViewController!.needsRefreshing = true
        }
    }
    
    func replyActionPressed(sender: AnyObject) {
        
    }

    func markAsSpamActionPressed(sender: AnyObject) {
        var dialogTitle : String = "Mark as spam"
        var dialogMessage : String = "Are you sure you want to mark this post as spam ?";
        var alert = UIAlertController(title: dialogTitle, message: dialogMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .Destructive, handler: { action in
            switch action.style{
            case .Default:
                println("default")
                
            case .Cancel:
                println("cancel")
                
            case .Destructive:
                println("destructive")
                self.jahiaServerServices.markAsSpam(self.post!.identifier!)
                self.post = self.jahiaServerServices.refreshPost(self.post!)
                self.displayPost()
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: { action in
            switch action.style{
            case .Default:
                println("default")
                
            case .Cancel:
                println("cancel")
                
            case .Destructive:
                println("destructive")
            }
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func unmarkAsSpamActionPressed(sender: AnyObject) {
        let dialogTitle = "Unmark as spam"
        let dialogMessage = "Are you sure you want to remove the spam marker on this message ?"
        var alert = UIAlertController(title: dialogTitle, message: dialogMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .Destructive, handler: { action in
            switch action.style{
            case .Default:
                println("default")
                
            case .Cancel:
                println("cancel")
                
            case .Destructive:
                println("destructive")
                self.jahiaServerServices.unmarkAsSpam(self.post!.identifier!)
                self.post = self.jahiaServerServices.refreshPost(self.post!)
                self.displayPost()
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: { action in
            switch action.style{
            case .Default:
                println("default")
                
            case .Cancel:
                println("cancel")
                
            case .Destructive:
                println("destructive")
            }
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func blockUserActionPressed(sender: AnyObject) {
        var alert = UIAlertController(title: "Block user", message: "Are you sure you want to block this user ?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .Destructive, handler: { action in
            switch action.style{
            case .Default:
                println("default")
                
            case .Cancel:
                println("cancel")
                
            case .Destructive:
                println("destructive")
                self.jahiaServerServices.blockUser(self.post!.author!)
                self.post = self.jahiaServerServices.refreshPost(self.post!)
                self.displayPost()
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: { action in
            switch action.style{
            case .Default:
                println("default")
                
            case .Cancel:
                println("cancel")
                
            case .Destructive:
                println("destructive")
            }
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func unblockUserActionPressed(sender: AnyObject) {
        var alert = UIAlertController(title: "Unblock user", message: "Are you sure you want to unblock this user ?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .Destructive, handler: { action in
            switch action.style{
            case .Default:
                println("default")
                
            case .Cancel:
                println("cancel")
                
            case .Destructive:
                println("destructive")
                self.jahiaServerServices.unblockUser(self.post!.author!)
                self.post = self.jahiaServerServices.refreshPost(self.post!)
                self.displayPost()
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: { action in
            switch action.style{
            case .Default:
                println("default")
                
            case .Cancel:
                println("cancel")
                
            case .Destructive:
                println("destructive")
            }
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func deleteActionPressed(sender: AnyObject) {
        var alert = UIAlertController(title: "Delete Post", message: "Are you sure you want to delete this post ?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .Destructive, handler: { action in
            switch action.style{
            case .Default:
                println("default")
                
            case .Cancel:
                println("cancel")
                
            case .Destructive:
                println("destructive")
                self.jahiaServerServices.deleteNode(self.post!.identifier!, workspace: "live")
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: { action in
            switch action.style{
            case .Default:
                println("default")
                
            case .Cancel:
                println("cancel")
                
            case .Destructive:
                println("destructive")
            }
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
