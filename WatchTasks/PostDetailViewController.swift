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
    
    var post : Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let realPost = post {
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
    @IBAction func reply(sender: AnyObject) {
    }

    @IBAction func markAsSpam(sender: AnyObject) {
        jahiaServerServices.markAsSpam(post!.identifier!)
    }
    @IBAction func blockUser(sender: AnyObject) {
        jahiaServerServices.blockUser(post!.author!)
    }
    @IBAction func deletePost(sender: AnyObject) {
    }
}
