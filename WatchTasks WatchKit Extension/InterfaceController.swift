//
//  InterfaceController.swift
//  Jahia Watcher WatchKit Extension
//
//  Created by Serge Huber on 09.03.15.
//  Copyright (c) 2015 Jahia Solutions. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
    
    let jahiaUserName = "root"
    let jahiaPassword = "root1234"
    let jahiaUserPath = "/users/root"
    let jahiaServerHost = "localhost";
    let jahiaServerPort = 8080;
    let jahiaServerProtocol = "http";
    let jahiaServerContextPath = "";
    let jahiaServerLoginServletPath = "/cms/login";
    let jahiaServerJcrApiServletPath = "/modules/api/jcr/v1";

    @IBOutlet weak var tasksLabel: WKInterfaceLabel!
    
    @IBOutlet weak var viewTasksButton: WKInterfaceButton!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        login()

        getWorkflowTasks()
        
    }
    
    func login() {
        let jahiaLoginURL : NSURL = NSURL(string: "\(jahiaServerProtocol)://\(jahiaServerHost):\(jahiaServerPort)\(jahiaServerContextPath)\(jahiaServerLoginServletPath)")!
        let request = NSMutableURLRequest(URL: jahiaLoginURL)
        let requestString : String = "doLogin=true&restMode=true&username=\(jahiaUserName)&password=\(jahiaPassword)&redirectActive=false";
        let postData = NSMutableData()
        postData.appendData(requestString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        
        request.HTTPMethod = "POST"
        request.setValue(NSString(format: "%lu", postData.length), forHTTPHeaderField: "Content-Length")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = postData
        request.timeoutInterval = 10
        
        var response: NSURLResponse?
        var error: NSError?
        var dataVal: NSData =  NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error:&error)!
        var err: NSError
        if let httpResponse = response as? NSHTTPURLResponse {
            println(httpResponse.statusCode)
        }
    }
    
    func getWorkflowTasks() {
        
        let jahiaWorkflowTasksURL : NSURL = NSURL(string: "\(jahiaServerProtocol)://\(jahiaServerHost):\(jahiaServerPort)\(jahiaServerContextPath)\(jahiaServerJcrApiServletPath)/default/en/paths\(jahiaUserPath)/workflowTasks?noLinks&includeFullChildren")!
        
        let request = NSMutableURLRequest(URL: jahiaWorkflowTasksURL)
        
        request.addValue("application/json,application/hal+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10
        
        var response: NSURLResponse?
        var error: NSError?
        var dataVal: NSData =  NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error:&error)!
        var err: NSError
        if let httpResponse = response as? NSHTTPURLResponse {
            println(httpResponse.statusCode)
        }
        var datastring = NSString(data: dataVal, encoding: NSUTF8StringEncoding)
        var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataVal, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
        
        let taskChildren : Dictionary = jsonResult["children"] as NSDictionary
        println("\(taskChildren.count) tasks found.")
        var openTaskCount = 0;
        for (taskName, task) in taskChildren {
            let taskProperties = task["properties"] as NSDictionary
            let taskState = taskProperties["state"] as NSDictionary
            let taskStateValue = taskState["value"] as NSString
            if (taskStateValue != "finished") {
                openTaskCount++;
            }
        }
        
        if (openTaskCount == 0) {
            tasksLabel.setText("No tasks waiting");
            viewTasksButton.setHidden(true)
        } else if (openTaskCount == 1) {
            tasksLabel.setText("One task waiting.");
            viewTasksButton.setHidden(false)
        } else if (openTaskCount > 1) {
            tasksLabel.setText("You have \(openTaskCount) tasks waiting.");
            viewTasksButton.setHidden(false)
        }
    }

    
    @IBAction func viewTasks() {
        
        WKInterfaceController.openParentApplication(["viewTasks" : "root"], reply: { (reply, error) -> Void in
        })
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
