//
//  TaskContentPreviewViewController.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 11.05.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import UIKit

class TaskContentPreviewViewController: UIViewController {

    var contentUrl : String?
    
    @IBOutlet weak var contentWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let contentURLRequest = NSURLRequest(URL: NSURL(string: contentUrl!)!)
        contentWebView.loadRequest(contentURLRequest)
    }
}
