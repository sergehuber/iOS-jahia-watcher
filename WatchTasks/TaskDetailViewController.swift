//
//  TaskDetailViewController.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 08.05.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import Foundation
import UIKit

class TaskDetailViewController: UIViewController {

    let jahiaWatcherSettings : JahiaWatcherSettings = JahiaWatcherSettings.sharedInstance
    let jahiaServerServices : JahiaServerServices = JahiaServerServices.sharedInstance
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var outcomeToolbar: UIToolbar!
    @IBOutlet weak var previewButton: UIButton!
    var task : Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if let realTask = task {
            task = jahiaServerServices.getTaskActions(realTask)
            if let title = realTask.title {
                titleLabel.text = title
            }
            if let state = realTask.state {
                statusLabel.text = state
            }
            if let description = realTask.description {
                descriptionLabel.text = description
            }
            if let dueDate = realTask.dueDate {
                dueDateLabel.text = JahiaServerServices.getShortDate(dueDate)
            }
            if let nextActions = realTask.nextActions {
                var insertedItems = 0;
                for nextAction in nextActions {
                    if let outcome = nextAction.finalOutcome {
                        outcomeToolbar.items!.append(UIBarButtonItem(title: JahiaServerServices.capitalizeFirstLetter(outcome), style: UIBarButtonItemStyle.Plain, target: self, action: Selector(outcome)))
                    } else {
                        outcomeToolbar.items!.append(UIBarButtonItem(title: JahiaServerServices.capitalizeFirstLetter(nextAction.name), style: UIBarButtonItemStyle.Plain, target: self, action: Selector(nextAction.name!)))
                    }
                    insertedItems++;
                    if (insertedItems < nextActions.count) {
                        outcomeToolbar.items!.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil))
                    }
                }
            }
            if (realTask.previewUrl != nil) {
                previewButton.hidden = false
            } else {
                previewButton.hidden = true
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func accept() {
        
    }
    
    func reject() {
        
    }
    /*
    // MARK: - Navigation
    */
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        let taskContentPreviewController = segue.destinationViewController as! TaskContentPreviewViewController
        taskContentPreviewController.contentUrl = jahiaWatcherSettings.contentRenderUrl(task!.previewUrl!)
    }
    
}