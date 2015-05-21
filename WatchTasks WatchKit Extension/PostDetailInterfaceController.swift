//
//  PostDetailInterfaceController.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 08.04.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import WatchKit
import Foundation

class PostDetailInterfaceController: WKInterfaceController {

    let jahiaServerServices = JahiaServerServices.sharedInstance
    let jahiaWatcherSettings = JahiaWatcherSettings.sharedInstance
    
    @IBOutlet weak var postTitleLabel: WKInterfaceLabel!
    @IBOutlet weak var postDateLabel: WKInterfaceLabel!
    @IBOutlet weak var postAuthorLabel: WKInterfaceLabel!
    @IBOutlet weak var postBodyLabel: WKInterfaceLabel!
    @IBOutlet weak var postSpamMarkerLabel: WKInterfaceLabel!
    
    var post : Post?
    var postsInterfaceController : PostsInterfaceController?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        post = context as? Post
        postTitleLabel.setText(post!.title)
        postBodyLabel.setText(post!.content)
        postDateLabel.setText("\(post!.date!.relativeTime)")
        postAuthorLabel.setText(post!.author!)
        
        buildPostActionsMenu()
    }
    
    func buildPostActionsMenu() {
        clearAllMenuItems()
        let updatedPost = jahiaServerServices.getPostActions(post!)
        if (updatedPost.actions != nil) {
            for action in updatedPost.actions! {
                var actionSelector = Selector(action.name! + "Pressed:")
                addMenuItemWithItemIcon(WKMenuItemIcon.Accept, title: action.displayName!, action: actionSelector)
            }
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        if (post!.spam!) {
            postSpamMarkerLabel.setHidden(false)
        } else {
            postSpamMarkerLabel.setHidden(true)
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func viewOnPhone() {
        println("Viewing post on phone...")
        var userInfo : [NSObject : AnyObject] = ["action": "viewPost",
            "viewUrl": jahiaWatcherSettings.contentRenderUrl(post!.viewUrl!)]
        WKInterfaceController.openParentApplication(userInfo, reply: { (reply, error) -> Void in
            println("parent application replied reply=\(reply) error=\(error)")
        })
    }
    
    func markAsSpamPressed(sender : AnyObject?) {
        presentControllerWithName("confirmationDialog", context: ConfirmationDialogContext(identifier: "markAsSpamDialog", title: "Mark as spam", message: "Are you sure you want to mark this post as spam ?", yesHandler : { context in
            println("Marking post \(self.post!.path!) as spam...")
            self.jahiaServerServices.markAsSpam(self.post!.identifier!)
            self.post!.spam = true
            }, noHandler : {context in }))
    }

    func unmarkAsSpamPressed(sender : AnyObject?) {
        presentControllerWithName("confirmationDialog", context: ConfirmationDialogContext(identifier: "markAsSpamDialog", title: "Unmark as spam", message: "Are you sure you want to unmark this post as spam ?", yesHandler : { context in
            println("Unmarking post \(self.post!.path!) as spam...")
            self.jahiaServerServices.unmarkAsSpam(self.post!.identifier!)
            self.post!.spam = false
            }, noHandler : {context in }))
    }
    
    func deletePressed(sender : AnyObject?) {
        presentControllerWithName("confirmationDialog", context: ConfirmationDialogContext(identifier: "deletePostDialog", title: "Delete ?", message: "Are you sure you want to delete this post ?", yesHandler : { context in
            println("Deleting post...")
            }, noHandler : {context in }))
    }
    
    func blockUserPressed(sender : AnyObject?) {
        presentControllerWithName("confirmationDialog", context: ConfirmationDialogContext(identifier: "blockUserDialog", title: "Block user", message: "Are you sure you want to block the account of this posts author", yesHandler : { context in
            println("Blocking user account \(self.post!.author!)...")
            self.jahiaServerServices.blockUser(self.post!.author!)
            }, noHandler : {context in }))
    }

    func unblockUserPressed(sender : AnyObject?) {
        presentControllerWithName("confirmationDialog", context: ConfirmationDialogContext(identifier: "blockUserDialog", title: "Unblock user", message: "Are you sure you want to unblock the account of this posts author", yesHandler : { context in
            println("Unblocking user account \(self.post!.author!)...")
            self.jahiaServerServices.unblockUser(self.post!.author!)
            }, noHandler : {context in }))
    }
    
    func replyPressed(sender : AnyObject?) {
    }
}
