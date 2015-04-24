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
    
    var post : NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let realPost = post {
            let postProperties : NSDictionary = realPost["properties"] as! NSDictionary
            let titleProperty : NSDictionary = postProperties["jcr__title"] as! NSDictionary
            let postTitle = titleProperty["value"] as! String
            postTitleLabel.text = postTitle
            let contentProperty : NSDictionary? = postProperties["content"] as? NSDictionary
            if (contentProperty != nil) {
                let postContent : String = contentProperty!["value"] as! String
                postContentLabel.text = jahiaServerServices.stripHTML(postContent)
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

}
