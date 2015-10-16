//
//  DisplayWebViewController.swift
//  Jahia Watcher
//
//  Created by Serge Huber on 16.10.15.
//  Copyright © 2015 Jahia Solutions. All rights reserved.
//

import UIKit

class DisplayWebViewController: UIViewController {
    
    var webViewUrl : NSURL?

    @IBOutlet weak var webView: UIWebView!
    
    override func viewWillAppear(animated: Bool) {
        let request = NSMutableURLRequest(URL: webViewUrl!)
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
        webView.loadRequest(request)
    }

}
