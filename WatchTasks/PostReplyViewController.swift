//
//  PostReplyViewController.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 22.05.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import UIKit

class PostReplyViewController: UIViewController {
    
    let serverServices : ServerServices = ServerServices.sharedInstance
    var postDetailContext : PostDetailContext?
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        titleTextField.text = "Re:" + postDetailContext!.post!.title!
        bodyTextView.text = "Quote : \"" + postDetailContext!.post!.content! + "\"\n";

        let doneBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "dismissKeyboard")
        let keyboardToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 44))
        let toolbarItems = [ doneBarButton ]
        keyboardToolbar.setItems(toolbarItems, animated: false)
        
        titleTextField.inputAccessoryView = keyboardToolbar
        bodyTextView.inputAccessoryView = keyboardToolbar
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
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
        postDetailContext!.jahiaServerSession!.replyToPost(postDetailContext!.post!, title: titleTextField.text, body: bodyTextView.text)
        performSegueWithIdentifier("backToPost", sender: self)
    }
        
}
