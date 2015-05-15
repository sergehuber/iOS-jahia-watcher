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

    let jahiaServerServices : JahiaServerServices = JahiaServerServices.sharedInstance
    
    @IBOutlet weak var postTitleLabel: WKInterfaceLabel!
    @IBOutlet weak var postDateLabel: WKInterfaceLabel!
    @IBOutlet weak var postAuthorLabel: WKInterfaceLabel!
    @IBOutlet weak var postBodyLabel: WKInterfaceLabel!
    
    var post : Post?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        post = context as? Post
        postTitleLabel.setText(post!.title)
        postBodyLabel.setText(post!.content)
        postDateLabel.setText("\(post!.date!.relativeTime)")
        postAuthorLabel.setText(post!.author!)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func viewOnPhone() {
        println("Viewing post on phone...")
    }
    
    @IBAction func markAsSpam() {
        println("Marking post \(post!.path!) as spam...")
        jahiaServerServices.markAsSpam(post!.identifier!)
    }
    
    @IBAction func deletePost() {
        println("Deleting post...")
    }
    
    @IBAction func blockUser() {
        println("Blocking user \(post!.author!)...")
        jahiaServerServices.blockUser(post!.author!)
    }
}
