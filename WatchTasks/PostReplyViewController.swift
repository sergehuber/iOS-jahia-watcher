//
//  PostReplyViewController.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 22.05.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import UIKit

class PostReplyViewController: UIViewController {
    
    let jahiaServerServices : JahiaServerServices = JahiaServerServices.sharedInstance
    var post : Post?

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        titleTextField.text = "Re:" + post!.title!
        bodyTextView.text = "Quote : \"" + post!.content! + "\"\n";
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
        }
    }
    
    @IBAction func saveReplyPressed(sender: AnyObject) {
        jahiaServerServices.replyToPost(post!, title: titleTextField.text, body: bodyTextView.text)
        performSegueWithIdentifier("backToPost", sender: self)
    }
        
}
